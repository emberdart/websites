{-# LANGUAGE OverloadedStrings #-}

module Html.Personal.Page.Intro where

import Control.Monad.Reader
import Data.Env.Types
import Data.NonEmpty               qualified as NE
import Html.Common.Link
import Html.Common.Page
import Text.Blaze.Html5     as H hiding (main)
-- import Text.Blaze.Html5.Attributes as A

pageIntro ∷ (MonadReader Website m) ⇒ m Html
pageIntro = plainBreadcrumb (NE.trustedNonEmpty "Intro") . makePage "intro" "Intro" defaultLayout defaultPage $ do
    p "Hello, my name is Ember."
    p "I am a software engineer, mathematics lover, radio ham and musician."
    p $ do
        "I work remotely in Exeter, with fond love for my late partner, "
        extLink "https://yanderedarling.com/" "Raven"
        "."
    p "I also enjoy discordant and nonsensical commentary."
    p "I can speak about maths, physics, computer science and linguistics at length."
    p "You can find out more by using the links at the top."
    br
    {-
    p $ do
        extLink "https://html.spec.whatwg.org/" $ img ! A.style "height: 16px" ! src "https://upload.wikimedia.org/wikipedia/commons/a/a1/WHATWG_logo.svg"
        extLink "/humans.txt" $ img ! src "/img/humanstxt-isolated-blank.gif"
    -}
