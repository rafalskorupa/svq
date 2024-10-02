defmodule Fcmex.Svq do
  defmodule TravelSegment do
    defstruct [
      :from,
      :to,
      :type,
      :start_date,
      :start_time,
      :finish_date,
      :finish_time
    ]
  end

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
      {trips, []} ->
        {:ok, trips}

      {_, errors} ->
        {:error, errors}
    end
  end

  @doc """
  Parse SVQ format to Stream

  Expects Svq data elements in Enumerable (with focus on Streams)

  1) Ignores `BASED SVQ` command, so it does not validate whether it present or not
  2) Ignores empty lines
  3) Reservation is delimiter
  """
  def stream_parse(enum_or_stream) do
    enum_or_stream
    |> Stream.map(&remove_newlines/1)
    |> Stream.filter(&meaningful_line?/1)
    |> chunk_by_reservation()
    |> Stream.map(&parse_reservation/1)
  end

  # Aggregates all lines for given Reservation
  defp chunk_by_reservation(collection) do
    collection
    |> Stream.chunk_while(
      [],
      fn element, acc ->
        if element == "RESERVATION" do
          {:cont, acc, []}
        else
          {:cont, [element | acc]}
        end
      end,
      fn
        [] -> {:cont, []}
        acc -> {:cont, Enum.reverse(acc), []}
      end
    )
    |> Stream.filter(&(&1 != []))
  end

  def parse_reservation(segments) do
    segments
    |> Enum.map(&parse_segment/1)
    |> reduce_result()
    |> case do
      {segments, []} ->
        {:ok, %Fcmex.Trip{segments: segments}}

      {_, errors} ->
        {:error, errors}
    end
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
  def parse_segment("SEGMENT: Flight " <> data) do
    parse_travel(:flight, data)
  end

  def parse_segment("SEGMENT: Train " <> data) do
    parse_travel(:train, data)
  end

  def parse_segment("SEGMENT: Hotel " <> data) do
    parse_hotel(data)
  end

  def parse_segment(line) do
    {:error, :invalid_segment, line}
  end

  defp parse_travel(type, flight_data) do
    case String.split(flight_data, " ") do
      [iata_from, date, start_time, "->", iata_to, finish_time] ->
        {:ok,
         %TravelSegment{
           type: type,
           from: iata_from,
           to: iata_to,
           start_date: date,
           start_time: start_time,
           finish_time: finish_time
         }}

      _ ->
        {:error, :invalid_segment, flight_data}
    end
  end

  defp parse_hotel(type \\ :hotel, data) do
    case String.split(data, " ") do
      [iata_from, start_date, "->", finish_date] ->
        {:ok,
         %TravelSegment{
           type: type,
           from: iata_from,
           to: iata_from,
           start_date: start_date,
           finish_date: finish_date
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
