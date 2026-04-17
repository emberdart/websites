{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -ddump-splices #-}

module Control.Exception.CommentException where

import Control.Exception
import Control.Exception.InvalidDateException
import Control.Exception.ParseFileException
import Control.Lens

-- we could probably do better here
data CommentException = CommentInvalidDateException InvalidDateException | CommentParseFileException ParseFileException
    deriving stock (Show)

instance Exception CommentException

makeClassyPrisms ''CommentException