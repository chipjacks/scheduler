module Main exposing (..)

import Html exposing (Html, h3, h4, text, div, a)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)
import Date exposing (Date, Month(..))
import Date.Extra as Date exposing (Interval(..))
import AppointmentCache exposing (accessAppointments, fetchAppointments)
import Task
import AppointmentAPI exposing (Appointment)
import Http

-- MODEL

type alias Model =
  { date: Date
  , apptCache: AppointmentCache.Model
  , message: Maybe String
  }

-- INIT

init : (Model, Cmd Message)
init =
  (Model (Date.fromCalendarDate 2018 Jan 1) AppointmentCache.initModel Nothing, Task.perform NewDate Date.now)


-- VIEW

view : Model -> Html Message
view model =
  let
    start = model.date
    end = Date.add Day 5 model.date
  in
    div [style []]
      [ viewMessage model
      , h3 [ class "ui center aligned header" ]
        [ a [onClick (NewDate (Date.add Week -1 start))] [text "< "]
        , ((start |> Date.toFormattedString "MMM ddd") ++ " - " ++ (end |> Date.toFormattedString "MMM ddd")) |> text
        , a [onClick (NewDate (Date.add Week 1 start))] [text " >"]
        ]
      , div [ class "ui nine column grid" ] (Date.range Date.Day 1 start end |> List.map (viewDay model))
      ]

viewMessage : Model -> Html Message
viewMessage model =
  case model.message of
      Just msg ->
        div [ class "ui message" ] [ msg |> text ]
  
      Nothing ->
        div [ class "ui hidden message" ] []
          

viewDay : Model -> Date -> Html Message
viewDay model date =
  let
      start = Date.fromParts (Date.year date) (Date.month date) (Date.day date) 9 0 0 0
      end = Date.add Hour 8 start
  in
    div [ class "row" ] 
      (
      [ h4 [ class "column" ] [date |> Date.toFormattedString "E" |> text]
      ] ++ (Date.range Date.Hour 1 start end |> List.map (viewHour model))
      )

viewHour : Model -> Date -> Html Message
viewHour model date = 
  let
      appts = accessAppointments model.apptCache (Date.floor Hour date) (Date.ceiling Hour date)
  in
    case appts of
      Ok [] ->
        div [class "column", onClick (CreateAppt date)] [Html.text <| Date.toFormattedString "h" <| date]

      _ ->
        div [ class "grey column" ] [ ]


      
-- MESSAGE

type Message
  = UpdateAppointmentCache AppointmentCache.Msg
  | NewDate Date
  | CreateAppt Date
  | CreatedAppt Date (Result Http.Error Appointment)

-- UPDATE

update : Message -> Model -> (Model, Cmd Message)
update message model =
  case message of
    UpdateAppointmentCache subMsg ->
      { model | apptCache = AppointmentCache.update subMsg model.apptCache } ! []
    
    NewDate date ->
      switchDate model date
    
    CreateAppt date ->
      model ! [AppointmentAPI.createAppointment date |> Http.send (CreatedAppt date)]
    
    CreatedAppt date result ->
      case result of
        Ok appt ->
          switchDate ({ model | message = Just ("Successfully created appointment for " ++ (Date.toFormattedString "MMMM ddd ha" date))}) date

        Err msg ->
          { model | message = Just "Failed to create appointment" } ! []


switchDate : Model -> Date -> (Model, Cmd Message)
switchDate model date =
  let
    ( acModel, acMsg ) =
        fetchAppointments model.apptCache (Date.floor Week date) (Date.ceiling Week date)
  in
    { model | date = (Date.floor Week date), apptCache = acModel } ! [ acMsg |> Cmd.map UpdateAppointmentCache ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Message
subscriptions model =
  Sub.none

-- MAIN

main : Program Never Model Message
main =
  Html.program
    {
      init = init,
      view = view,
      update = update,
      subscriptions = subscriptions
    }
