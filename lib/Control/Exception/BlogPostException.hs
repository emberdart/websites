{-# LANGUAGE TemplateHaskell #-}

module Control.Exception.BlogPostException where

import Control.Exception
import Control.Exception.BlogPost.CommentException
import Control.Exception.BlogPost.InvalidDateException
import Control.Exception.BlogPost.MissingPostIdException
import Control.Exception.BlogPost.ParseFileException
import Control.Lens

-- we could probably do better here
data BlogPostException = BlogPostCommentException CommentException
                        | BlogPostInvalidDateException InvalidDateException
                        | BlogPostMissingPostIdException MissingPostIdException
                        | BlogPostParseFileException ParseFileException
    deriving stock (Show)

instance Exception BlogPostException

makeClassyPrisms ''BlogPostException