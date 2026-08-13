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
import Network.URI.Lens
import System.FilePath
import Text.Blaze.Html5       as H hiding (main)
import Web.Sitemap.Gen

build ∷ (MonadReader Website m, MonadIO m) ⇒ m Html → m Html → m ()
build page page404 = do
    slug' <- view slug
    let slugDirname = T.unpack (NE.getNonEmpty slug')
    let siteDir = ".sites" </> slugDirname
    sitemapUrl' <- view sitemapUrl
    sitemap' <- sitemap
    ws <- ask
    liftIO . BS.writeFile (siteDir </> "sitemap.xml") $ renderSitemap sitemap'

    for_ (ws ^. redirectSlugs) $ \redirectSlug -> do
        let redirectSlugDirname = T.unpack . NE.getNonEmpty $ redirectSlug
        let redirectSlugDir = ".sites" </> redirectSlugDirname
        liftIO . putStrLn $ "Creating " <> redirectSlugDir
        mkdirp redirectSlugDir
        liftIO . BS.writeFile (redirectSlugDir </> "sitemap.xml") $ renderSitemap sitemap'
        liftIO . BS.writeFile (redirectSlugDir </> "robots.txt") $ "User-agent: *\nAllow: /\nSitemap: " <> BS.pack (show sitemapUrl') <> "\nContent-Signal: ai-train=no, search=yes, ai-input=no"

    liftIO . BS.writeFile (siteDir </> "sitemap.xml") $ renderSitemap sitemap'
    liftIO . BS.writeFile (siteDir </> "robots.txt") $ "User-agent: *\nAllow: /\nSitemap: " <> BS.pack (show sitemapUrl') <> "\nContent-Signal: ai-train=no, search=yes, ai-input=no"
    make page page404
    -- could probably be a modify or whatever
    saveScreenshotIfNotExistsForOEmbed (over (uriAuthorityLens . mapped . uriRegNameLens) ("dev." <>) (ws ^. pageUrl)) (siteDir </> "img" </> "embed.png")
    