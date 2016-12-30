module MyCss exposing (CssClasses(..), CssIds(..), css)

import Css exposing (..)
import Css.Elements exposing (html, body, li, ul)
import Css.Namespace exposing (namespace)


type CssClasses
    = NavBar
    | HeadTitle
    | SearchBar
    | SearchForm
    | ActiveVideo
    | VideoFrame
    | VideoDetails
    | VideoTitle
    | VideoDescription
    | CommentsArea
    | CommentLi
    | CommentFooter
    | CommentUserImage
    | CommentContent
    | CommentContentUserName
    | CommentContentText
    | RelatedLi
    | RelatedTitle
    | RelatedImg
    | RelatedFooter


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
            [ margin zero
            , padding zero
            , color (hex "000")
            , property "font-family" "Roboto, sans-serif"
              -- , backgroundColor (hex "a7a09a")
            ]
        , html
            [ margin zero
            , padding zero
            , color (hex "000")
              -- , backgroundColor (hex "a7a09a")
            ]
        , ul [ listStyleType none ]
        , (#) Wrap
            [ width (vw 100)
            , marginLeft auto
            , marginRight auto
            , marginTop zero
            , marginBottom zero
              -- , backgroundColor (hex "99c")
            ]
        , (#) Header
            [ textAlign center
              -- , backgroundColor (hex "ddd")
            ]
        , (#) Nav
            [ textAlign center
              -- , backgroundColor (hex "c99")
            ]
        , (#) Main
            [ float left
            , width (vw 75)
              -- , backgroundColor (hex "9c9")
            ]
        , (#) SideBar
            [ float right
            , width (vw 25)
              -- , backgroundColor (hex "c9c")
            ]
        , (#) Footer
            [ property "clear" "both"
              -- , backgroundColor (hex "cc9")
            ]
        , (.) HeadTitle
            [ fontSize (Css.rem 3) ]
        , (.) SearchBar
            [ width (pct 25) ]
        , (.) SearchForm
            [ margin (Css.rem 1) ]
        , (.) ActiveVideo
            [ textAlign center ]
        , (.) VideoFrame
            [ height (Css.rem 30)
            , width (pct 98)
            ]
        , (.) VideoDetails
            [ backgroundColor (hex "dedada")
            , borderRadius (px 5)
            ]
        , (.) VideoTitle
            [ textAlign left ]
        , (.) VideoDescription
            [ textAlign left ]
        , (.) CommentsArea
            [ backgroundColor (hex "dedada")
            , borderRadius (px 5)
            , property "margin" "0 10px"
            , property "padding" "1px 10px"
            ]
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
        , (.) RelatedLi
            [ property "margin" "10px 0" ]
        , (.) RelatedImg
            [ float left ]
        , (.) RelatedFooter
            [ property "clear" "both" ]
        ]
