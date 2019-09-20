module Fluent.Parser exposing (..)

import Fluent.Ast exposing (..)
import Parser exposing ((|.), (|=), Parser)
import Regex
import Set


parser : Parser (List Resource)
parser =
    let
        step : List Resource -> Parser (Parser.Step (List Resource) (List Resource))
        step resources =
            Parser.oneOf
                [ Parser.end |> Parser.map (\_ -> Parser.Done (List.reverse resources))
                , Parser.succeed (\a -> Parser.Loop (a :: resources))
                    |= resource
                , Parser.succeed ()
                    |> Parser.map (\_ -> Parser.Done (List.reverse resources))
                ]
    in
    Parser.succeed identity
        |= Parser.loop [] step
        |. Parser.end


resource : Parser Resource
resource =
    Parser.oneOf
        [ Parser.succeed EntryResource
            |= entry
            |. Parser.spaces
        , Parser.succeed JunkResource
            |= (Parser.chompUntilEndOr "\n" |> Parser.getChompedString)
            |. lineEnd
        ]


entry : Parser Entry
entry =
    Parser.oneOf
        [ message |> Parser.map MessageEntry
        , commentLine |> Parser.map CommentLineEntry

        -- TODO: Add TermEntry parser
        ]



{- Message -}


message : Parser Message
message =
    Parser.succeed Message
        |= identifier
        |. zeroOrMore ((==) ' ')
        |. Parser.symbol "="
        |. zeroOrMore ((==) ' ')
        |= multiline


multiline : Parser String
multiline =
    let
        step : List String -> Parser (Parser.Step (List String) String)
        step lines =
            let
                conclusion whitespace lineWithoutWhitespace =
                    let
                        line =
                            whitespace ++ lineWithoutWhitespace
                    in
                    if line == "" then
                        Parser.Done (String.join "\n" (List.reverse lines))

                    else
                        Parser.Loop (line :: lines)
            in
            Parser.succeed conclusion
                |. Parser.chompIf isNewLine
                |= (Parser.chompWhile (\c -> c == ' ') |> Parser.getChompedString)
                |= (Parser.chompUntilEndOr "\n" |> Parser.getChompedString)
    in
    Parser.oneOf
        [ Parser.succeed (\a b -> a ++ b)
            |= oneOrMore (\c -> textChar c || specialTextChar c)
            |= Parser.loop [] step
        , Parser.loop [] step
        ]



{- CommentLine -}


commentLine : Parser String
commentLine =
    Parser.oneOf ([ "###", "##", "#" ] |> List.map Parser.lineComment)
        |> Parser.getChompedString



{- Block Expressions -}
{- Identifier -}


identifier : Parser String
identifier =
    Parser.variable
        { start = Char.isAlpha
        , inner = \c -> Char.isAlphaNum c || c == '_' || c == '-'
        , reserved = Set.empty
        }



{- Content Characters

   Translation content can be written using any Unicode characters. However,
   some characters are considered special depending on the type of content
   they're in. See text_char and quoted_char for more information.

   Some Unicode characters, even if allowed, should be avoided in Fluent
   resources. See spec/recommendations.md.
-}


anyChar : Char -> Bool
anyChar c =
    Regex.fromString "[\u{0000}-\u{10FFFF}]"
        |> Maybe.map (\regex -> Regex.contains regex (String.fromChar c))
        |> Maybe.withDefault False



{- Text elements

   The primary storage for content are text elements. Text elements are not
   delimited with quotes and may span multiple lines as long as all lines are
   indented. The opening brace ({) marks a start of a placeable in the pattern
   and may not be used in text elements verbatim. Due to the indentation
   requirement some text characters may not appear as the first character on a
   new line.
-}


specialTextChar : Char -> Bool
specialTextChar c =
    c == '{' || c == '}'


textChar : Char -> Bool
textChar c =
    anyChar c && (not <| specialTextChar c) && (c /= '\n')


indentedChar : Char -> Bool
indentedChar c =
    textChar c && c /= '[' && c /= '*' && c /= '.'



-- WhiteSpace


lineEnd : Parser ()
lineEnd =
    Parser.oneOf
        [ Parser.end
        , Parser.symbol "\n"
        , Parser.symbol "\\u000D\\u000A"
        ]



-- Helpers


zeroOrMore : (Char -> Bool) -> Parser String
zeroOrMore isOk =
    Parser.succeed ()
        |. Parser.chompWhile isOk
        |> Parser.getChompedString


oneOrMore : (Char -> Bool) -> Parser String
oneOrMore isOk =
    Parser.succeed ()
        |. Parser.chompIf isOk
        |. Parser.chompWhile isOk
        |> Parser.getChompedString


isNewLine : Char -> Bool
isNewLine char =
    char == '\n'
