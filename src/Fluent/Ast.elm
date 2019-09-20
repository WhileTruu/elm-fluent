module Fluent.Ast exposing (..)

{- An FTL file defines a Resource consisting of Entries. -}


type Resource
    = EntryResource Entry
    | JunkResource String



{- Entries are the main building blocks of Fluent. They define translations and
   contextual and semantic information about the translations. During the AST
   construction, adjacent comment lines of the same comment type (defined by the
   number of #) are joined together. Single-# comments directly preceding Messages
   and Terms are attached to the Message or Term and are not standalone Entries.
-}


type Entry
    = MessageEntry Message
    | TermEntry
    | CommentLineEntry String


type alias Message =
    { id : String
    , value : String
    }
