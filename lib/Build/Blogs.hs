{-# LANGUAGE OverloadedStrings #-}
-- {-# OPTIONS_GHC -Wno-incomplete-uni-patterns #-}

module Build.Blogs where

import Control.Exception.AtomException
import Control.Exception.Atom.MissingAtomURIException
import Control.Exception.Atom.CantGenerateFeedException
import Control.Lens
import Control.Monad                 (join)
import Control.Monad.Error.Class
import Control.Monad.IO.Class
import Control.Monad.Reader
import Data.ByteString.Char8         qualified as BS
import Data.ByteString.Lazy.Char8         qualified as BSL
import Data.Env.Types                as Env
import Data.Foldable
import Data.Foldable1
import Data.List.NonEmpty            (NonEmpty (..))
import Data.List.NonEmpty            qualified as LNE
-- import Data.Map                      (Map)
import Data.Map                      qualified as M
import Data.Map.NonEmpty             (NEMap)
import Data.Map.NonEmpty             qualified as MNE
import Data.Maybe
import Data.NonEmpty                 qualified as NE
-- import Data.Set                      (Set)
-- import Data.Set                      qualified as S
-- import Data.Set.NonEmpty                      (NESet)
import Data.Set.NonEmpty             qualified as SNE
import Data.Text                     qualified as T
import Data.Text.IO                  qualified as TIO
import Data.Time.Clock
import Data.Traversable
import GHC.Stack
import Html.Common.Blog.Feed
import Html.Common.Blog.Link
import Html.Common.Blog.Post
import Html.Common.Blog.Types        qualified as BlogTypes
import Html.Common.Redirect
import Make
import Network.URI
import System.Directory
import System.FilePath
import Text.Blaze.Html.Renderer.Utf8 (renderHtml)
import Text.Blaze.Html5              as H hiding (main, title)
import Web.Sitemap.Gen

-- go through and write in some way, so something to concat perhaps

-- urgh
groupByMany ∷ (Foldable1 f, Ord tag) ⇒ (post → f tag) → NonEmpty post → NEMap tag (NonEmpty post)
groupByMany postToTags posts = MNE.unsafeFromMap $
  foldr' (\post map'' ->
    foldr' (\tag map' ->
        M.insertWith (<>) tag (LNE.singleton post) map'
      )
      map''
      (postToTags post)
    )
    M.empty
    posts

{- Make a graph of connectivity.
  e.g. [[a, b, c, d], [b, c, e, g], [a, c, e]] ->
      {
        a: { b: 1, c: 2, d: 1, e: 1 },
        b: { a: 1, c: 2, d: 1, e: 1, g: 1 },
        c: { a: 2, b: 2, d: 1, e: 2, g: 1 },
        d: { a: 1, b: 1, c: 1 },
        e: { a: 1, b: 1, c: 2, g: 1},
        g: { b: 1, c: 1, e: 1 }
      }
  then you rabot (filter) for x>1
      {
        a: { c: 2 },
        b: { c: 2 },
        c: { a: 2, b: 2, e: 2 },
        e: { c: 2 },
      }
  Then you can see clearly that since everything = 2, a, b and e are pretty obvious subsets of c!
-}

{-
filterGraph :: (v -> Bool) -> M.Map k (M.Map k v) -> M.Map k (M.Map k v)
filterGraph pred map = undefined

-- Doesn't necessarily lead to any commonalities so we can't return NEMap
filterNEGraph :: (v -> Bool) -> MNE.NEMap k (MNE.NEMap k v) -> M.Map k (M.Map a v)
filterNEGraph pred map = undefined

connectivity :: Foldable t => t (t a) -> M.Map a (M.Map a Int)
connectivity xss = undefined

connectivityNE :: Foldable t => t (t a) -> MNE.NEMap a (MNE.NEMap a Int)
connectivityNE xss = MNE.unsafeFromMap $ foldr' (
    \tagsForOnePost mapSoFar -> 
      -- Now for each of the tags, we must add it to the map if it's not there as empty...
      -- and also add all the tags used in this post to the set under each.
      undefined {-}
      foldr' (
          \tag setSoFar -> undefined
      )-}
  ) M.empty xss
