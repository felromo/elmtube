port module Main exposing (..)

import Html exposing (div, ul, li, button, text)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import List exposing (map)


-- import Html.Attributes exposing (..)


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
    , Cmd.none
    )



-- UPDATE


type Msg
    = Input
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
        Search ->
            ( model, searchQuery "raise cain" )

        SearchNative ->
            ( model, searchVideo )

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
        [ button [ onClick Search ] [ text "Interop" ]
        , button [ onClick SearchNative ] [ text "Native" ]
        , ul [] <| map (\item -> li [] [ text item.details.description ]) model.page.items
        ]



-- listOfLi-- s : Model -> Html.Html Msg
-- listOfLis model =
--     map (


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


searchVideo : Cmd Msg
searchVideo =
    let
        url =
            constructUrl "raise cain" apiKey
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
