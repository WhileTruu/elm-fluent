module Fluent.Generator exposing (File, ftlToElm)

import Elm.CodeGen
import Elm.Pretty
import Elm.Syntax.Declaration as S
import Elm.Syntax.Exposing as S
import Elm.Syntax.Expression as S
import Elm.Syntax.Node as S
import Elm.Syntax.Range as S
import Elm.Syntax.TypeAnnotation as S
import Fluent.Ast as Ast exposing (Message)
import Fluent.Parser
import Parser
import Pretty
import String.Extra


type alias File =
    { name : List String, content : String }


ftlToElm : File -> Result (List Parser.DeadEnd) File
ftlToElm fluentFile =
    Parser.run Fluent.Parser.parser fluentFile.content
        |> Result.map (List.filterMap resourceToDeclaration)
        |> Result.map
            (\a ->
                Elm.CodeGen.file
                    (Elm.CodeGen.normalModule fluentFile.name [ S.FunctionExpose ".." ])
                    []
                    a
                    []
            )
        |> Result.map (Elm.Pretty.pretty >> Pretty.pretty 80 >> File fluentFile.name)


resourceToDeclaration : Ast.Resource -> Maybe S.Declaration
resourceToDeclaration resource =
    case resource of
        Ast.EntryResource entry ->
            case entry of
                Ast.MessageEntry message ->
                    Just <| S.FunctionDeclaration <| messageToFunction message

                Ast.TermEntry ->
                    Nothing

                Ast.CommentLineEntry _ ->
                    Nothing

        Ast.JunkResource _ ->
            Nothing


messageToFunction : Message -> S.Function
messageToFunction message =
    let
        name : S.Node String
        name =
            message.id
                |> String.Extra.camelize
                |> String.Extra.decapitalize
                |> S.Node S.emptyRange
    in
    { documentation = Nothing
    , signature =
        Just <|
            S.Node S.emptyRange
                { name = name
                , typeAnnotation = S.Node S.emptyRange (S.GenericType "String")
                }
    , declaration =
        S.Node
            S.emptyRange
            { name = name
            , arguments = []
            , expression = S.Node S.emptyRange (S.Literal message.value)
            }
    }
