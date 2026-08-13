{-# LANGUAGE DerivingVia       #-}
{-# LANGUAGE OverloadedLists   #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE StrictData        #-}

module Data.Env where

import Build.BlogPersonal                qualified as Blog
import Build.BlogTech         qualified as BlogTech
import Build.BlogHamRadio           qualified as BlogHamRadio
import Build.Personal             qualified as Personal
import Build.Portfolio             qualified as Portfolio
import Build.HamRadio               qualified as HamRadio
import Build.Reviews           qualified as Reviews
import Control.Lens
import Data.Env.Types
import Data.NonEmpty             qualified as NE
import Html.Reviews.Suffix
import Network.URI.Static
import Text.Email.QuasiQuotation qualified as QE

productionUrls ∷ Urls
productionUrls = Urls {
    _urlPersonal = [uri|https://emberdart.co.uk|],
    _urlHamRadio = [uri|https://m0ori.com|],
    _urlBlogHamRadio = [uri|https://blog.m0ori.com|],
    _urlBlogPersonal = [uri|https://blog.emberdart.co.uk|],
    _urlBlogTech = [uri|https://blog.jolharg.com|],
    _urlPortfolio = [uri|https://jolharg.com|],
    _urlReviews = [uri|https://madhackerreviews.com|]
}

prodBlogPersonal,
    prodPersonal,
    prodPortfolio,
    prodBlogTech,
    prodHamRadio,
    prodBlogHamRadio,
    prodReviews ∷ Website
prodBlogPersonal = Website {
    _slug = NE.trustedNonEmpty "blogpersonal",
    _redirectSlugs = [NE.trustedNonEmpty "blogdead"],
    _title = NE.trustedNonEmpty "Ember Dart's Blog: Software, Mathematics, Ham Radio, Music",
    {- _keywords = [
        "ember",
        "dart",
        "emberdart",
        "ember dart",
        "exeter",
        "devon",
        "england",
        "united kingdom",
        "uk",
        "en_GB",
        "gb",
        "Great Britain",
        "Britain",
        "blog",
        "software",
        "engineer",
        "mathematics",
        "lover",
        "radio",
        "ham",
        "haskell",
        "typescript",
        "react.js",
        "react",
        "php",
        "javascript",
        "css",
        "coffee",
        "coffeescript",
        "laravel",
        "zend",
        "framework",
        "linux",
        "gnu",
        "express.js",
        "ubuntu",
        "debian"
        ],-}
    _description = NE.trustedNonEmpty "The blog of Ember Dart. Includes life-changing observations and scientific breakthroughs, as well as interesting content from around the world.",
    _previewImgUrl = [relativeReference|/img/embed.png|],
    _baseUrl = productionUrls ^. urlBlogPersonal,
    _pageUrl = productionUrls ^. urlBlogPersonal,
    _sitemapUrl = [relativeReference|/sitemap.xml|],
    _urls = productionUrls,
    _breadcrumb = Breadcrumb [(NE.trustedNonEmpty "Blog", Nothing)],
    _siteType = Blog {
        _atomTitle = NE.trustedNonEmpty "Ember Dart's Blog: Software, Maths, Ham Radio, Music",
        _atomUrl = [relativeReference|/atom.xml|],
        _renderSuffix = mempty
    },
    _email = [QE.email|blog@emberdart.co.uk|],
    _openGraphInfo = OGWebsite,
    _livereload = False,
    _build = Blog.build
}
prodPersonal = Website {
    _slug = NE.trustedNonEmpty "personal",
    _redirectSlugs = [NE.trustedNonEmpty "deadsite"],
    _title = NE.trustedNonEmpty "Ember Dart: Software, Maths, Ham Radio, Music",
    {- _keywords = [
        "ember",
        "dart",
        "emberdart",
        "ember dart",
        "exeter",
        "devon",
        "england",
        "united kingdom",
        "uk",
        "en_GB",
        "gb",
        "Great Britain",
        "Britain",
        "software",
        "engineer",
        "mathematics",
        "lover",
        "radio",
        "ham",
        "haskell",
        "typescript",
        "react.js",
        "react",
        "php",
        "javascript",
        "css",
        "coffee",
        "coffeescript",
        "laravel",
        "zend",
        "framework",
        "linux",
        "gnu",
        "express.js",
        "ubuntu",
        "debian"
        ],
    -}
    _description = NE.trustedNonEmpty "Ember Dart works on a large collection of software and is interested in mathematics, physics, chemistry, radio and linguistics.",
    _previewImgUrl = [relativeReference|/img/embed.png|],
    _baseUrl = productionUrls ^. urlPersonal,
    _pageUrl = productionUrls ^. urlPersonal,
    _sitemapUrl = [relativeReference|/sitemap.xml|],
    _urls = productionUrls,
    _breadcrumb = Breadcrumb [(NE.trustedNonEmpty "Ember Dart", Nothing)],
    _siteType = Normal,
    _email = [QE.email|website@emberdart.co.uk|],
    _openGraphInfo = OGProfile $ OpenGraphProfile {
        _ogProfileFirstName = NE.trustedNonEmpty "Ember",
        _ogProfileLastName = NE.trustedNonEmpty "Dart",
        _ogProfileUsername = NE.trustedNonEmpty "emberdart",
        _ogProfileGender = NE.trustedNonEmpty "trans female"
    },
    _livereload = False,
    _build = Personal.build
}
prodPortfolio = Website {
    _slug = NE.trustedNonEmpty "portfolio",
    _redirectSlugs = [],
    _title = NE.trustedNonEmpty "JolHarg: Your Software Engineering Partner",
    {- _keywords = [
        "jolharg",
        "ember",
        "dart",
        "emberdart",
        "ember dart",
        "exeter",
        "devon",
        "england",
        "united kingdom",
        "uk",
        "en_GB",
        "gb",
        "Great Britain",
        "Britain",
        "software",
        "dart",
        "software",
        "engineer",
        "mathematics",
        "haskell",
        "php",
        "javascript",
        "react",
        "react.js",
        "hoogle",
        "help",
        "computing",
        "computer",
        "serverless",
        "npm",
        "hask",
        "ask",
        "question",
        "haskell",
        "typescript",
        "react.js",
        "react",
        "css",
        "coffee",
        "coffeescript",
        "laravel",
        "zend",
        "framework",
        "linux",
        "gnu",
        "express.js",
        "ubuntu",
        "debian"
        ], -}
    _description = NE.trustedNonEmpty "Ember Dart can provide you with all kinds of software engineering including fully-functioning web and phone applications.",
    _previewImgUrl = [relativeReference|/img/embed.png|],
    _baseUrl = productionUrls ^. urlPortfolio,
    _pageUrl = productionUrls ^. urlPortfolio,
    _sitemapUrl = [relativeReference|/sitemap.xml|],
    _urls = productionUrls,
    _breadcrumb = Breadcrumb [(NE.trustedNonEmpty "Portfolio", Nothing)],
    _siteType = Normal,
    _email = [QE.email|website@jolharg.com|],
    _openGraphInfo = OGWebsite,
    _livereload = False,
    _build = Portfolio.build
}
prodBlogTech = Website {
    _slug = NE.trustedNonEmpty "blogtech",
    _redirectSlugs = [],
    _title = NE.trustedNonEmpty "JolHarg: Software and Technology Blog",
    {- _keywords = [
        "jolharg",
        "blog",
        "ember",
        "dart",
        "emberdart",
        "ember dart",
        "exeter",
        "devon",
        "england",
        "united kingdom",
        "uk",
        "en_GB",
        "gb",
        "Great Britain",
        "Britain",
        "software",
        "engineer",
        "mathematics",
        "lover",
        "radio",
        "ham",
        "haskell",
        "typescript",
        "react.js",
        "react",
        "php",
        "javascript",
        "css",
        "coffee",
        "coffeescript",
        "laravel",
        "zend",
        "framework",
        "linux",
        "gnu",
        "express.js",
        "ubuntu",
        "debian"
        ], -}
    _description = NE.trustedNonEmpty "JolHarg's blog covers various pieces of technology, code and tutorials to help make your life easier.",
    _previewImgUrl = [relativeReference|/img/embed.png|],
    _baseUrl = productionUrls ^. urlBlogTech,
    _pageUrl = productionUrls ^. urlBlogTech,
    _sitemapUrl = [relativeReference|/sitemap.xml|],
    _urls = productionUrls,
    _breadcrumb = Breadcrumb [(NE.trustedNonEmpty "JolHarg Blog", Nothing)],
    _siteType = Blog {
        _atomTitle = NE.trustedNonEmpty "JolHarg: Software and Technology Blog",
        _atomUrl = [relativeReference|/atom.xml|],
        _renderSuffix = mempty
    },
    _email = [QE.email|blog@jolharg.com|],
    _openGraphInfo = OGWebsite,
    _livereload = False,
    _build = BlogTech.build
}
prodHamRadio = Website {
    _slug = NE.trustedNonEmpty "hamradio",
    _redirectSlugs = [],
    _title = NE.trustedNonEmpty "M0ORI call sign: Ember Dart, England",
    {- _keywords = [
        "ember",
        "dart",
        "emberdart",
        "ember dart",
        "exeter",
        "devon",
        "england",
        "united kingdom",
        "uk",
        "en_GB",
        "gb",
        "Great Britain",
        "Britain",
        "haskell",
        "typescript",
        "react.js",
        "react",
        "radio",
        "call",
        "sign",
        "ham",
        "m0ori",
        "yaesu",
        "qrz"
        ]
    -}
    _description = NE.trustedNonEmpty "The M0ORI callsign is owned by Ember Dart located in England. She works on HF and VHF in Exeter.",
    _previewImgUrl = [relativeReference|/img/embed.png|],
    _baseUrl = productionUrls ^. urlHamRadio,
    _pageUrl = productionUrls ^. urlHamRadio,
    _sitemapUrl = [relativeReference|/sitemap.xml|],
    _urls = productionUrls,
    _breadcrumb = Breadcrumb [(NE.trustedNonEmpty "M0ORI", Nothing)],
    _siteType = Normal,
    _email = [QE.email|website@m0ori.com|],
    _openGraphInfo = OGWebsite,
    _livereload = False,
    _build = HamRadio.build
}
prodBlogHamRadio = Website {
    _slug = NE.trustedNonEmpty "bloghamradio",
    _redirectSlugs = [],
    _title = NE.trustedNonEmpty "The Blog of M0ORI: Interesting Ham Radio Observations",
    _description = NE.trustedNonEmpty "My radio blog covers interesting observations I have had whilst working on ham bands.",
    _previewImgUrl = [relativeReference|/img/embed.png|],
    _baseUrl = productionUrls ^. urlBlogHamRadio,
    _pageUrl = productionUrls ^. urlBlogHamRadio,
    _sitemapUrl = [relativeReference|/sitemap.xml|],
    _urls = productionUrls,
    _breadcrumb = Breadcrumb [(NE.trustedNonEmpty "M0ORI Blog", Nothing)],
    _siteType = Blog {
        _atomTitle = NE.trustedNonEmpty "The Blog of M0ORI: Interesting Ham Radio Observations",
        _atomUrl = [relativeReference|/atom.xml|],
        _renderSuffix = mempty
    },
    _email = [QE.email|blog@m0ori.com|],
    _openGraphInfo = OGWebsite,
    _livereload = False,
    _build = BlogHamRadio.build
}
prodReviews = Website {
    _slug = NE.trustedNonEmpty "reviews",
    _redirectSlugs = [],
    _title = NE.trustedNonEmpty "The Mad Hacker: Tech Reviews by a crazy computer enthusiast",
    {- _keywords = [
        "exeter",
        "devon",
        "england",
        "united kingdom",
        "uk",
        "en_GB",
        "gb",
        "Great Britain",
        "Britain",
        "mad",
        "hacker",
        "tech",
        "technology",
        "reviews",
        "review",
        "ember",
        "dart",
        "emberdart",
        "ember dart",
        "haskell",
        "typescript",
        "react.js",
        "react"
        ]
    -}
    _description = NE.trustedNonEmpty "Find tech and software reviews with a hackability twist, right here! Requests are accepted and review models are always non-sponsored.",
    _previewImgUrl = [relativeReference|/img/embed.png|],
    _baseUrl = productionUrls ^. urlReviews,
    _pageUrl = productionUrls ^. urlReviews,
    _sitemapUrl = [relativeReference|/sitemap.xml|],
    _urls = productionUrls,
    _breadcrumb = Breadcrumb [(NE.trustedNonEmpty "Mad Hacker Reviews", Nothing)],
    _siteType = Blog {
        _atomTitle = NE.trustedNonEmpty "The Mad Hacker: Tech Reviews by a crazy computer enthusiast",
        _atomUrl = [relativeReference|/atom.xml|],
        _renderSuffix = renderStars
    },
    _email = [QE.email|madhacker@emberdart.co.uk|], -- TODO add MX
    _openGraphInfo = OGWebsite,
    _livereload = False,
    _build = Reviews.build
}

production ∷ Env
production = [
    prodBlogPersonal,
    prodPersonal,
    prodPortfolio,
    prodBlogTech,
    prodBlogHamRadio,
    prodHamRadio,
    prodReviews
    ]
