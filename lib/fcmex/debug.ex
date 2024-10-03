defmodule FcmexDebug do
  def debug_segments(segments) do
    Enum.each(segments, &debug_segment/1)

    segments
  end

  def debug_segment(segment) do
    IO.inspect("#{segment.type} #{segment.from} -> #{segment.to} #{segment.start_date}")
  end
end
