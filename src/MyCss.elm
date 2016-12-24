module MyCss exposing (CssClasses(..), CssIds(..), css)

import Css exposing (..)
import Css.Elements exposing (body, li)
import Css.Namespace exposing (namespace)


type CssClasses
    = NavBar


type CssIds
    = Page


css : Stylesheet
css =
    (stylesheet << namespace "base")
        [ body
            [ backgroundColor (hex "a8a2a2") ]
        ]
