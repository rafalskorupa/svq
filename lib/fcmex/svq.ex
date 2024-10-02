defmodule Fcmex.Svq do
  alias Fcmex.TripSegment

  @moduledoc """

  """

  @doc """
  Parses SVQ enumerable to Fcmex.Trip structs

  If any segment or reservation is invalid it return error and doesn't return any sucessfuly parsed
  trips (it could be changed - after `reduce_result` we've got access to sucessfuly parsed data)
  """
  def parse(enum_or_stream) do
    enum_or_stream
    |> stream_parse()
    |> reduce_result()
    |> case do
      {segments, []} ->
        {:ok, Enum.reverse(segments)}

      {_, errors} ->
        {:error, errors}
    end
  end

  @doc """
  Parse SVQ format to Stream

  Expects Svq data elements in Enumerable (with focus on Streams)

  1) Ignores `BASED SVQ` command, so it does not validate whether it present or not
  2) Ignores empty lines
  3) Reservations are kept as reservation_id in each segment - id is just an index of reservation occurence in given data source
  """
  def stream_parse(enum_or_stream) do
    enum_or_stream
    |> Stream.map(&remove_newlines/1)
    |> Stream.filter(&meaningful_line?/1)
    |> chunk_by_reservation()
    |> Stream.flat_map(&parse_reservation/1)
  end

  # Aggregates all lines for given Reservation
  # Each Chunk is indexed by Reservation index for future reference
  defp chunk_by_reservation(collection) do
    collection
    |> Stream.chunk_while(
      {0, []},
      fn element, {reservation_index, acc} ->
        if element == "RESERVATION" do
          # Emit previous chunk, reset current chunk to [] and increase index by 1
          {:cont, {reservation_index, acc}, {reservation_index + 1, []}}
        else
          # Add current segment to chunk
          {:cont, {reservation_index, [element | acc]}}
        end
      end,
      fn
        # Continue with empty acc
        {_, []} = acc -> {:cont, acc}
        # Reverse chunk to keep order as in the source
        {index, acc} -> {:cont, {index, Enum.reverse(acc)}, {index, []}}
      end
    )
    |> Stream.filter(&(&1 != []))
  end

  def parse_reservation({reservation_index, segments}) do
    Enum.map(segments, &parse_segment(&1, reservation_index))
  end

  def parse_reservation(segments) do
    parse_reservation({nil, segments})
  end

  defp reduce_result(result_collection) do
    Enum.reduce(
      result_collection,
      {_parsed = [], _errors = []},
      fn result, {parsed, errors} ->
        case result do
          {:ok, segment} ->
            {[segment | parsed], errors}

          {:error, error_type, error_line} ->
            {parsed, [{error_type, error_line} | errors]}
        end
      end
    )
  end

  @doc """
  Parse segment line to {:ok, %SegmentTrip{}} or return error tuple
  """
  def parse_segment("SEGMENT: Flight " <> data, reservation_index) do
    parse_travel(:flight, data, reservation_index)
  end

  def parse_segment("SEGMENT: Train " <> data, reservation_index) do
    parse_travel(:train, data, reservation_index)
  end

  def parse_segment("SEGMENT: Hotel " <> data, reservation_index) do
    parse_hotel(data, reservation_index)
  end

  def parse_segment(line, _) do
    {:error, :invalid_segment, line}
  end

  defp parse_travel(type, flight_data, reservation_index) do
    case String.split(flight_data, " ") do
      [iata_from, date, start_time, "->", iata_to, finish_time] ->
        {:ok,
         %TripSegment{
           type: type,
           from: iata_from,
           to: iata_to,
           start_date: date,
           start_time: start_time,
           finish_time: finish_time,
           reservation_id: reservation_index
         }}

      _ ->
        {:error, :invalid_segment, flight_data}
    end
  end

  defp parse_hotel(data, reservation_index) do
    case String.split(data, " ") do
      [iata_from, start_date, "->", finish_date] ->
        {:ok,
         %TripSegment{
           type: :hotel,
           from: iata_from,
           to: iata_from,
           start_date: start_date,
           finish_date: finish_date,
           reservation_id: reservation_index
         }}

      _ ->
        {:error, :invalid_hotel, data}
    end
  end

  ### Helpers

  defp remove_newlines(string) do
    String.replace_suffix(string, "\n", "")
  end

  defp meaningful_line?(""), do: false
  defp meaningful_line?("BASED: SVQ"), do: false
  defp meaningful_line?(line), do: line
end
