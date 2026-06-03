{-# LANGUAGE OverloadedStrings #-}

module Html.Portfolio.Header where

import Control.Lens
import Control.Monad.Reader
import Data.Env.Types
import Html.Common.GitHub
import Html.Common.Header
import Html.Common.Page
import Html.Portfolio.Page.Contact
import Html.Portfolio.Page.FreeSoftware
import Html.Portfolio.Page.Portfolio
import Text.Blaze.Html5               as H hiding (main)

linkBlogTech ∷ (MonadReader Website m) ⇒ m Html
linkBlogTech = do
    urlBlogTech' <- view $ urls . urlBlogTech
    pure $ extNav (stringValue $ show urlBlogTech') "Blog"

-- Todo Technologies, Pricing, Blog, About
htmlHeader ∷ (MonadReader [Repo] n, MonadReader Website m) ⇒ n (m Html)
htmlHeader = do
    pageFs' <- pageFs
    pure $ do
        pagePortfolio' <- pagePortfolio
        pageContact' <- pageContact
        pageFs'' <- pageFs'
        linkBlogTech' <- linkBlogTech
        pure . makeHeader "" "" mempty $ do
            pagePortfolio'
            pageFs''
            linkBlogTech'
            pageContact'
