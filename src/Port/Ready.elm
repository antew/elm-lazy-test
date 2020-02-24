port module Port.Ready exposing (send)


send : Cmd msg
send =
    sendReady ()


port sendReady : () -> Cmd msg
