port module Main exposing (..)

import Html exposing (div, ul, li, button, text, hr, iframe, h1, h3, h5, input, form, Attribute, img, p)
import Html.Attributes exposing (src, type_, value)
import Html.Events exposing (onClick, onSubmit, onInput)
import Http
import Json.Decode as Decode
import List exposing (map, head)
import MyCss
import Html.CssHelpers


{ id, class, classList } =
    Html.CssHelpers.withNamespace "base"


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { input : String
    , searchTerm : String
    , searchReturn : List Video
    , activeVideo : ActiveVideo
    , activeVideoComments : CommentPage
    , page : Page
    , error : String
    }


type alias Video =
    { id : String
    , title : String
    , description : String
    , likes : Int
    , dislikes : Int
    , thumbnail : Thumbnail
    }


type alias ActiveVideo =
    { video : Video
    , comments : List String
    , related : List VideoRaw
    }


type alias Page =
    { nextPageToken : String
    , items : List VideoRaw
    }


type alias VideoRaw =
    { videoId : String
    , details : VideoDetails
    }


type alias VideoDetails =
    { title : String
    , description : String
    , thumbnails : Thumbnail
    }


type alias Thumbnail =
    { url : String
    , width : Int
    , height : Int
    }


type alias CommentPage =
    { nextPageToken : Maybe String, items : List Comment }


type alias Comment =
    { id : String
    , authorDisplayName : String
    , authorProfileImageUrl : String
    , textDisplay : String
    , likeCount : Int
    , publishedAt : String
    , totalReplyCount : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { input = ""
      , searchTerm = ""
      , searchReturn = []
      , activeVideo = (ActiveVideo (Video "" "" "" 0 0 (Thumbnail "" 0 0)) [] [])
      , activeVideoComments = CommentPage (Just "") []
      , page = Page "" []
      , error = ""
      }
    , searchVideo "elm"
    )



-- UPDATE


type Msg
    = Input String
    | Search
    | SearchNative
    | SelectVideo Video
    | LikeVideo
    | DislikeVideo
    | PopulateComments (Result Http.Error CommentPage)
    | PostComment
    | SetPage (Result Http.Error Page)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input searchInput ->
            { model | input = searchInput } ! []

        Search ->
            -- ( model, searchQuery "raise cain" )
            ( { model | input = "" }, searchVideo model.input )

        SearchNative ->
            ( model, searchVideo "raise cain" )

        SetPage (Ok receivedPage) ->
            let
                first =
                    firstVideoRaw receivedPage.items
            in
                { model
                    | page = receivedPage
                    , activeVideo =
                        { video = composeVideo first
                        , comments = []
                        , related = composeRelated first.videoId receivedPage.items
                        }
                }
                    ! [ fetchComments first.videoId ]

        PopulateComments (Ok receivedCommentPage) ->
            { model
                | activeVideoComments = receivedCommentPage
            }
                ! []

        PopulateComments (Err error) ->
            { model
                | activeVideoComments = CommentPage (Just "") []
                , error = toString error
            }
                ! []

        SelectVideo video ->
            { model
                | activeVideo =
                    { video = video
                    , comments = []
                    , related = composeRelated video.id model.page.items
                    }
            }
                ! [ fetchComments video.id ]

        _ ->
            ( model, Cmd.none )



-- port to send the search query to javascript


port searchQuery : String -> Cmd msg



-- port to listen for the results of the query


