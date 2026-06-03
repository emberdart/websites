module Control.Exception.Atom.CantGenerateFeedException where

import Control.Exception
import Data.Text.NonEmpty              (NonEmptyText)
import Network.URI

data CantGenerateFeedException = CantGenerateFeedException {
    excAtomXml :: URI,
    excSelfUrl :: URI,
    excDomain :: URI,
    excTitle :: NonEmptyText
} deriving stock (Show)

instance Exception CantGenerateFeedException where
    displayException ex = "Can't generate a feed for this blog, no information was given by the library about why. Debug information: " <> show ex

