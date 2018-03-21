module AppointmentAPI exposing (listAppointments, Appointment, createAppointment)

import Http exposing (Request, jsonBody)
import Json.Encode exposing (object, encode)
import Json.Decode exposing (Decoder, map, field, string, list, succeed, fail, andThen)
import Date exposing (Date, Month(..))
import Date.Extra as Date


type alias Appointment =
    { time : Date
    }


listAppointments : Date -> Date -> Request (List Appointment)
listAppointments startDate endDate =
    let
        request_url =
            url "/appointments"
                [ ( "before", ((Date.toTime endDate / 1000) |> toString) ) ]
    in
        Http.get request_url (list appointmentDecoder)


createAppointment : Date -> Request Appointment
createAppointment date =
    let
        request_url = "/appointments"
        request_body = (object
                [ ( "appointment", 
                    object [
                        ( "time", Json.Encode.string (Date.toIsoString date) )
                   ])
                ])
    in
        Http.post request_url (jsonBody request_body) appointmentDecoder


appointmentDecoder : Decoder Appointment
appointmentDecoder =
    map Appointment
        (field "time" stringToDate)


stringToDate : Decoder Date
stringToDate =
  string
    |> andThen (\val ->
        case Date.fromIsoString(val) of
          Nothing -> fail "Couldn't parse date"
          Just date -> succeed date
    )


url : String -> List ( String, String ) -> String
url baseUrl args =
    case args of
        [] ->
            baseUrl

        _ ->
            baseUrl ++ "?" ++ String.join "&" (List.map queryPair args)


queryPair : ( String, String ) -> String
queryPair ( key, value ) =
    Http.encodeUri key ++ "=" ++ Http.encodeUri value