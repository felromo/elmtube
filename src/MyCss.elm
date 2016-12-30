module MyCss exposing (CssClasses(..), CssIds(..), css)

import Css exposing (..)
import Css.Elements exposing (html, body, li, ul)
import Css.Namespace exposing (namespace)


type CssClasses
    = NavBar
    | ActiveVideo
    | VideoFrame
    | VideoTitle
    | VideoDescription
    | CommentLi
    | CommentFooter
    | CommentUserImage
    | CommentContent
    | CommentContentUserName
    | CommentContentText


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
        , ul [ listStyleType none ]
        , (#) Wrap
            [ width (vw 100)
            , marginLeft auto
            , marginRight auto
            , marginTop zero
            , marginBottom zero
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
        , (.) VideoTitle
            [ textAlign left ]
        , (.) VideoDescription
            [ textAlign left ]
        , (.) CommentLi
            [ property "margin" "30px auto" ]
        , (.) CommentUserImage
            [ float left
            , width (pct 5)
            ]
        , (.) CommentContent
            [ float right
            , width (pct 95)
            ]
        , (.) CommentContentUserName
            [ property "margin" "0" ]
        , (.) CommentContentText
            [ property "margin" "0" ]
        , (.) CommentFooter
            [ property "clear" "both" ]
        ]
