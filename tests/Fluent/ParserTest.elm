module Fluent.ParserTest exposing (..)

import Expect exposing (Expectation)
import Fluent.Ast exposing (..)
import Fluent.Parser
import Fuzz exposing (Fuzzer, int, list, string)
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
        ]
