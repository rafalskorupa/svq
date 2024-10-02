defmodule Fcmex.PrintableTrips do
  def friendly_format(%Fcmex.Trip{} = trip) do
    [
      friendly_header(trip),
      Enum.map(trip.segments, &friendly_description/1)
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end

  def friendly_format(trips) when is_list(trips) do
    trips
    |> Enum.map(&friendly_format/1)
    |> Enum.join("\n\n")
    |> String.replace_suffix("", "\n")
  end

  defp friendly_header(%Fcmex.Trip{segments: [%{from: origin} | _] = _segments} = trip) do
    destinations =
      trip |> destinations() |> Enum.filter(&(&1 != origin))

    "TRIP to #{Enum.join(destinations, ", ")}"
  end

  defp friendly_header(%Fcmex.Trip{}) do
    # Yeah, should be raised
    "TRIP to nowhere"
  end

  defp friendly_type(%Fcmex.TripSegment{type: type}) do
    case type do
      :connected_flight -> "Flight"
      :flight -> "Flight"
      :train -> "Train"
      :hotel -> "Hotel"
    end
  end

  defp friendly_description(%Fcmex.TripSegment{type: type} = segment)
       when type in [:flight, :train] do
    "#{friendly_type(segment)} from #{segment.from} to #{segment.to} at #{segment.start_date} #{segment.start_time} to #{segment.finish_time}"
  end

  defp friendly_description(%Fcmex.TripSegment{type: :hotel} = segment) do
    "#{friendly_type(segment)} at #{segment.from} on #{segment.start_date} to #{segment.finish_date}"
  end

  defp destinations(%Fcmex.Trip{} = trip) do
    trip.segments
    |> Enum.reject(& &1.connection_flight)
    |> Enum.map(& &1.to)
    |> Enum.uniq()
  end
end
