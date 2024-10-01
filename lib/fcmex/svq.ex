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
  Parse SVQ format

  Expects Svq data elements in Enumerable (with focus on Streams)

  1) Ignores `BASED SVQ` command, so it does not validate whether it present or not
  2) Ignores empty lines
  3) Reservation is delimiter
  """
  def parse(enum_or_stream) do
    enum_or_stream
    |> Stream.map(&remove_newlines/1)
    |> Stream.filter(&meaningful_line?/1)
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

  def parse_segment(line) do
    case line do
      "SEGMENT: Flight " <> data ->
        parse_travel(:flight, data)

      "SEGMENT: Hotel " <> data ->
        parse_hotel(data)

      "SEGMENT: Train " <> data ->
        parse_travel(:train, data)

      _ ->
        {:error, :invalid_segment, line}
    end
  end

  def parse_travel(type, flight_data) do
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
        {:error, :invalid_travel, flight_data}
    end
  end

  def parse_hotel(type \\ :hotel, data) do
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

  defp remove_newlines(string) do
    String.replace_suffix(string, "\n", "")
  end

  defp meaningful_line?(""), do: false
  defp meaningful_line?("BASED: SVQ"), do: false
  defp meaningful_line?(line), do: line
end
