module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Browser.Events
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Html.Lazy as Lazy
import Json.Decode as Decode
import Port.Faker as Faker exposing (FakeData)
import Port.Logger as Logger
import Port.Ready as Ready
import Session exposing (Session)
import Time exposing (Posix)



-- TYPES


type alias Model =
    { session : Session
    , messages : List FakeData
    , messagesPerSecond : Int
    , maxMessages : Int
    , currentMessages : Int
    , currentTime : Posix
    }


toSession : Model -> Session
toSession model =
    model.session


type Msg
    = NoOp
    | TimeUpdate Posix
    | OnFakeData (List FakeData)
    | OnAnimationFrame Posix
    | SetMessagesPerSecond Int
    | SetMaxMessages Int



-- STATE


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , messages = []
      , messagesPerSecond = 1
      , maxMessages = 500
      , currentMessages = 0
      , currentTime = Time.millisToPosix 0
      }
    , Ready.send
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if model.messagesPerSecond /= 0 then
            Time.every (1000 / toFloat model.messagesPerSecond) TimeUpdate

          else
            Sub.none
        , Faker.receive OnFakeData

        -- , Browser.Events.onAnimationFrame OnAnimationFrame
        , Time.every 100 OnAnimationFrame
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate posix ->
            ( model
            , Faker.send model.messagesPerSecond
            )

        OnFakeData messages ->
            ( { model
                | messages =
                    messages
                        |> List.foldl (\m acc -> m :: acc) model.messages
              }
            , Cmd.none
            )

        SetMessagesPerSecond value ->
            ( { model | messagesPerSecond = value }
            , Logger.log
                ("Set messages per second to: "
                    ++ String.fromInt value
                )
            )

        SetMaxMessages value ->
            ( { model | maxMessages = value }
            , Cmd.none
            )

        OnAnimationFrame posix ->
            ( { model | currentTime = posix }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Lazy Test"
    , content =
        Html.div [ Attributes.class "flex" ]
            [ Html.div
                [ Attributes.class "flex flex-col w-2/3 p-4" ]
                [ controls model
                , charts
                ]
            , Html.div [ Attributes.class "flex flex-col-reverse w-1/3 overflow-scroll" ]
                [ viewList (List.take model.maxMessages model.messages)
                ]
            ]
    }


controls : Model -> Html Msg
controls model =
    Html.div [ Attributes.class "flex" ]
        [ Html.div [ Attributes.class "flex flex-col w-1/3" ]
            [ Html.div []
                [ Html.text "Messages Per Second"
                ]
            , Html.input
                [ Attributes.class "border py-2 px-4 bg-transparent"
                , Attributes.type_ "number"
                , Attributes.value (String.fromInt model.messagesPerSecond)
                , onNumericInput SetMessagesPerSecond
                ]
                []
            ]
        , Html.div [ Attributes.class "flex flex-col w-1/3" ]
            [ Html.div [] [ Html.text "Max Messages To Display" ]
            , Html.input
                [ Attributes.class "border py-2 px-4 bg-transparent"
                , Attributes.type_ "number"
                , Attributes.value (String.fromInt model.maxMessages)
                , onNumericInput SetMaxMessages
                ]
                []
            ]
        , Html.div [ Attributes.class "flex flex-col w-1/3" ]
            [ Html.div [] [ Html.text "Current Message Count" ]
            , Html.span [ Attributes.class "border py-2 px-4 bg-transparent" ]
                [ Html.text <| String.fromInt <| List.length model.messages ]
            ]
        , Html.div [ Attributes.class "flex flex-col w-1/3" ]
            [ Html.div []
                [ Html.text "Current Time"
                ]
            , Html.span [ Attributes.class "border py-2 px-4 bg-transparent" ]
                [ Html.text <| String.fromInt <| Time.posixToMillis model.currentTime ]
            ]
        ]


charts : Html msg
charts =
    Html.div [ Attributes.class "mt-6 text-xs" ]
        [ Html.pre
            [ Attributes.class ""
            , Attributes.id "view-chart"
            ]
            []
        , Html.h4 []
            [ Html.text "View function (ms)"
            ]
        , Html.pre
            [ Attributes.class "mt-6"
            , Attributes.id "diff-chart"
            ]
            []
        , Html.h4 []
            [ Html.text "VDom diffing (ms)"
            ]
        , Html.pre
            [ Attributes.class "mt-6"
            , Attributes.id "patch-chart"
            ]
            []
        , Html.h4 []
            [ Html.text "VDom patching (ms)"
            ]
        , Html.pre
            [ Attributes.class "mt-6"
            , Attributes.id "frame-chart"
            ]
            []
        , Html.h4 []
            [ Html.text "Frame time (ms)"
            ]
        , Html.pre
            [ Attributes.class "mt-6"
            , Attributes.id "lazy-success-chart"
            ]
            []
        , Html.h4 []
            [ Html.text "Lazy render success"
            ]
        , Html.pre
            [ Attributes.class "mt-6"
            , Attributes.id "lazy-failure-chart"
            ]
            []
        , Html.h4 []
            [ Html.text "Lazy render failure"
            ]
        ]


onNumericInput : (Int -> msg) -> Html.Attribute msg
onNumericInput tagger =
    Events.on "input"
        (Decode.at [ "target", "value" ] Decode.string
            |> Decode.andThen
                (\value ->
                    case String.toInt value of
                        Just num ->
                            Decode.succeed (tagger num)

                        Nothing ->
                            Decode.fail "Invalid number"
                )
        )


viewList : List FakeData -> Html msg
viewList messages =
    Html.div [ Attributes.class "" ]
        (messages
            |> List.map
                (\message -> Lazy.lazy viewMessage message)
        )


viewMessage : FakeData -> Html msg
viewMessage message =
    Html.div [ Attributes.class "w-28 px-8 py-4 text-lg mb-4" ]
        [ Html.div [ Attributes.class "flex items-center" ]
            [ Html.img
                [ Attributes.src message.avatar
                , Attributes.class "w-8 h-8 rounded-full mr-3 pb-1"
                ]
                []
            , Html.div []
                [ Html.text message.name ]
            ]
        , Html.div []
            [ Html.div
                [ Attributes.class "" ]
                [ Html.text message.message
                ]
            ]
        ]
