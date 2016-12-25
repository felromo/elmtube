module MyCss exposing (CssClasses(..), CssIds(..), css)

import Css exposing (..)
import Css.Elements exposing (html, body, li)
import Css.Namespace exposing (namespace)


type CssClasses
    = NavBar


type CssIds
    = Wrap
    | Header
    | Nav
    | Main
    | SideBar
    | Footer


css : Stylesheet
css =
    (stylesheet << namespace "base")
        [ body
            [ backgroundColor (hex "a7a09a")
            , margin zero
            , padding zero
            , color (hex "000")
            ]
        , html
            [ backgroundColor (hex "a7a09a")
            , margin zero
            , padding zero
            , color (hex "000")
            ]
        , (#) Wrap
            [ width (px 750)
            , marginLeft zero
            , marginRight zero
            , marginTop auto
            , marginBottom auto
            , backgroundColor (hex "99c")
            ]
        , (#) Header
            [ backgroundColor (hex "ddd") ]
        , (#) Nav
            [ backgroundColor (hex "c99") ]
        , (#) Main
            [ backgroundColor (hex "9c9")
            , float left
            , width (px 500)
            ]
        , (#) SideBar
            [ backgroundColor (hex "c9c")
            , float right
            , width (px 250)
            ]
        , (#) Footer
            [ property "clear" "both"
            , backgroundColor (hex "cc9")
            ]
        ]
