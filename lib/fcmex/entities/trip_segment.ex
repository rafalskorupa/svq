defmodule Fcmex.TripSegment do
  defstruct [
    :from,
    :to,
    :type,
    :start_date,
    :start_time,
    :finish_date,
    :finish_time,
    :reservation_id,
    :connection_flight
  ]

  @doc """
  Both start_datetime and finish_datetimes requires a little bit work
  1) Instead of NaiveDateTime it would be better to use DateTime due to support for timezones
  2) Maybe it should be calculated before putting them into struct?
  3) Defaults for start_time and finish_time works, but it's a little bit smelly code for me  
  4) Parsing strings to Dates from potentially unsanitized input sounds like a very bad idea for production
  """
  def start_datetime!(%__MODULE__{} = segment) do
    start_time = segment.start_time || "00:00"

    date = Date.from_iso8601!(segment.start_date)
    time = parse_time(start_time)

    {:ok, datetime} = DateTime.new(date, time, "Etc/UTC")
    datetime
  end

  def finish_datetime!(%__MODULE__{} = segment) do
    finish_time = segment.finish_time || "23:59"
    finish_date = segment.finish_date || segment.start_date

    date = Date.from_iso8601!(finish_date)
    time = parse_time(finish_time)

    {:ok, datetime} = DateTime.new(date, time, "Etc/UTC")
    datetime
  end

  def parse_time(time_string) do
    [hours, minutes] = String.split(time_string, ":")
    {:ok, time} = Time.new(String.to_integer(hours), String.to_integer(minutes), 0, 0)
    time
  end
end
