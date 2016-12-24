port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode


-- import Html.Attributes exposing (..)


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
    , display : TopLevel
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
      , display = TopLevel "" []
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
    | Display (Result Http.Error TopLevel)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( model, searchQuery "raise cain" )

        SearchNative ->
            ( model, searchVideo )

        Display (Ok something) ->
            { model | display = something } ! []

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
        ]


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


type alias TopLevel =
    { nextPageToken : String
    , items : List String
    }



-- getNextPageToken : Decode.Decoder String
-- getNextPageToken =
--     Decode.field "nextPageToken" Decode.string


getNextPageToken : Decode.Decoder TopLevel
getNextPageToken =
    Decode.map2 TopLevel
        (Decode.field "nextPageToken" Decode.string)
        (Decode.field "items" (Decode.list getId))


getId =
    Decode.at [ "id", "videoId" ] Decode.string
