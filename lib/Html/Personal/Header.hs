{-# LANGUAGE OverloadedStrings #-}

module Html.Personal.Header where

import Control.Lens
import Control.Monad.Reader
import Data.Env.Types
import Data.Foldable.Monoid
import Html.Common.Header
import Html.Common.Page
import Html.Personal.Page.About
-- import Html.Personal.Page.Characters
import Html.Personal.Page.Contact
-- import Html.Personal.Page.Favourites
-- import Html.Personal.Page.Health
import Html.Personal.Page.Intro
import Html.Personal.Page.Maths
import Html.Personal.Page.Music
import Html.Personal.Page.Origami
-- import Html.Personal.Page.Talks
import Html.Personal.Social
import Text.Blaze.Html5             as H hiding (main)

linkHamRadio ∷ (MonadReader Website m) ⇒ m Html
linkHamRadio = do
    urlHamRadio' <- view $ urls . urlHamRadio
    pure $ extNav (stringValue . show $ urlHamRadio') "Ham Radio"

linkSoftware ∷ (MonadReader Website m) ⇒ m Html
linkSoftware = do
    urlPortfolio' <- view $ urls . urlPortfolio
    pure $ extNav (stringValue . show $ urlPortfolio') "Software"

linkBlogPersonal ∷ (MonadReader Website m) ⇒ m Html
linkBlogPersonal = do
    urlBlogPersonal' <- view $ urls . urlBlogPersonal
    pure $ extNav (stringValue . show $ urlBlogPersonal') "Blog"

linkReviews ∷ (MonadReader Website m) ⇒ m Html
linkReviews = do
    urlReviews' <- view $ urls . urlReviews
    pure $ extNav (stringValue . show $ urlReviews') "Reviews"

htmlHeader ∷ (MonadReader Website m) ⇒ m Html
htmlHeader = do
    socialIcons' <- socialIcons
    pages <- foldA [
        pageIntro,
        -- pageTalks,
        -- pageFavourites,
        -- pageCharacters,
        linkHamRadio,
        -- pageHealth,
        pageMusic,
        pageMaths,
        pageOrigami,
        pageAbout,
        linkSoftware,
        linkBlogPersonal,
        linkReviews,
        pageContact
        ]
    pure . makeHeader "#intro" "Ember Dart" socialIcons' $ pages
