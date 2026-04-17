{-# LANGUAGE TemplateHaskell #-}

module Control.Exception.ParseFileException where

import Control.Exception
import Control.Lens
import Data.ByteString.Char8

data ParseFileException = ParseFilePartialException FilePath ByteString | ParseFileFailException FilePath ByteString [String] String
    deriving stock (Show)

instance Exception ParseFileException

makeClassyPrisms ''ParseFileException