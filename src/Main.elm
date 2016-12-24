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
    , description : String
    , likes : Int
    , dislikes : Int
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
      , activeVideo = (ActiveVideo (Video "" "" 0 0) [] [])
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


view : Model -> Html.Html Msg
view model =
    div []
        [ div
            []
            [ h3 [] [ text "Debug Menu" ]
            , button [ onClick Search ] [ text "Interop" ]
            , button [ onClick SearchNative ] [ text "Native" ]
            , hr [] []
            ]
        , h1 [] [ text "Elmtube" ]
        , form [ onSubmit Search ]
            [ input
                [ type_ "text"
                , onInput Input
                , value model.input
                ]
                []
            , button [ type_ "submit" ] [ text "Search" ]
            ]
        , iframe [ src ("https://www.youtube.com/embed/" ++ (firstVideo model)) ] []
        , ul [] <| map (\item -> relatedVideoView item) model.page.items
        ]


relatedVideoView : VideoRaw -> Html.Html Msg
relatedVideoView video =
    li []
        [ h5 [] [ text video.details.title ]
        , img [ src video.details.thumbnails.url ] []
        , p [] [ text video.details.description ]
        ]


firstVideo : Model -> String
firstVideo model =
    let
        first =
            (head model.page.items)
    in
        case first of
            Just value ->
                value.videoId

            Nothing ->
                ""


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
        Http.send Display <| Http.get url getNextPageToken


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



-- getNextPageToken : Decode.Decoder String
-- getNextPageToken =
--     Decode.field "nextPageToken" Decode.string
-- getId : Decode.Decoder String
-- getId =
--     Decode.at [ "id", "videoId" ] Decode.string


getNextPageToken : Decode.Decoder Page
getNextPageToken =
    Decode.map2 Page
        (Decode.field "nextPageToken" Decode.string)
        (Decode.field "items" (Decode.list getVideoRaw))


getVideoRaw : Decode.Decoder VideoRaw
getVideoRaw =
    Decode.map2 VideoRaw
        (Decode.at [ "id", "videoId" ] Decode.string)
        (Decode.field "snippet" getVideoDetails)


getVideoDetails : Decode.Decoder VideoDetails
getVideoDetails =
    Decode.map3 VideoDetails
        (Decode.field "title" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "thumbnails" getThumbnails)


getThumbnails : Decode.Decoder Thumbnail
getThumbnails =
    Decode.map3 Thumbnail
        (Decode.at [ "default", "url" ] Decode.string)
        (Decode.at [ "default", "width" ] Decode.int)
        (Decode.at [ "default", "height" ] Decode.int)
