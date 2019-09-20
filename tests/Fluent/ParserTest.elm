module Fluent.ParserTest exposing (..)

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
                (Parser.run Fluent.Parser.parser wholeExampleFile)
                (Ok wholeFileExampleExpectation)


wholeExampleFile : String
wholeExampleFile =
    """tabs-close-warning =
    You are about to close {$tabCount} tabs.
    Are you sure you want to continue?


page-title = This is the title

youve-clicked = You've clicked { $count ->
              [one]    once
             *[other]  { $count } times
           }.

enter-name = Please enter your name below

your-name-is = Your name is { $name }.

your-country-is = Your country is { $country }.

complex-info-header = Complex Info

# The generated complexInfo function should have a type signature
# that includes the $name arg:
complex-info = { your-name-is } You are wonderful


number-tests-section-title = Number tests

message-with-hard-coded-number-and-number-function = There are { NUMBER(12345) } things.

message-with-hard-coded-bare-number-literal = There are { 123456.7 } things.

message-with-number-function-and-arg = There are { NUMBER($count) } things

message-with-number-function-and-params = There are { NUMBER(7890, useGrouping: 0, minimumIntegerDigits: 2 ) } things

message-with-money = You have { NUMBER($money, currencyDisplay:"name") } in your bank.

message-with-mixed-numeric-select = You have { $count ->
    [0]       no new messages
    [one]     one new message
   *[other]   { $count } new messages
 }


date-tests-section-title = Dates tests

here-is-a-date = Here is a formatted date: { DATETIME($mydate, day: "numeric", month:"long", year:"numeric", hour:"2-digit", minute:"2-digit", second:"2-digit", hour12: 0, era:"short") }

parameterized-terms-tests-title = Parameterized terms

-parameterized-thing = { $article ->
                  *[indefinite] { $count ->
                                       [one]    a parameterized thing
                                      *[other]  some parameterized things
                                }
                   [definite]   { $count ->
                                       [one]   the parameterized thing
                                      *[other] the parameterized things
                                }
 }

message-with-parameterized-thing = We have { -parameterized-thing(article: "definite", count: 7) }


html-tests-section-title = HTML tests

simple-text-html = Some text with this &amp; that.

tags-html = Some <b>bold text</b> and some <b>bold <i>and italic</i></b> text.

attributes-html = Some <span class="foo">highlighted text</span>.

argument-html = Hello <b>{ $username }</b>!

html-message-reference-html = { argument-html } You came back

attribute-substitution-html = <b foo="{ attribute-substitution-html.foo }">Some text</b>
                            .foo = Hello

html-attributes-test-section-title = HTML attributes

last-movement = Your last movement:

havent-moved-yet = You haven't moved yet

you-moved-left = You moved left

you-moved-right = You moved right

go-left-or-right-html = Go <a data-left>left</a> or <a data-right>right</a>"""


wholeFileExampleExpectation : List Resource
wholeFileExampleExpectation =
    [ EntryResource (MessageEntry { id = "tabs-close-warning", value = "    You are about to close {$tabCount} tabs.\n    Are you sure you want to continue?" })
    , EntryResource (MessageEntry { id = "page-title", value = "This is the title" })
    , EntryResource (MessageEntry { id = "youve-clicked", value = "You've clicked { $count ->              [one]    once\n             *[other]  { $count } times\n           }." })
    , EntryResource (MessageEntry { id = "enter-name", value = "Please enter your name below" })
    , EntryResource (MessageEntry { id = "your-name-is", value = "Your name is { $name }." })
    , EntryResource (MessageEntry { id = "your-country-is", value = "Your country is { $country }." })
    , EntryResource (MessageEntry { id = "complex-info-header", value = "Complex Info" })
    , EntryResource (CommentLineEntry "# The generated complexInfo function should have a type signature")
    , EntryResource (CommentLineEntry "# that includes the $name arg:")
    , EntryResource (MessageEntry { id = "complex-info", value = "{ your-name-is } You are wonderful" })
    , EntryResource (MessageEntry { id = "number-tests-section-title", value = "Number tests" })
    , EntryResource (MessageEntry { id = "message-with-hard-coded-number-and-number-function", value = "There are { NUMBER(12345) } things." })
    , EntryResource (MessageEntry { id = "message-with-hard-coded-bare-number-literal", value = "There are { 123456.7 } things." })
    , EntryResource (MessageEntry { id = "message-with-number-function-and-arg", value = "There are { NUMBER($count) } things" })
    , EntryResource (MessageEntry { id = "message-with-number-function-and-params", value = "There are { NUMBER(7890, useGrouping: 0, minimumIntegerDigits: 2 ) } things" })
    , EntryResource (MessageEntry { id = "message-with-money", value = "You have { NUMBER($money, currencyDisplay:\"name\") } in your bank." })
    , EntryResource (MessageEntry { id = "message-with-mixed-numeric-select", value = "You have { $count ->    [0]       no new messages\n    [one]     one new message\n   *[other]   { $count } new messages\n }" })
    , EntryResource (MessageEntry { id = "date-tests-section-title", value = "Dates tests" })
    , EntryResource (MessageEntry { id = "here-is-a-date", value = "Here is a formatted date: { DATETIME($mydate, day: \"numeric\", month:\"long\", year:\"numeric\", hour:\"2-digit\", minute:\"2-digit\", second:\"2-digit\", hour12: 0, era:\"short\") }" })
    , EntryResource (MessageEntry { id = "parameterized-terms-tests-title", value = "Parameterized terms" })
    , JunkResource "-parameterized-thing = { $article ->"
    , JunkResource "                  *[indefinite] { $count ->"
    , JunkResource "                                       [one]    a parameterized thing"
    , JunkResource "                                      *[other]  some parameterized things"
    , JunkResource "                                }"
    , JunkResource "                   [definite]   { $count ->"
    , JunkResource "                                       [one]   the parameterized thing"
    , JunkResource "                                      *[other] the parameterized things"
    , JunkResource "                                }"
    , JunkResource " }"
    , JunkResource ""
    , EntryResource (MessageEntry { id = "message-with-parameterized-thing", value = "We have { -parameterized-thing(article: \"definite\", count: 7) }" })
    , EntryResource (MessageEntry { id = "html-tests-section-title", value = "HTML tests" })
    , EntryResource (MessageEntry { id = "simple-text-html", value = "Some text with this &amp; that." })
    , EntryResource (MessageEntry { id = "tags-html", value = "Some <b>bold text</b> and some <b>bold <i>and italic</i></b> text." })
    , EntryResource (MessageEntry { id = "attributes-html", value = "Some <span class=\"foo\">highlighted text</span>." })
    , EntryResource (MessageEntry { id = "argument-html", value = "Hello <b>{ $username }</b>!" })
    , EntryResource (MessageEntry { id = "html-message-reference-html", value = "{ argument-html } You came back" })
    , EntryResource (MessageEntry { id = "attribute-substitution-html", value = "<b foo=\"{ attribute-substitution-html.foo }\">Some text</b>                            .foo = Hello" })
    , EntryResource (MessageEntry { id = "html-attributes-test-section-title", value = "HTML attributes" })
    , EntryResource (MessageEntry { id = "last-movement", value = "Your last movement:" })
    , EntryResource (MessageEntry { id = "havent-moved-yet", value = "You haven't moved yet" })
    , EntryResource (MessageEntry { id = "you-moved-left", value = "You moved left" })
    , EntryResource (MessageEntry { id = "you-moved-right", value = "You moved right" })
    , EntryResource (MessageEntry { id = "go-left-or-right-html", value = "Go <a data-left>left</a> or <a data-right>right</a>" })
    ]
