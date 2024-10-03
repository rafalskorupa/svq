defmodule Mix.Tasks.Convert.FromSvq do
  @moduledoc "The hello mix task: `mix convert_from_svq <input_file>"
  use Mix.Task

  require Logger


  @shortdoc "Converts svq from file under first argument path and stores in the second argument file path (or Log it terminal)"
  def run(args) do
    %{input: input, output: output_fn} = parse_args(args)

    with {:stream, %Stream{} = stream} <- {:stream, Fcmex.Files.stream_from_path(input)},
         {:trips, {:ok, trips}} <- {:trips, Fcmex.Svq.parse(stream)}
          do
      trips
      |> Fcmex.Trips.aggregate_trips()
      |> Fcmex.PrintableTrips.friendly_format()
      |> output_fn.()
    else
      {:stream, _} ->
        Logger.error("File cannot be read")

      {:trips, {:error, errors}} ->
        Logger.error("SVQ file cannot be parsed")
        
        Enum.each(errors, fn {error_name, segment} ->
          Logger.error("[#{error_name}] #{segment}")
        end)
    end
  end

  defp parse_args([input_file, output_file]) do
    %{
      input: input_file,
      output: fn result -> Fcmex.Files.write_to_file(output_file, result) end
    }
  end

  defp parse_args([input_file]) do
    %{input: input_file, output: &IO.puts/1}
  end

  defp parse_args(_) do
    %{input: "./input.txt", output: &IO.puts/1}
  end
end
