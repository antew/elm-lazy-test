module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Lazy as Lazy
import Session exposing (Session)
import Time exposing (Posix)



-- TYPES


type alias Model =
    { session : Session
    , list : List String
    }


toSession : Model -> Session
toSession model =
    model.session


type Msg
    = NoOp
    | TimeUpdate Posix



-- STATE


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , list = []
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 TimeUpdate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate posix ->
            ( { model | list = String.fromInt (Time.posixToMillis posix) :: model.list }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html msg }
view model =
    { title = "Lazy Test"
    , content =
        Html.div [ Attributes.class "" ]
            [ Lazy.lazy viewList model.list
            ]
    }


viewList : List String -> Html msg
viewList list =
    Html.div [ Attributes.class "" ]
        (list
            |> List.map
                (\str ->
                    Html.div [ Attributes.class "w-28 px-8 py-4 text-lg mb-4" ]
                        [ Html.text str
                        ]
                )
        )