port searchResults : (List String -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


placeholderVideo : Video
placeholderVideo =
    Video "" "Loading.." "Loading.." 0 0 (Thumbnail "" 0 0)


placeholderVideoRaw : VideoRaw
placeholderVideoRaw =
    VideoRaw "" <| VideoDetails "" "" <| Thumbnail "" 0 0


view : Model -> Html.Html Msg
view model =
    div [ id [ MyCss.Wrap ] ]
        [ div [ id [ MyCss.Header ] ] [ h1 [] [ text "Elmtube" ] ]
        , div [ id [ MyCss.Nav ] ] [ searchBar model ]
        , div [ id [ MyCss.Main ] ]
            [ div [] [ activeVideo model.activeVideo.video ]
            , commentsView model.activeVideoComments.items
            ]
        , div [ id [ MyCss.SideBar ] ] [ h3 [] [ relatedVideos model.activeVideo.related ] ]
        , div [ id [ MyCss.Footer ] ] [ p [] [ text "footer" ] ]
        ]


searchBar : Model -> Html.Html Msg
searchBar model =
    form [ onSubmit Search ]
        [ input
            [ type_ "text"
            , onInput Input
            , value model.input
            ]
            []
        , button [ type_ "submit" ] [ text "Search" ]
        ]


activeVideo : Video -> Html.Html Msg
activeVideo video =
    div [ class [ MyCss.ActiveVideo ] ]
        [ iframe
            [ class [ MyCss.VideoFrame ]
            , src ("https://www.youtube.com/embed/" ++ video.id)
            ]
            []
        , h3 [ class [ MyCss.VideoTitle ] ] [ text video.title ]
        , p [ class [ MyCss.VideoDescription ] ] [ text video.description ]
        ]


relatedVideos : List VideoRaw -> Html.Html Msg
relatedVideos videosRaw =
    ul [] <| map (\videoRaw -> relatedVideoView videoRaw) videosRaw


relatedVideoView : VideoRaw -> Html.Html Msg
relatedVideoView video =
    li [ onClick (SelectVideo <| composeVideo video) ]
        [ h5 [] [ text video.details.title ]
        , img
            [ src video.details.thumbnails.url ]
            []
        , p [] [ text video.details.description ]
        ]


commentsView : List Comment -> Html.Html Msg
commentsView =
    ul [] << map (\comment -> commentsLiView comment)


commentsLiView : Comment -> Html.Html Msg
commentsLiView comment =
    li []
        [ p [] [ text comment.textDisplay ] ]


firstVideoRaw : List VideoRaw -> VideoRaw
firstVideoRaw videos =
    let
        first =
            (head videos)
    in
        case first of
            Just video ->
                video

            Nothing ->
                placeholderVideoRaw


composeVideo : VideoRaw -> Video
composeVideo { videoId, details } =
    let
        { title, description, thumbnails } =
            details
    in
        Video videoId title description 0 0 thumbnails


composeRelated : String -> List VideoRaw -> List VideoRaw
composeRelated videoId videosRaw =
    List.filterMap
        (\video ->
            if video.videoId /= videoId then
                Just video
            else
                Nothing
        )
        videosRaw


apiKey : String
apiKey =
    "AIzaSyAVYprfgQ03PuwwwKLNVdh6KJr2Me9XLYM"


constructUrl : String -> String -> String
constructUrl query apiKey =
    let
        keyParam =
            "key=" ++ apiKey

        queryParam =
            "&q=" ++ query

        partParam =
            -- this one is preset, but change here if desired
            "&part=" ++ "snippet"

        typeParam =
            "&type=" ++ "video"
    in
        "https://www.googleapis.com/youtube/v3/search?" ++ keyParam ++ queryParam ++ partParam ++ typeParam


searchVideo : String -> Cmd Msg
searchVideo query =
    let
        url =
            constructUrl query apiKey
    in
        Http.send SetPage <| Http.get url decodePage


fetchComments : String -> Cmd Msg
fetchComments videoId =
    let
        url =
            "https://www.googleapis.com/youtube/v3/commentThreads?" ++ "key=" ++ apiKey ++ "&part=snippet&videoId=" ++ videoId
    in
        Http.send PopulateComments <| Http.get url decodeCommentPage


decodeCommentPage : Decode.Decoder CommentPage
decodeCommentPage =
    Decode.map2 CommentPage
        (Decode.maybe (Decode.field "nextPageToken" Decode.string))
        (Decode.field "items" (Decode.list decodeComment))


decodeComment : Decode.Decoder Comment
decodeComment =
    Decode.map7 Comment
        (Decode.field "id" Decode.string)
        (Decode.at [ "snippet", "topLevelComment", "snippet", "authorDisplayName" ] Decode.string)
        (Decode.at [ "snippet", "topLevelComment", "snippet", "authorProfileImageUrl" ] Decode.string)
        (Decode.at [ "snippet", "topLevelComment", "snippet", "textDisplay" ] Decode.string)
        (Decode.at [ "snippet", "topLevelComment", "snippet", "likeCount" ] Decode.int)
        (Decode.at [ "snippet", "topLevelComment", "snippet", "publishedAt" ] Decode.string)
        (Decode.at [ "snippet", "totalReplyCount" ] Decode.int)


decodePage : Decode.Decoder Page
decodePage =
    Decode.map2 Page
        (Decode.field "nextPageToken" Decode.string)
        (Decode.field "items" (Decode.list decodeVideoRaw))


decodeVideoRaw : Decode.Decoder VideoRaw
decodeVideoRaw =
    Decode.map2 VideoRaw
        (Decode.at [ "id", "videoId" ] Decode.string)
        (Decode.field "snippet" decodeVideoDetails)


decodeVideoDetails : Decode.Decoder VideoDetails
decodeVideoDetails =
    Decode.map3 VideoDetails
        (Decode.field "title" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "thumbnails" decodeThumbnails)


decodeThumbnails : Decode.Decoder Thumbnail
decodeThumbnails =
    Decode.map3 Thumbnail
        (Decode.at [ "default", "url" ] Decode.string)
        (Decode.at [ "default", "width" ] Decode.int)
        (Decode.at [ "default", "height" ] Decode.int)
