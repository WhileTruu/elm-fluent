module Fluent.ParserTest exposing (..)

import Constants
import Expect exposing (Expectation)
import Fluent.Ast exposing (..)
import Fluent.Parser
import Parser
import Test exposing (..)


parserTest : Test
parserTest =
    describe "parser" <|
        [ test "parses single line string messages" <|
            \_ ->
                Expect.equal
                    (Parser.run Fluent.Parser.parser "hello = Hello, world!\n")
                    (Ok
                        [ EntryResource
                            (MessageEntry { id = "hello", value = "Hello, world!" })
                        ]
                    )
        , test "parses single line string messages without newline" <|
            \_ ->
                Expect.equal
                    (Parser.run Fluent.Parser.parser <| "hello = Hello, world!")
                    (Ok
                        [ EntryResource <|
                            MessageEntry
                                { id = "hello", value = "Hello, world!" }
                        ]
                    )
        ]


{-| This should make it pretty clear whether things are moving in the right
direction.
-}
wholeFileTest : Test
wholeFileTest =
    test "parses the whole file to best of it's current ability" <|
        \_ ->
            Expect.equal
                (Parser.run Fluent.Parser.parser Constants.fluentFile1Content)
                (Ok Constants.fluentFile1Ast)
