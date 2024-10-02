defmodule Fcmex.TripsTest do
  use ExUnit.Case, async: true
  alias Fcmex.Trips
  alias Fcmex.{Trip, TripSegment}

  # From specification
  @example_segments [
    %Fcmex.TripSegment{
      from: "SVQ",
      to: "BCN",
      type: :flight,
      start_date: "2023-03-02",
      start_time: "06:40",
      finish_date: nil,
      finish_time: "09:10",
      reservation_id: 1
    },
    %Fcmex.TripSegment{
      from: "BCN",
      to: "BCN",
      type: :hotel,
      start_date: "2023-01-05",
      start_time: nil,
      finish_date: "2023-01-10",
      finish_time: nil,
      reservation_id: 2
    },
    %Fcmex.TripSegment{
      from: "BCN",
      to: "SVQ",
      type: :flight,
      start_date: "2023-01-10",
      start_time: "10:30",
      finish_date: nil,
      finish_time: "11:50",
      reservation_id: 3
    },
    %Fcmex.TripSegment{
      from: "SVQ",
      to: "BCN",
      type: :flight,
      start_date: "2023-01-05",
      start_time: "20:40",
      finish_date: nil,
      finish_time: "22:10",
      reservation_id: 3
    },
    %Fcmex.TripSegment{
      from: "MAD",
      to: "SVQ",
      type: :train,
      start_date: "2023-02-17",
      start_time: "17:00",
      finish_date: nil,
      finish_time: "19:30",
      reservation_id: 4
    },
    %Fcmex.TripSegment{
      from: "SVQ",
      to: "MAD",
      type: :train,
      start_date: "2023-02-15",
      start_time: "09:30",
      finish_date: nil,
      finish_time: "11:00",
      reservation_id: 4
    },
    %Fcmex.TripSegment{
      from: "MAD",
      to: "MAD",
      type: :hotel,
      start_date: "2023-02-15",
      start_time: nil,
      finish_date: "2023-02-17",
      finish_time: nil,
      reservation_id: 5
    },
    %Fcmex.TripSegment{
      from: "BCN",
      to: "NYC",
      type: :flight,
      start_date: "2023-03-02",
      start_time: "15:00",
      finish_date: nil,
      finish_time: "22:45",
      reservation_id: 6
    },
    %Fcmex.TripSegment{
      from: "NYC",
      to: "BOS",
      type: :flight,
      start_date: "2023-03-06",
      start_time: "08:00",
      finish_date: nil,
      finish_time: "09:25",
      reservation_id: 6
    }
  ]

  describe "aggregate_trips/1" do
    test "return trips with aggregated segments" do
      assert Fcmex.Trips.aggregate_trips(@example_segments) == [
        %Fcmex.Trip{segments: [%Fcmex.TripSegment{from: "SVQ", to: "BCN", type: :flight, start_date: "2023-01-05", start_time: "20:40", finish_date: nil, finish_time: "22:10", reservation_id: 3, connection_flight: nil}, %Fcmex.TripSegment{from: "BCN", to: "BCN", type: :hotel, start_date: "2023-01-05", start_time: nil, finish_date: "2023-01-10", finish_time: nil, reservation_id: 2, connection_flight: nil}, %Fcmex.TripSegment{from: "BCN", to: "SVQ", type: :flight, start_date: "2023-01-10", start_time: "10:30", finish_date: nil, finish_time: "11:50", reservation_id: 3, connection_flight: nil}]},
        %Fcmex.Trip{segments: [%Fcmex.TripSegment{from: "SVQ", to: "MAD", type: :train, start_date: "2023-02-15", start_time: "09:30", finish_date: nil, finish_time: "11:00", reservation_id: 4, connection_flight: nil}, %Fcmex.TripSegment{from: "MAD", to: "MAD", type: :hotel, start_date: "2023-02-15", start_time: nil, finish_date: "2023-02-17", finish_time: nil, reservation_id: 5, connection_flight: nil}, %Fcmex.TripSegment{from: "MAD", to: "SVQ", type: :train, start_date: "2023-02-17", start_time: "17:00", finish_date: nil, finish_time: "19:30", reservation_id: 4, connection_flight: nil}]},
        %Fcmex.Trip{segments: [%Fcmex.TripSegment{from: "SVQ", to: "BCN", type: :flight, start_date: "2023-03-02", start_time: "06:40", finish_date: nil, finish_time: "09:10", reservation_id: 1, connection_flight: true}, %Fcmex.TripSegment{from: "BCN", to: "NYC", type: :flight, start_date: "2023-03-02", start_time: "15:00", finish_date: nil, finish_time: "22:45", reservation_id: 6, connection_flight: nil}, %Fcmex.TripSegment{from: "NYC", to: "BOS", type: :flight, start_date: "2023-03-06", start_time: "08:00", finish_date: nil, finish_time: "09:25", reservation_id: 6, connection_flight: nil}]}
      ]
    end

    test "trip to BCN with hotel and back to SVG" do
      segments = [
        %Fcmex.TripSegment{
          from: "BCN",
          to: "BCN",
          type: :hotel,
          start_date: "2023-01-05",
          start_time: nil,
          finish_date: "2023-01-10",
          finish_time: nil,
          reservation_id: 2
        },
        %Fcmex.TripSegment{
          from: "BCN",
          to: "SVQ",
          type: :flight,
          start_date: "2023-01-10",
          start_time: "10:30",
          finish_date: nil,
          finish_time: "11:50",
          reservation_id: 3
        },
        %Fcmex.TripSegment{
          from: "SVQ",
          to: "BCN",
          type: :flight,
          start_date: "2023-01-05",
          start_time: "20:40",
          finish_date: nil,
          finish_time: "22:10",
          reservation_id: 3
        }
      ]

      assert [%Trip{}] = Fcmex.Trips.aggregate_trips(segments)
    end
  end

  describe "sort_segments/1" do
    test "return segments sorted" do
      assert Fcmex.Trips.sort_segments(@example_segments) == [
               %Fcmex.TripSegment{
                 from: "SVQ",
                 to: "BCN",
                 type: :flight,
                 start_date: "2023-01-05",
                 start_time: "20:40",
                 finish_date: nil,
                 finish_time: "22:10",
                 reservation_id: 3
               },
               %Fcmex.TripSegment{
                 from: "BCN",
                 to: "BCN",
                 type: :hotel,
                 start_date: "2023-01-05",
                 start_time: nil,
                 finish_date: "2023-01-10",
                 finish_time: nil,
                 reservation_id: 2
               },
               %Fcmex.TripSegment{
                 from: "BCN",
                 to: "SVQ",
                 type: :flight,
                 start_date: "2023-01-10",
                 start_time: "10:30",
                 finish_date: nil,
                 finish_time: "11:50",
                 reservation_id: 3
               },
               %Fcmex.TripSegment{
                 from: "SVQ",
                 to: "MAD",
                 type: :train,
                 start_date: "2023-02-15",
                 start_time: "09:30",
                 finish_date: nil,
                 finish_time: "11:00",
                 reservation_id: 4
               },
               %Fcmex.TripSegment{
                 from: "MAD",
                 to: "MAD",
                 type: :hotel,
                 start_date: "2023-02-15",
                 start_time: nil,
                 finish_date: "2023-02-17",
                 finish_time: nil,
                 reservation_id: 5
               },
               %Fcmex.TripSegment{
                 from: "MAD",
                 to: "SVQ",
                 type: :train,
                 start_date: "2023-02-17",
                 start_time: "17:00",
                 finish_date: nil,
                 finish_time: "19:30",
                 reservation_id: 4
               },
               %Fcmex.TripSegment{
                 from: "SVQ",
                 to: "BCN",
                 type: :flight,
                 start_date: "2023-03-02",
                 start_time: "06:40",
                 finish_date: nil,
                 finish_time: "09:10",
                 reservation_id: 1
               },
               %Fcmex.TripSegment{
                 from: "BCN",
                 to: "NYC",
                 type: :flight,
                 start_date: "2023-03-02",
                 start_time: "15:00",
                 finish_date: nil,
                 finish_time: "22:45",
                 reservation_id: 6
               },
               %Fcmex.TripSegment{
                 from: "NYC",
                 to: "BOS",
                 type: :flight,
                 start_date: "2023-03-06",
                 start_time: "08:00",
                 finish_date: nil,
                 finish_time: "09:25",
                 reservation_id: 6
               }
             ]
    end
  end

  describe "connected_flight?" do
    test "it returns true if second segments starts less than 24h after the first one" do
      assert Trips.connected_flight?(
               %TripSegment{type: :flight, finish_date: "2023-03-02"},
               %TripSegment{type: :flight, start_date: "2023-03-03"}
             )

      assert Trips.connected_flight?(
               %TripSegment{type: :flight, finish_date: "2023-03-02", finish_time: "10:00"},
               %TripSegment{type: :flight, start_date: "2023-03-03", start_time: "9:00"}
             )

      assert Trips.connected_flight?(
               %TripSegment{type: :flight, finish_date: "2023-03-02", finish_time: "10:00"},
               %TripSegment{type: :flight, start_date: "2023-03-03", start_time: "9:00"}
             )
    end

    test "it returns false if second segmend starts more than 24h after the first one" do
      refute Trips.connected_flight?(
               %TripSegment{type: :flight, finish_date: "2023-03-02", finish_time: "9:00"},
               %TripSegment{type: :flight, start_date: "2023-03-03", start_time: "11:00"}
             )

      refute Trips.connected_flight?(
               %TripSegment{type: :flight, finish_date: "2023-03-02", start_time: "9:00"},
               %TripSegment{type: :flight, start_date: "2023-03-07"}
             )

      refute Trips.connected_flight?(
               %TripSegment{type: :flight, finish_date: "2023-03-02"},
               %TripSegment{type: :flight, start_date: "2023-03-09", start_time: "11:00"}
             )
    end
  end
end
