module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Browser.Events
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Html.Lazy as Lazy
import Json.Decode as Decode
import Port.Faker as Faker exposing (FakeData)
import Port.Logger as Logger
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
    | OnFakeData FakeData
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
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if model.messagesPerSecond /= 0 then
            Time.every (1000 / toFloat model.messagesPerSecond) TimeUpdate

          else
            Sub.none
        , Faker.receive OnFakeData
        , Browser.Events.onAnimationFrame OnAnimationFrame
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate posix ->
            ( model
            , Faker.send
            )

        OnFakeData fakeData ->
            ( { model
                | messages =
                    fakeData
                        :: (if List.length model.messages >= model.maxMessages then
                                List.take (model.maxMessages - 1) model.messages

                            else
                                model.messages
                           )
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
                [ Attributes.class "flex flex-col w-1/3 p-4" ]
                [ Html.h2 [ Attributes.class "" ]
                    [ Html.text "Messages Per Second"
                    ]
                , Html.input
                    [ Attributes.class "border py-2 px-4 bg-transparent"
                    , Attributes.type_ "number"
                    , Attributes.value (String.fromInt model.messagesPerSecond)
                    , onNumericInput SetMessagesPerSecond
                    ]
                    []
                , Html.h2 [ Attributes.class "mt-6" ]
                    [ Html.text "Max Messages"
                    ]
                , Html.input
                    [ Attributes.class "border py-2 px-4 bg-transparent"
                    , Attributes.type_ "number"
                    , Attributes.value (String.fromInt model.maxMessages)
                    , onNumericInput SetMaxMessages
                    ]
                    []
                , Html.h2 [ Attributes.class "mt-6" ]
                    [ Html.text "Current Message Count"
                    ]
                , Html.span [ Attributes.class "border py-2 px-4 bg-transparent" ]
                    [ Html.text <| String.fromInt <| List.length model.messages ]
                , Html.h2 [ Attributes.class "mt-6" ]
                    [ Html.text "Animation Frame Subscription"
                    ]
                , Html.span [ Attributes.class "border py-2 px-4 bg-transparent" ]
                    [ Html.text <| String.fromInt <| Time.posixToMillis model.currentTime ]
                , Html.div [ Attributes.class "mt-6 text-xs" ]
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
                    ]
                ]
            , Html.div [ Attributes.class "flex flex-col-reverse w-2/3 overflow-scroll" ]
                [ Lazy.lazy viewList model.messages
                ]
            ]
    }


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
                (\message ->
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
                )
        )
