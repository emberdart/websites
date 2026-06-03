{-# LANGUAGE OverloadedStrings #-}

module Html.Common.Redirect where

import Control.Lens
import Control.Monad.Reader
import Data.Env.Types
-- import Data.NonEmpty                 qualified as NE
-- import Data.Text                     qualified as T
import Text.Blaze.Html5.Attributes              as A
import Text.Blaze.Html5              as H

pageRedirect :: MonadReader Website m => FilePath -> m Html
pageRedirect path' = do
    ws <- ask
    let pageUrl' = ws ^. pageUrl
    pure . H.docTypeHtml .
        H.html $ do
            H.meta ! httpEquiv "refresh" ! content ("1;URL=" <> stringValue (show pageUrl' <> "/" <> path'))
            H.h1 $ text "Moved"
            H.p $ do
                text "This page has moved. It can be found at "
                H.a ! A.href (toValue $ (show pageUrl' <> "/" <> path')) $ do
                    string $ (show pageUrl' <> "/" <> path')
                text ". Please update your bookmarks. You are being redirected now."
