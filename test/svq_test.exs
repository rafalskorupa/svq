defmodule Fcmex.SvqTest do
  use ExUnit.Case, async: true

  alias Fcmex.Svq

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

    test "returns batched groups of segments for each reservation" do
      assert %Stream{} = stream = Svq.parse(@example_svq)

      assert Enum.to_list(stream) == [
               ["SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10"],
               ["SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10"],
               [
                 "SEGMENT: Flight BCN 2023-01-10 10:30 -> SVQ 11:50",
                 "SEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10"
               ],
               [
                 "SEGMENT: Train MAD 2023-02-17 17:00 -> SVQ 19:30",
                 "SEGMENT: Train SVQ 2023-02-15 09:30 -> MAD 11:00"
               ],
               ["SEGMENT: Hotel MAD 2023-02-15 -> 2023-02-17"],
               [
                 "SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45",
                 "SEGMENT: Flight NYC 2023-03-06 08:00 -> BOS 09:25"
               ]
             ]
    end
  end

  describe "parse_segment/1" do
    test "parse flight segemnt" do
      assert {:ok, flight} =
               Svq.parse_segment("SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10")

      assert flight.type == :flight
      assert flight.from == "SVQ"
      assert flight.to == "BCN"
      assert flight.start_date == "2023-03-02"
      assert flight.start_time == "06:40"
      assert flight.finish_time == "09:10"
    end

    test "parse train segemnt" do
      assert {:ok, segment} =
               Svq.parse_segment("SEGMENT: Train MAD 2023-02-17 17:00 -> SVQ 19:30")

      assert segment.type == :train
      assert segment.from == "MAD"
      assert segment.to == "SVQ"
      assert segment.start_date == "2023-02-17"
      assert segment.start_time == "17:00"
      assert segment.finish_time == "19:30"
    end

    test "parse hotel segment" do
      assert {:ok, segment} = Svq.parse_segment("SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10")
      assert segment.type == :hotel
      assert segment.from == "BCN"
      assert segment.to == "BCN"
      assert segment.start_date == "2023-01-05"
      refute segment.start_time
      refute segment.finish_time
      assert segment.finish_date == "2023-01-10"
    end

    test "when line is not a segment" do
      segment = "Hotel MAD 2023-02-15 -> 2023-02-17"
      assert Svq.parse_segment(segment) == {:error, :invalid_segment, segment}
    end
  end
end
