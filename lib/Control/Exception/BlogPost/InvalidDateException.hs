{-# LANGUAGE DerivingVia #-}

module Control.Exception.BlogPost.InvalidDateException where

import Control.Exception

newtype InvalidDateException = InvalidDateException String
    deriving stock (Show)

instance Exception InvalidDateException