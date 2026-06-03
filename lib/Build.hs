module Build where

import Control.Exception
import Control.Exception.AtomException
import Control.Lens
import Control.Monad.Error.Class
import Control.Monad.IO.Class
import Control.Monad.Reader
import Data.Env               as Env
import Data.Env.Types         as Env
import Data.Foldable

build ∷ (MonadReader Env m, MonadError AtomException m, MonadIO m) ⇒ m ()
build = ask >>= traverse_ (\website -> runReaderT (website ^. Env.build) website)

runBuild ∷ IO ()
runBuild = runReaderT (modifyError (userError . show) Build.build) production
    `catches` [
        Handler (\(ex :: AtomException) -> do
            putStrLn $ "Caught atom exception " <> displayException ex
            ),
        Handler (\(ex :: IOException) -> do
        putStrLn $ "Caught IO exception " <> displayException ex
            ),
        Handler (\(SomeException ex) -> do
        putStrLn $ "Caught exception " <> displayException ex
            )
        ]