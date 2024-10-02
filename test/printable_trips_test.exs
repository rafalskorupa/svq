defmodule Fcmex.PrintableTripsTest do
  use ExUnit.Case, async: true
  alias Fcmex.Trips
  alias Fcmex.{Trip, TripSegment}

  # From specification
  @example_segments [
    %Fcmex.TripSegment{
      finish_date: nil,
      finish_time: "09:10",
      from: "SVQ",
      reservation_id: 1,
      start_date: "2023-03-02",
      start_time: "06:40",
      to: "BCN",
      type: :flight
    },
    %Fcmex.TripSegment{
      finish_date: "2023-01-10",
      finish_time: nil,
      from: "BCN",
      reservation_id: 2,
      start_date: "2023-01-05",
      start_time: nil,
      to: "BCN",
      type: :hotel
    },
    %Fcmex.TripSegment{
      finish_date: nil,
      finish_time: "11:50",
      from: "BCN",
      reservation_id: 3,
      start_date: "2023-01-10",
      start_time: "10:30",
      to: "SVQ",
      type: :flight
    },
    %Fcmex.TripSegment{
      finish_date: nil,
      finish_time: "22:10",
      from: "SVQ",
      reservation_id: 3,
      start_date: "2023-01-05",
      start_time: "20:40",
      to: "BCN",
      type: :flight
    },
    %Fcmex.TripSegment{
      finish_date: nil,
      finish_time: "19:30",
      from: "MAD",
      reservation_id: 4,
      start_date: "2023-02-17",
      start_time: "17:00",
      to: "SVQ",
      type: :train
    },
    %Fcmex.TripSegment{
      finish_date: nil,
      finish_time: "11:00",
      from: "SVQ",
      reservation_id: 4,
      start_date: "2023-02-15",
      start_time: "09:30",
      to: "MAD",
      type: :train
    },
    %Fcmex.TripSegment{
      finish_date: "2023-02-17",
      finish_time: nil,
      from: "MAD",
      reservation_id: 5,
      start_date: "2023-02-15",
      start_time: nil,
      to: "MAD",
      type: :hotel
    },
    %Fcmex.TripSegment{
      finish_date: nil,
      finish_time: "22:45",
      from: "BCN",
      reservation_id: 6,
      start_date: "2023-03-02",
      start_time: "15:00",
      to: "NYC",
      type: :flight
    },
    %Fcmex.TripSegment{
      finish_date: nil,
      finish_time: "09:25",
      from: "NYC",
      reservation_id: 6,
      start_date: "2023-03-06",
      start_time: "08:00",
      to: "BOS",
      type: :flight
    }
  ]

  describe "friendly_format/1" do
    test "it returns example trip in friendly format" do
      trips = Trips.aggregate_trips(@example_segments)

      assert Fcmex.PrintableTrips.friendly_format(trips) == """
             TRIP to BCN
             Flight from SVQ to BCN at 2023-01-05 20:40 to 22:10
             Hotel at BCN on 2023-01-05 to 2023-01-10
             Flight from BCN to SVQ at 2023-01-10 10:30 to 11:50

             TRIP to MAD
             Train from SVQ to MAD at 2023-02-15 09:30 to 11:00
             Hotel at MAD on 2023-02-15 to 2023-02-17
             Train from MAD to SVQ at 2023-02-17 17:00 to 19:30

             TRIP to NYC, BOS
             Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10
             Flight from BCN to NYC at 2023-03-02 15:00 to 22:45
             Flight from NYC to BOS at 2023-03-06 08:00 to 09:25
             """
    end

    test "it returns trip in friendly format" do
      trip = %Trip{
        segments: [
          %TripSegment{
            from: "SVQ",
            to: "BCN",
            type: :flight,
            start_date: "2023-03-02",
            start_time: "06:40",
            finish_date: nil,
            finish_time: "09:10\n"
          }
        ]
      }

      assert Fcmex.PrintableTrips.friendly_format(trip) == """
             TRIP to BCN
             Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10
             """
    end
  end
end
