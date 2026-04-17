{-# LANGUAGE OverloadedStrings #-}

module Html.HamRadio.Header where

import Control.Lens
import Control.Monad.Reader
import Data.Env.Types
import Html.Common.Header
import Html.Common.Page
import Html.HamRadio.Page.Contact
import Html.HamRadio.Page.HamRadio
import Text.Blaze.Html5         as H hiding (main)

htmlHeader ∷ MonadReader Website m ⇒ m Html
htmlHeader = do
    urlPersonal' <- view $ urls . urlPersonal
    pageHamRadio' <- pageHamRadio
    pageContact' <- pageContact
    urlBlogHamRadio' <- view $ urls . urlBlogHamRadio
    pure . makeHeader "" "M0ORI: Dan Dart" mempty $ do
        extNav (stringValue $ show urlPersonal') "Dan Dart"
        pageHamRadio'
        extNav (stringValue $ show urlBlogHamRadio') "Blog"
        pageContact'
