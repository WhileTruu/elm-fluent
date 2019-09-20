module Fluent.Encoder exposing (..)

import Elm.CodeGen
import Elm.Pretty
import Elm.Syntax.Declaration as S
import Elm.Syntax.Exposing as S
import Elm.Syntax.Expression as S
import Elm.Syntax.Node as S
import Elm.Syntax.Range as S
import Elm.Syntax.TypeAnnotation as S
import Fluent.Ast as Ast exposing (Message)
import Pretty


encode : List String -> List Ast.Resource -> String
encode moduleName resources =
    Elm.CodeGen.file
        (Elm.CodeGen.normalModule moduleName [ S.FunctionExpose ".." ])
        []
        (resources
            |> List.filterMap resourceToDeclaration
        )
        []
        |> (Elm.Pretty.pretty >> Pretty.pretty 80)


resourceToDeclaration : Ast.Resource -> Maybe S.Declaration
resourceToDeclaration resource =
    case resource of
        Ast.EntryResource entry ->
            case entry of
                Ast.MessageEntry message ->
                    Just <| S.FunctionDeclaration <| messageToFunction message

                Ast.TermEntry ->
                    Nothing

                Ast.CommentLineEntry string ->
                    Nothing

        Ast.JunkResource string ->
            Nothing


messageToFunction : Message -> S.Function
messageToFunction message =
    { documentation = Nothing
    , signature =
        Just <|
            S.Node S.emptyRange
                { name = S.Node S.emptyRange message.id
                , typeAnnotation = S.Node S.emptyRange (S.GenericType "String")
                }
    , declaration =
        S.Node
            S.emptyRange
            { name = S.Node S.emptyRange message.id
            , arguments = []
            , expression = S.Node S.emptyRange (S.Literal message.value)
            }
    }
