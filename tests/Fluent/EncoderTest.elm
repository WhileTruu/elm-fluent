module Fluent.EncoderTest exposing (..)

import Expect
import Fluent.Encoder
import Fluent.Parser
import Parser
import String.Extra
import Test exposing (Test, describe, test)


encodeTest : Test
encodeTest =
    describe "encode" <|
        let
            fluentInput : String
            fluentInput =
                "hello = Hello, world!"

            elmOutput : String
            elmOutput =
                """
                module EN exposing (..)


                hello : String
                hello =
                    "Hello, world!"
                """
                    |> String.Extra.unindent
                    |> String.trimLeft
        in
        [ test "encodes" <|
            \_ ->
                Parser.run Fluent.Parser.parser fluentInput
                    |> Result.map (Fluent.Encoder.encode [ "EN" ])
                    |> Expect.equal (Ok elmOutput)
        ]
