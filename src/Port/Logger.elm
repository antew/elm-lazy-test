port module Port.Logger exposing (log)

import Json.Decode as Decode
import Json.Encode as Encode


log : String -> Cmd msg
log str =
    loggerOutgoing str


port loggerOutgoing : String -> Cmd msg