-}

build ∷ (HasCallStack, MonadReader Website m, MonadError AtomException m, MonadIO m) ⇒ (Html → Html → Html → m Html) → m Html → m ()
build page page404 = do
  ws <- ask
  baseUrl' <- view baseUrl
  title' <- view Env.title
  slug' <- view slug
  mAtomUri' <- preview $ siteType . atomUrl
  sitemapUrl' <- view sitemapUrl
  atomUri' <- case mAtomUri' of
      Just x  -> pure x
      Nothing -> throwError . AtomMissingAtomURIException $ MissingAtomURIException -- no Monoid for URI -- is that right?
  -- atomTitle' <- view $ siteType . atomTitle
  -- Clear us out, Jim
  let siteDir = ".sites" </> T.unpack (NE.getNonEmpty slug') <> "/"
  traverse_ (liftIO . removePathForcibly . (siteDir <>)) [
    "post",
    "tag"
    ]
  (sortedPosts, renderedPosts) <- buildMD ("posts" </> T.unpack (NE.getNonEmpty slug'))
  -- By tag
  let grouped = groupByMany (SNE.fromList . BlogTypes.tags . BlogTypes.metadata) sortedPosts :: NEMap BlogTypes.BlogTag (NonEmpty BlogTypes.BlogPost)
  let tags = MNE.keys grouped

  -- Also find commonalities between tags
  let _tagsGroupedByPost :: NonEmpty (NonEmpty BlogTypes.BlogTag) = fmap (BlogTypes.tags . BlogTypes.metadata) sortedPosts

  -- For implication, add every tag in the sub list to a new map where it adds one each time it sees everything
  -- much like frequency, but for frequency "per" tag shared
  -- then throw away the hardly shared ones!

  -- let implicator :: NEMap BlogTypes.BlogTag (NEMap BlogTypes.BlogTag Int) = MNE.unsafeFromMap . foldr' (
  --         \tag map' -> M.insertWith (\new old -> M.insertWith (\))
  --       ) M.empty

  -- let freqsOf :: NonEmpty BlogTypes.BlogTag -> NEMap BlogTypes.BlogTag Int = MNE.unsafeFromMap . foldr' (
  --         \tag map' -> M.insertWith (+) tag 1 map'
  --       ) M.empty
-- 
  -- -- Find the frequency of each tag so we can link it in, and sort by frequency, then implication.
  -- let frequency :: MNE.NEMap BlogTypes.BlogTag Int = freqsOf $ join tagsGroupedByPost
-- 
  -- let freqsSorted :: [(BlogTypes.BlogTag, Int)] = LNE.filter ((> 1) . snd) . LNE.reverse . LNE.sortOn snd $ MNE.toList frequency

  -- liftIO $ print freqsSorted

  -- Highest freqs



  -- go through each post and add a tag for each other tag. If there are more than one tag for another tag this means something.
  -- Probably means implication if x<y, equality if x = y, reverse implication if x>y.

  -- let _commonalities :: MNE.NEMap BlogTypes.BlogTag (MNE.NEMap BlogTypes.BlogTag Int) = undefined
  
  -- pretty sus of this
  tagUrlDates <- MNE.elems <$> MNE.traverseWithKey (\tag posts -> do
    -- Okay LNE.filter does not have this guarantee - anything else?
    postsRendered <- foldtraverse renderPost posts
    -- TODO: lowercase earlier?

    let relTagUri = fromJust . parseRelativeReference $ "/tag" </> escapeURIString isUnescapedInURIComponent (T.unpack (NE.getNonEmpty (BlogTypes.getTag tag)))
    let relAtomUri = fromJust . parseRelativeReference $ "/atom.xml"
    let tagUri' = relTagUri `relativeTo` baseUrl'
    let tagAtomUri' = relAtomUri `relativeTo` tagUri'

    -- TODO nonempty th?
    let atomDesc = NE.trustedNonEmpty "Posts tagged with " <> BlogTypes.getTag tag
    let atomPrefix = atomDesc <> NE.trustedNonEmpty ": "
    let atomPrefixer = (atomPrefix <>)
    let fullAtomTitle' = atomPrefixer title'

    let atomTagFilename = "tag" </> T.unpack (NE.getNonEmpty (BlogTypes.getTag tag)) </> "atom.xml"
    let fullAtomTagFilename = ".sites" </> T.unpack (NE.getNonEmpty slug') </> atomTagFilename
    let tagFilename = "tag" </> T.unpack (NE.getNonEmpty (BlogTypes.getTag tag)) </> "index.html"
    let fullTagFilename = siteDir <> tagFilename
    let dirname = dropFileName fullTagFilename

    pageTag <- locally title atomPrefixer .
      locally (siteType . atomTitle) atomPrefixer .
      local (set (siteType . atomUrl) tagAtomUri') .
      addBreadcrumb atomDesc $
      page (makeLinks Nothing (NE.trustedNonEmpty "#") atomDesc posts) (makeTags (Just tag) tags) postsRendered --  (("Posts tagged with " <> BlogTypes.getTag tag <> ": ") <>)

    mkdirp dirname

    liftIO . BS.writeFile fullTagFilename . BS.toStrict . renderHtml $ pageTag
    
    -- TODO redirect here
    for_ (ws ^. redirectSlugs) $ \redirectSlug -> do
      let fullRedirectFilename = ".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug) </> tagFilename
      let redirectDirname = dropFileName fullRedirectFilename
      mkdirp redirectDirname
      pageRedir <- pageRedirect tagFilename
      liftIO . BSL.writeFile fullRedirectFilename . renderHtml $ pageRedir

    let mRssFeed = makeRSSFeed tagAtomUri' tagUri' baseUrl' fullAtomTitle' posts

    -- unless mRssFeed $ 
    case mRssFeed of
      Just rssFeed -> do
        liftIO . TIO.writeFile fullAtomTagFilename . NE.getNonEmpty $ rssFeed
        for_ (ws ^. redirectSlugs) (\redirectSlug -> do
          let fullRedirectAtomFilename = ".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug) </> atomTagFilename
          let fullRedirectAtomDirname = dropFileName fullRedirectAtomFilename
          mkdirp fullRedirectAtomDirname
          -- pageRedir <- pageRedirect tagFilename
          liftIO . TIO.writeFile fullRedirectAtomFilename . NE.getNonEmpty $ rssFeed
          )
      Nothing -> throwError . AtomCantGenerateFeedException $ CantGenerateFeedException {
        excAtomXml = tagAtomUri',
        excSelfUrl = tagUri',
        excDomain = baseUrl',
        excTitle = fullAtomTitle'
      }
    -- liftIO . TIO.putStrLn $ "/tag" </> BlogTypes.getTag tag
    -- traverse_ (liftIO . TIO.putStrLn . BlogTypes.title . BlogTypes.metadata) posts
    pure (
      tagUri',
      (BlogTypes.date . BlogTypes.metadata) (LNE.head posts)
      )
    ) grouped
  -- By post
  urlDatePairsFromPages <- fmap join . for sortedPosts $ \post -> do
    let aliases' = BlogTypes.aliases . BlogTypes.metadata $ post
    for aliases' $ \alias -> do
      let filename = "post" <> alias </> "index.html"
      let fullFilename = siteDir </> filename
      let dirname = dropFileName fullFilename
      let aliasSuffix = fromJust . parseRelativeReference $ alias
      let aliasUrl = aliasSuffix `relativeTo` baseUrl'
      let postTitle = BlogTypes.title . BlogTypes.metadata $ post
      let postTitlePrefix = postTitle <> NE.trustedNonEmpty ": "
      let postTitlePrefixer = (postTitlePrefix <>)

      mkdirp dirname
      renderedPost <- renderPost post
      pageBlogPost <- locally title postTitlePrefixer .
        local (set openGraphInfo (OGArticle $ OpenGraphArticle {
            _ogArticlePublishedTime = BlogTypes.date . BlogTypes.metadata $ post,
            _ogArticleModifiedTime = Just . BlogTypes.date . BlogTypes.metadata $ post,
            _ogArticleExpirationTime = Nothing,
            _ogArticleAuthor =
              OpenGraphProfile {
                _ogProfileFirstName = NE.trustedNonEmpty "Ember",
                _ogProfileLastName = NE.trustedNonEmpty "Dart",
                _ogProfileUsername = NE.trustedNonEmpty "emberdart",
                _ogProfileGender = NE.trustedNonEmpty "trans female"
              } :| [],
            _ogArticleSection = NE.trustedNonEmpty "Blog post",
            _ogArticleTag = BlogTypes.tags . BlogTypes.metadata $ post
        })) .
        local (\w -> w {
          -- we don't override rss title, only page title, this is why they're separate
          _previewImgUrl = fromMaybe (w ^. previewImgUrl) (BlogTypes.featuredImage . BlogTypes.metadata $ post)
        }) . addBreadcrumb (BlogTypes.title . BlogTypes.metadata $ post) $
        page (makeLinks (Just . BlogTypes.postId $ post) (NE.trustedNonEmpty "/#") (NE.trustedNonEmpty "All Posts") sortedPosts) (makeTags Nothing tags) renderedPost
      liftIO . BS.writeFile fullFilename . BS.toStrict . renderHtml $ pageBlogPost

      for_ (ws ^. redirectSlugs) $ \redirectSlug -> do
        let redirectFilename = ".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug) </> filename
        let redirectDirname = dropFileName redirectFilename
        mkdirp redirectDirname
        pageRedir <- pageRedirect filename
        liftIO . BSL.writeFile redirectFilename . renderHtml $ pageRedir
      pure (
        aliasUrl,
        BlogTypes.date . BlogTypes.metadata $ post
        )
  now <- liftIO getCurrentTime
  let sitemap' = Sitemap $ [
        SitemapUrl (T.show baseUrl') (Just now) (Just Weekly) (Just 1.0)
        ] <> fmap (\(url, date) -> SitemapUrl (T.show url) (Just date) (Just Never) (Just 1.0)) (LNE.toList urlDatePairsFromPages)
          <> fmap (\(url, date) -> SitemapUrl (T.show url) (Just date) (Just Weekly) (Just 2.0)) (LNE.toList tagUrlDates)
  liftIO . putStrLn $ "Saving sitemap to " <> siteDir <> "/sitemap.xml"
  liftIO . BS.writeFile (siteDir </> "sitemap.xml") $ renderSitemap sitemap'

  for_ (ws ^. redirectSlugs) $ \redirectSlug -> do
    liftIO . BSL.writeFile (".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug) </> "sitemap.xml") $ renderSitemap sitemap'
  
  case makeRSSFeed atomUri' baseUrl' baseUrl' title' sortedPosts of
    Just rssFeed' -> do
      liftIO . TIO.writeFile (siteDir <> "atom.xml") . NE.getNonEmpty $ rssFeed'

      for_ (ws ^. redirectSlugs) $ \redirectSlug -> do
        liftIO . TIO.writeFile (".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug) </> "atom.xml") . NE.getNonEmpty $ rssFeed'

    Nothing -> throwError . AtomCantGenerateFeedException $ CantGenerateFeedException {
      excAtomXml = atomUri',
      excSelfUrl = baseUrl',
      excDomain = baseUrl',
      excTitle = title'
    }
    
  liftIO . BS.writeFile (siteDir <> "/robots.txt") $
    "User-agent: *\nAllow: /\nSitemap: " <> BS.pack (show sitemapUrl') <> "\nContent-Signal: ai-train=no, search=yes, ai-input=no"
  
  for_ (ws ^. redirectSlugs) $ \redirectSlug -> do
    liftIO . BS.writeFile (".sites" </> (T.unpack . NE.getNonEmpty $ redirectSlug) <> "/robots.txt") $
      "User-agent: *\nAllow: /\nSitemap: " <> BS.pack (show sitemapUrl') <> "\nContent-Signal: ai-train=no, search=yes, ai-input=no"
    
  make (page (makeLinks Nothing (NE.trustedNonEmpty "#") (NE.trustedNonEmpty "All Posts") sortedPosts) (makeTags Nothing tags) renderedPosts) page404
