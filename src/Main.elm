module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)


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
    , activeVideo : Video
    }


type alias Video =
    { id : String
    , name : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" "" [] { id = "", name = "" }, Cmd.none )



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
        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html.Html Msg
view model =
    div []
        [ text "placeholder" ]
