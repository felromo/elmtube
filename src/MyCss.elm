module MyCss exposing (CssClasses(..), CssIds(..), css)

import Css exposing (..)
import Css.Elements exposing (html, body, li)
import Css.Namespace exposing (namespace)


type CssClasses
    = NavBar
    | ActiveVideo
    | VideoFrame


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
            [ width (vw 100)
            , marginLeft zero
            , marginRight zero
            , marginTop auto
            , marginBottom auto
            , backgroundColor (hex "99c")
            ]
        , (#) Header
            [ backgroundColor (hex "ddd")
            , textAlign center
            ]
        , (#) Nav
            [ textAlign center
            , backgroundColor (hex "c99")
            ]
        , (#) Main
            [ backgroundColor (hex "9c9")
            , float left
            , width (vw 75)
            ]
        , (#) SideBar
            [ backgroundColor (hex "c9c")
            , float right
            , width (vw 25)
            ]
        , (#) Footer
            [ property "clear" "both"
            , backgroundColor (hex "cc9")
            ]
        , (.) ActiveVideo
            [ textAlign center ]
        , (.) VideoFrame
            [ height (Css.rem 30)
            , width (pct 98)
            ]
        ]
