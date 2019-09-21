module Fluent.GeneratorTest exposing (..)

import Expect
import Fluent.Generator
import String.Extra
import Test exposing (Test, describe, test)


ftlToElmTest : Test
ftlToElmTest =
    describe "ftlToElm" <|
        let
            fluentInput : Fluent.Generator.File
            fluentInput =
                { name = [ "EN" ], content = "hello = Hello, world!" }

            elmOutput : Fluent.Generator.File
            elmOutput =
                { name = [ "EN" ]
                , content =
                    """
                      module EN exposing (..)


                      hello : String
                      hello =
                          "Hello, world!"
                      """
                        |> String.Extra.unindent
                        |> String.trimLeft
                }
        in
        [ test "turns one line fluent message into an elm value " <|
            \_ ->
                Fluent.Generator.ftlToElm fluentInput |> Expect.equal (Ok elmOutput)
        ]
