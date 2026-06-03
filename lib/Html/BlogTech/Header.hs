{-# LANGUAGE OverloadedStrings #-}

module Html.BlogTech.Header where

import Control.Lens
import Control.Monad.Reader
import Data.Env.Types
import Data.String
import Html.BlogTech.Page.Blog
import Html.Common.Header
import Html.Common.Page
import Text.Blaze.Html5           as H hiding (main)
import Text.Pandoc.Highlighting

htmlHeader ∷ MonadReader Website m ⇒ Html → Html → Html → m Html
htmlHeader blogPostLinks blogTagLinks blogPosts = do
    urlPortfolio' <- view $ urls . urlPortfolio
    pageBlog' <- pageBlog blogPostLinks blogTagLinks blogPosts
    atomXml' <- view $ siteType . atomUrl . to show
    pure . makeHeader "/#blog" "Blog" mempty $ do
        extNav (stringValue $ show urlPortfolio') "Portfolio"
        pageBlog'
        dlNav (toValue atomXml') "Atom Feed"
        H.style . fromString $ styleToCss haddock
