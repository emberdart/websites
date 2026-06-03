{-# LANGUAGE DerivingVia       #-}
{-# LANGUAGE OverloadedLists   #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StrictData        #-}
{-# LANGUAGE TemplateHaskell   #-}

module Data.Env.Types where

import Control.Exception.AtomException
import Control.Lens
import Control.Monad.Error.Class
import Control.Monad.Reader
import Data.Function
import Data.List.NonEmpty     (NonEmpty)
import Data.List.NonEmpty     qualified as LNE
import Data.Set               (Set)
-- huh? NESet is not IsList? Well I suppose not... maybe there should be an IsNEList...
-- import Data.Set.NonEmpty     (NESet)
import Data.Text.NonEmpty              (NonEmptyText)
import Data.Time.Clock
import Html.Common.Blog.Types qualified as BlogTypes
import Network.URI
import Text.Blaze.Html5       (Html)
import Text.Email.Parser

data SiteType = Normal | Blog {
    _atomTitle    :: NonEmptyText,
    _atomUrl      :: URI,
    _renderSuffix :: BlogTypes.BlogMetadata → Html
}

makeLenses ''SiteType

data Urls = Urls {
    _urlPersonal      :: URI,
    _urlHamRadio     :: URI,
    _urlBlogHamRadio :: URI,
    _urlBlogPersonal         :: URI,
    _urlBlogTech  :: URI,
    _urlPortfolio      :: URI,
    _urlReviews    :: URI
}

makeLenses ''Urls

-- not a map because ordered
newtype Breadcrumb = Breadcrumb {
    getBreadcrumb :: NonEmpty (NonEmptyText, Maybe URI)
}

data OpenGraphProfile = OpenGraphProfile {
    _ogProfileFirstName :: NonEmptyText,
    _ogProfileLastName  :: NonEmptyText,
    _ogProfileUsername  :: NonEmptyText,
    _ogProfileGender    :: NonEmptyText
}

makeLenses ''OpenGraphProfile

data OpenGraphArticle = OpenGraphArticle {
    _ogArticlePublishedTime  :: UTCTime, -- ISO
    _ogArticleModifiedTime   :: Maybe UTCTime, -- ISO
    _ogArticleExpirationTime :: Maybe UTCTime, -- ISO
    _ogArticleAuthor         :: NonEmpty OpenGraphProfile,
    _ogArticleSection        :: NonEmptyText,
    _ogArticleTag            :: NonEmpty BlogTypes.BlogTag
}

makeLenses ''OpenGraphArticle

data OpenGraphInfo = OGWebsite | OGArticle OpenGraphArticle | OGProfile OpenGraphProfile

makeLenses ''OpenGraphInfo

data Website = Website {
    _slug          :: NonEmptyText,
    _redirectSlugs :: [NonEmptyText],
    _title         :: NonEmptyText,
    -- _keywords :: NESet NonEmptyText,
    _description   :: NonEmptyText,
    _previewImgUrl :: URI,
    _baseUrl       :: URI,
    _pageUrl       :: URI,
    _sitemapUrl    :: URI,
    _urls          :: Urls,
    _breadcrumb    :: Breadcrumb,
    _siteType      :: SiteType,
    _email         :: EmailAddress,
    _openGraphInfo :: OpenGraphInfo,
    _livereload    :: Bool,
    _build         :: forall m. (MonadError AtomException m, MonadReader Website m, MonadIO m) => m ()
}

makeLenses ''Website

-- TODO lens it?
plainBreadcrumb ∷ MonadReader Website m ⇒ NonEmptyText → m a → m a
plainBreadcrumb breadcrumb' = local (set breadcrumb (Breadcrumb [(breadcrumb', Nothing)]))

addBreadcrumb ∷ MonadReader Website m ⇒ NonEmptyText → m a → m a
addBreadcrumb breadcrumb' page = do
    breadcrumbExisting <- view breadcrumb
    baseUrl' <- view baseUrl
    let firstText = fst $ LNE.head (getBreadcrumb breadcrumbExisting)
    local (set breadcrumb (Breadcrumb [(firstText, Just baseUrl'), (breadcrumb', Nothing)])) page

-- todo "on"
instance Eq Website where
    (==) = (==) `on` view slug

instance Ord Website where
    compare = compare `on` view slug

type Env = Set Website
