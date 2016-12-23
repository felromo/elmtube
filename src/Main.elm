port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)


-- import Http
-- import Json.Decode as Decode
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
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Input
    | Search
    | SelectVideo
    | LikeVideo
    | DislikeVideo
    | Comment


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( model, searchQuery "raise cain" )

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
        [ button [ onClick Search ] [ text "test" ] ]


apiKey : String
apiKey =
    "AIzaSyAVYprfgQ03PuwwwKLNVdh6KJr2Me9XLYM"
