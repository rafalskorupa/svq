defmodule Fcmex.Files do
  @spec stream(String.t()) :: Stream.t()
  def stream(path) do
    path
    |> File.stream!()
    |> Stream.map(& &1)
  end
end
