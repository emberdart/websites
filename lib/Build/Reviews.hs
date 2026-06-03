module Build.Reviews where

import Build.Blogs          qualified as Blogs
import Control.Exception.AtomException
import Control.Monad.Error.Class
import Control.Monad.Reader
import Data.Env.Types
import Html.Reviews.Index

build ∷ (MonadReader Website m, MonadError AtomException m, MonadIO m) ⇒ m ()
build = Blogs.build page page404
