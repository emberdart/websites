{-# LANGUAGE TemplateHaskell #-}

module Control.Exception.AtomException where

import Control.Exception
import Control.Exception.Atom.MissingAtomURIException
import Control.Exception.Atom.CantGenerateFeedException
import Control.Lens

data AtomException = AtomMissingAtomURIException MissingAtomURIException
                   | AtomCantGenerateFeedException CantGenerateFeedException
    deriving stock (Show)

instance Exception AtomException

makeClassyPrisms ''AtomException