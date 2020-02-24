port module Port.Faker exposing (FakeData, receive, send)


type alias FakeData =
    { name : String
    , avatar : String
    , message : String
    }


send : Int -> Cmd msg
send count =
    fakerOutgoing count


receive : (List FakeData -> msg) -> Sub msg
receive tagger =
    fakerIncoming tagger


port fakerOutgoing : Int -> Cmd msg


port fakerIncoming : (List FakeData -> msg) -> Sub msg
