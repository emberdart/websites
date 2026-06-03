{-# LANGUAGE OverloadedStrings #-}

module Build.Normal where

import Build.Sitemap
import Control.Lens
import Control.Monad.IO.Class
import Control.Monad.Reader
import Data.ByteString.Char8  qualified as BS
import Data.Env.Types         as Env
import Data.Foldable
import Data.NonEmpty          qualified as NE
import Data.Text              qualified as T
-- import GHC.Stack
import Make
import System.FilePath
import Text.Blaze.Html5       as H hiding (main)
import Web.Sitemap.Gen

build ∷ (MonadReader Website m, MonadIO m) ⇒ m Html → m Html → m ()
build page page404 = do
    slug' <- view slug
    sitemapUrl' <- view sitemapUrl
    sitemap' <- sitemap
    ws <- ask
    liftIO . BS.writeFile (".sites/" <> T.unpack (NE.getNonEmpty slug') <> "/sitemap.xml") $ renderSitemap sitemap'

    for_ (ws ^. redirectSlugs) $ \redirectSlug -> do
        liftIO . putStrLn $ "Creating .sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug)
        mkdirp $ ".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug)
        liftIO . BS.writeFile (".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug) </> "sitemap.xml") $ renderSitemap sitemap'
        liftIO . BS.writeFile (".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug) </> "robots.txt") $ "User-agent: *\nAllow: /\nSitemap: " <> BS.pack (show sitemapUrl') <> "\nContent-Signal: ai-train=no, search=yes, ai-input=no"

        liftIO . BS.writeFile (".sites" </> T.unpack (NE.getNonEmpty slug') </> "sitemap.xml") $ renderSitemap sitemap'
    liftIO . BS.writeFile (".sites" </> T.unpack (NE.getNonEmpty slug') </> "robots.txt") $ "User-agent: *\nAllow: /\nSitemap: " <> BS.pack (show sitemapUrl') <> "\nContent-Signal: ai-train=no, search=yes, ai-input=no"
    make page page404
