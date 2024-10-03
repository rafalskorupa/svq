defmodule Fcmex.Trips do
  alias Fcmex.{Trip, TripSegment}

  @doc """
  Aggregating segments to trip is based sorted segments on:
  * Each segment from must match previous segment destination
  * If both previous and current segment are flight and they are separated by less than 24h 
  previous flight is marked as connection flight

  Chunked segments are parsed to Trip struct - Enum.reverse is used as they are prepended to 
  linked list is more efficient and rather easier

  """
  def aggregate_trips(segments) do
    segments
    |> sort_segments()
    |> Enum.chunk_while(
      {_trip_origin = nil, _trip_segments = []},
      &aggregate_trips_chunk_fn/2,
      &aggregate_trips_after_fn/1
    )
    |> Enum.map(fn trip_segments ->
      %Trip{segments: Enum.reverse(trip_segments)}
    end)
  end

  # Initial state - first segment can be always added and it defines the origin
  defp aggregate_trips_chunk_fn(segment, {nil, []}) do
    acc = {segment.from, [segment]}

    {:cont, acc}
  end

  defp aggregate_trips_chunk_fn(
         segment,
         {origin, [previous_segment | older_segments] = trip_segments}
       ) do
    # Adding segment to existing trip
    segments =
      cond do
        connected_flight?(previous_segment, segment) ->
          # Mark previous flight as connection flight

          previous_segment = %TripSegment{previous_segment | connection_flight: true}

          [segment | [previous_segment | older_segments]]

        previous_segment.to || previous_segment.from == segment.from ->
          # Valid Segment is added to trip

          [segment | trip_segments]

        true ->
          # Trip is missing a segment - destination don't match - just an error segment

          raise "NotImplemented"
      end

    if trip_completed?(origin, segment) do
      # Trip has closed travel "loop" - trip is completed
      # Chunk is emitted and accumulator is cleared
      {:cont, segments, {nil, []}}
    else
      # Continue aggregating
      {:cont, {origin, segments}}
    end
  end

  defp aggregate_trips_after_fn({_origin, trip_segments}) do
    if trip_segments == [] do
      # Empty trip, nothing to emit
      {:cont, {nil, []}}
    else
      {:cont, trip_segments, {nil, []}}
    end
  end

  defp trip_completed?(origin, segment) do
    segment.to == origin
  end

  @doc """
  Sorting is simplest working solution

  Is public function to be testable - maybe it should belong to internal module,
  but I wanted to avoid creating more complex structure of app

  1) As segments are not overlapping we can just compare start_date/start_time
  2) Given date format is sortable by default, so I skipped parsing dates just to cut some corners :)
  3) I assumed Hotel would be the last thing in the day, so just for sorting purposes it happens after all hours during the given day
  """
  def sort_segments(segments) do
    Enum.sort_by(segments, &[&1.start_date, &1.start_time || "24:00"])
  end

  @doc """
  Return boolean whether two segments are connected flights
  (there is less than 24 hours difference between flight segments)
  """
  @seconds_in_day 24 * 60 * 60

  def connected_flight?(%{type: :flight} = segment_1, %{type: :flight} = segment_2) do
    finish_of_segment_1 = TripSegment.finish_datetime!(segment_1)
    start_of_segment_2 = TripSegment.start_datetime!(segment_2)

    DateTime.diff(start_of_segment_2, finish_of_segment_1) <= @seconds_in_day
  end

  def connected_flight?(_, _), do: false
end
