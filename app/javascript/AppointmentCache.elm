module AppointmentCache exposing (fetchAppointments, accessAppointments, Model, initModel, Msg, update)

import Http
import Dict exposing (Dict)
import Date exposing (Date)
import Date.Extra as Date exposing (toRataDie, Interval(..))
import AppointmentAPI exposing (..)


type alias Model =
    { cache : Dict Int (Result String (List Appointment))
    }


initModel : Model
initModel =
    Model Dict.empty


type Msg
    = GotAppointments Date (Result Http.Error (List Appointment))


update : Msg -> Model -> Model
update msg model =
    case msg of
        GotAppointments date result ->
            case result of
                Ok appointments ->
                    { model | cache = Dict.insert (date |> keyFor) (Ok appointments) model.cache }

                _ ->
                    model


fetchAppointments : Model -> Date -> Date -> ( Model, Cmd Msg )
fetchAppointments model startDate endDate =
    Date.range Date.Month 1 (Date.floor Date.Month startDate) endDate
        |> List.foldr fetch ( model, [] )
        |> (\( m, cs ) -> ( m, Cmd.batch cs ))


accessAppointments : Model -> Date -> Date -> Result String (List Appointment)
accessAppointments model startDate endDate =
    Date.range Date.Month 1 (Date.floor Date.Month startDate) endDate
        |> List.map keyFor
        |> List.map (\k -> Dict.get k model.cache |> Maybe.withDefault (Ok []))
        |> List.foldl (\r s -> Result.map2 (++) s r) (Ok [])
        |> Result.map (filterAppointments startDate endDate)



--- INTERNAL


keyFor : Date -> Int
keyFor date =
    Date.floor Date.Month date |> toRataDie


filterAppointments : Date -> Date -> (List Appointment -> List Appointment)
filterAppointments a b =
    List.filter (\appointment -> Date.isBetween a (Date.add Date.Second -1 b) appointment.time)


fetch : Date -> ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
fetch date result =
    let
        key =
            keyFor date

        value =
            Dict.get key model.cache

        ( model, cmds ) =
            result
    in
        case value of
            Just result ->
                ( model, (appointmentRequestCmd date) :: cmds )

            Nothing ->
                ( model, (appointmentRequestCmd date) :: cmds )


appointmentRequestCmd : Date -> Cmd Msg
appointmentRequestCmd date =
    let
        endDate =
            Date.add Month 1 date
    in
        AppointmentAPI.listAppointments date endDate
            |> Http.send (GotAppointments date)