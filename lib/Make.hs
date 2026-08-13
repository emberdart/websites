{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Unsafe            #-}
{-# OPTIONS_GHC -Wno-unsafe #-}

module Make where

import Control.Exception
import Control.Monad
import Control.Monad.Error.Class
import Control.Monad.Logger
import Control.Monad.Reader
import Control.Lens
import Data.ByteString.Lazy.Char8         qualified as BSL
import Data.Env.Types
import Data.Foldable
import Data.List                     (sortOn)
import Data.List.NonEmpty            (NonEmpty)
import Data.List.NonEmpty            qualified as LNE
import Data.NonEmpty                 qualified as NE
import Data.Ord                      (Down (Down))
import Data.Text                     qualified as T
import Data.Text.IO                  qualified as TIO
import Distribution.Simple.Utils
import Distribution.Verbosity
-- import GHC.Stack
import Html.Common.Blog.Post
import Html.Common.Blog.Types
import Html.Common.Redirect
import System.Directory              (createDirectoryIfMissing, doesFileExist, getDirectoryContents)
import System.FilePath               (dropFileName, (</>))
-- import System.PathZ
import Test.WebDriver
import Test.WebDriver.Capabilities
import Test.WebDriver.WD
import Text.Blaze.Html5              as H
import Text.Blaze.Html.Renderer.Utf8 (renderHtml)
import Network.URI

mkdirp :: MonadIO m => FilePath -> m ()
mkdirp dir = liftIO $ createDirectoryIfMissing True dir

saveScreenshotIfNotExistsForOEmbed :: MonadIO m => URI -> FilePath -> m ()
saveScreenshotIfNotExistsForOEmbed uri toFile = do
  ssExists <- liftIO . doesFileExist $ toFile
  unless ssExists $ do
    mkdirp (dropFileName toFile)
    liftIO . putStrLn $ "Saving " <> show uri <> " to " <> toFile
    liftIO . bracket mkEmptyWebDriverContext (runStdoutLoggingT . teardownWebDriverContext) $ \ctx -> runStdoutLoggingT $ do
      session <- startSession ctx (DriverConfigGeckodriver {
        driverConfigGeckodriver = "geckodriver",
        driverConfigGeckodriverFlags = [],
        driverConfigGeckodriverExtraEnv = Nothing,
        driverConfigFirefox = "firefox",
        driverConfigLogDir = Nothing
      }) (defaultCaps {
          _capabilitiesMozFirefoxOptions = Just $ defaultFirefoxOptions {
              _firefoxOptionsArgs = Just [ "--headless" ]
          }
      }) "Firefox"
      runWD session $ do
        openPage (show uri)
        setWindowRect $ Rect 0 0 1200 630
        saveScreenshot toFile
      closeSession ctx session

make ∷ (MonadReader Website m, MonadIO m) => m Html → m Html → m ()
make page page404 = do
    ws <- ask
    let slug' = ws ^. slug
    let path' = T.unpack (NE.getNonEmpty slug')
    page' <- page
    page404' <- page404
    pageRedir <- pageRedirect "/"
    liftIO $ do
      installDirectoryContents silent "static/common" (".sites" </> path')
      installDirectoryContents silent ("static" </> path') (".sites" </> path')
      for_ (ws ^. redirectSlugs) $ \redirectSlug -> do
        liftIO . putStrLn $ "Redirection creating in " <> ".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug)
        -- let redirectDirname = ".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug)
        installDirectoryContents silent ("static" </> (T.unpack . NE.getNonEmpty $ redirectSlug)) (".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug))
        BSL.writeFile (".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug) </> "index.html") . renderHtml $ pageRedir
        BSL.writeFile (".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug) </> "404.html") . renderHtml $ pageRedir
      BSL.writeFile (".sites" </> path' </> "index.html") $ renderHtml page'
      BSL.writeFile (".sites" </> path' </> "404.html") $ renderHtml page404'
      TIO.putStrLn $ NE.getNonEmpty slug' <> " compiled."
      -- saveScreenshotIfNotExistsForOEmbed (ws ^. pageUrl </> path') (".sites" </> path' </> "img" </> path' </> "embed.png")

foldtraverse ∷ (Monoid b', Traversable t, Applicative f) ⇒ (a' → f b') → t a' → f b'
foldtraverse f xs = fold <$> traverse f xs

buildMD ∷ forall m. (MonadReader Website m, MonadIO m) ⇒ FilePath → m (NonEmpty BlogPost, Html)
buildMD postsDir = do
  files' <- liftIO $ getDirectoryContents postsDir
  let fileNames = (postsDir </>) <$> files' -- if used in same line, use Compose
  validFiles <- liftIO $ filterM doesFileExist fileNames
  -- move this modify UP!
  posts <- liftIO (traverse (modifyError (userError . show) . makeBlogPost postsDir) validFiles)
  let sortedPosts = sortOn (Down . date . metadata) . filter (not . draft . metadata) $ posts
  case LNE.nonEmpty sortedPosts of
    -- TODO throw here instead
    Nothing -> liftIO $ fail "No valid, non-draft posts. Oh dear."
    Just sortedPosts' -> do
      -- potentially we could do this afterwards?
      renderedPosts <- foldtraverse renderPost sortedPosts'
      pure (sortedPosts', renderedPosts)
