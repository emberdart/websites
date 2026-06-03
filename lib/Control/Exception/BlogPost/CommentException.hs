{-# LANGUAGE TemplateHaskell #-}

module Control.Exception.BlogPost.CommentException where

import Control.Exception
import Control.Exception.BlogPost.InvalidDateException
import Control.Exception.BlogPost.ParseFileException
import Control.Lens

-- we could probably do better here
data CommentException = CommentInvalidDateException InvalidDateException | CommentParseFileException ParseFileException
    deriving stock (Show)

instance Exception CommentException

makeClassyPrisms ''CommentException