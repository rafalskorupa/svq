defmodule Fcmex.Files do
  @spec stream_from_path(String.t()) :: Stream.t()
  def stream_from_path(path) do
    path
    |> File.stream!()
    |> Stream.map(& &1)
  end
end
