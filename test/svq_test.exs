defmodule Fcmex.SvqTest do
  use ExUnit.Case, async: true

  alias Fcmex.Svq
  alias Fcmex.{TripSegment}

  describe "parse/1" do
    @example_svq [
      "BASED: SVQ\n",
      "\n",
      "RESERVATION\n",
      "SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10\n",
      "\n",
      "RESERVATION\n",
      "SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10\n",
      "\n",
      "RESERVATION\n",
      "SEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10\n",
      "SEGMENT: Flight BCN 2023-01-10 10:30 -> SVQ 11:50\n",
      "\n",
      "RESERVATION\n",
      "SEGMENT: Train SVQ 2023-02-15 09:30 -> MAD 11:00\n",
      "SEGMENT: Train MAD 2023-02-17 17:00 -> SVQ 19:30\n",
      "\n",
      "RESERVATION\n",
      "SEGMENT: Hotel MAD 2023-02-15 -> 2023-02-17\n",
      "\n",
      "RESERVATION\n",
      "SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45\n",
      "SEGMENT: Flight NYC 2023-03-06 08:00 -> BOS 09:25"
    ]

    test "returns parsed segments" do
      assert {:ok, segments} = Svq.parse(@example_svq)

      assert segments == [
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
    end
  end

  describe "parse_reservation/1" do
    test "it parses reservation data to struct" do
      segments = [
        "SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45",
        "SEGMENT: Flight NYC 2023-03-06 08:00 -> BOS 09:25"
      ]

      assert [
               {
                 :ok,
                 %Fcmex.TripSegment{
                   finish_date: nil,
                   finish_time: "22:45",
                   from: "BCN",
                   reservation_id: 2,
                   start_date: "2023-03-02",
                   start_time: "15:00",
                   to: "NYC",
                   type: :flight
                 }
               },
               {:ok,
                %Fcmex.TripSegment{
                  from: "NYC",
                  to: "BOS",
                  type: :flight,
                  start_date: "2023-03-06",
                  start_time: "08:00",
                  finish_date: nil,
                  finish_time: "09:25",
                  reservation_id: 2
                }}
             ] = Svq.parse_reservation({2, segments})
    end

    test "it parses single segment reservation" do
      segments = [
        "SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10"
      ]

      assert [
               ok: %TripSegment{
                 from: "SVQ",
                 to: "BCN",
                 type: :flight,
                 start_date: "2023-03-02",
                 start_time: "06:40",
                 finish_date: nil,
                 finish_time: "09:10",
                 reservation_id: 5
               }
             ] = Fcmex.Svq.parse_reservation({5, segments})
    end

    test "it return invalid segments" do
      segments = [
        "SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45",
        "SEG: Flight NYC 2023-03-06 08:00 -> BOS 09:25"
      ]

      assert [
               {:ok,
                %Fcmex.TripSegment{
                  from: "BCN",
                  to: "NYC",
                  type: :flight,
                  start_date: "2023-03-02",
                  start_time: "15:00",
                  finish_date: nil,
                  finish_time: "22:45",
                  reservation_id: 2
                }},
               {:error, :invalid_segment, "SEG: Flight NYC 2023-03-06 08:00 -> BOS 09:25"}
             ] = Fcmex.Svq.parse_reservation({2, segments})
    end
  end

  describe "parse_segment/1" do
    test "parse flight segemnt" do
      assert {:ok, flight} =
               Svq.parse_segment("SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10", 1)

      assert flight.type == :flight
      assert flight.from == "SVQ"
      assert flight.to == "BCN"
      assert flight.start_date == "2023-03-02"
      assert flight.start_time == "06:40"
      assert flight.finish_time == "09:10"
      assert flight.reservation_id == 1
    end

    test "parse train segemnt" do
      assert {:ok, segment} =
               Svq.parse_segment("SEGMENT: Train MAD 2023-02-17 17:00 -> SVQ 19:30", 2)

      assert segment.type == :train
      assert segment.from == "MAD"
      assert segment.to == "SVQ"
      assert segment.start_date == "2023-02-17"
      assert segment.start_time == "17:00"
      assert segment.finish_time == "19:30"
      assert segment.reservation_id == 2
    end

    test "parse hotel segment" do
      assert {:ok, segment} = Svq.parse_segment("SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10", 1)
      assert segment.type == :hotel
      assert segment.from == "BCN"
      assert segment.to == "BCN"
      assert segment.start_date == "2023-01-05"
      refute segment.start_time
      refute segment.finish_time
      assert segment.finish_date == "2023-01-10"
      assert segment.reservation_id == 1
    end

    test "when line is not a segment" do
      segment = "Hotel MAD 2023-02-15 -> 2023-02-17"
      assert Svq.parse_segment(segment, 5) == {:error, :invalid_segment, segment}
    end
  end
end
