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
    , page : Page
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
    , related : List Video
    }


init : ( Model, Cmd Msg )
init =
    ( { input = ""
      , searchTerm = ""
      , searchReturn = []
      , activeVideo = (ActiveVideo (Video "" "" "" 0 0 (Thumbnail "" 0 0)) [] [])
      , page = Page "" []
      }
    , searchVideo "elm"
    )



-- UPDATE


type Msg
    = Input String
    | Search
    | SearchNative
    | SelectVideo
    | LikeVideo
    | DislikeVideo
    | Comment
    | Display (Result Http.Error Page)


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

        Display (Ok receivedPage) ->
            { model | page = receivedPage } ! []

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


view : Model -> Html.Html Msg
view model =
    div [ id [ MyCss.Wrap ] ]
        [ div [ id [ MyCss.Header ] ] [ h1 [] [ text "Elmtube" ] ]
        , div [ id [ MyCss.Nav ] ] [ searchBar model ]
        , div [ id [ MyCss.Main ] ] [ h3 [] [ activeVideo <| composeVideo <| head model.page.items ] ]
        , div [ id [ MyCss.SideBar ] ] [ h3 [] [ relatedVideos model ] ]
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
        ]


relatedVideos : Model -> Html.Html Msg
relatedVideos model =
    ul [] <| map (\item -> relatedVideoView item) model.page.items


relatedVideoView : VideoRaw -> Html.Html Msg
relatedVideoView video =
    li []
        [ h5 [] [ text video.details.title ]
        , img [ src video.details.thumbnails.url ] []
        , p [] [ text video.details.description ]
        ]


firstVideoId : Model -> String
firstVideoId model =
    let
        first =
            (head model.page.items)
    in
        case first of
            Just value ->
                value.videoId

            Nothing ->
                ""


composeVideo : Maybe VideoRaw -> Video
composeVideo videoRaw =
    case videoRaw of
        Just { videoId, details } ->
            let
                { title, description, thumbnails } =
                    details
            in
                Video videoId title description 0 0 thumbnails

        Nothing ->
            placeholderVideo


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
        Http.send Display <| Http.get url decodePage


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
