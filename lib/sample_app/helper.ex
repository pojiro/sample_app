defmodule SampleApp.Helper do
  @doc false
  def random_string(length \\ 64) do
    # see https://github.com/phoenixframework/phoenix/blob/master/lib/mix/tasks/phx.gen.secret.ex
    # literal copy of mix phx.gen.secret implementation.
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  @doc false
  def convert_to_atom_key_map(module, map) when is_atom(module) and is_map(map) do
    converted =
      module
      |> Map.from_struct()
      |> Map.keys()
      |> Enum.reduce(%{}, fn key, acc ->
        string_key = to_string(key)

        cond do
          Map.has_key?(map, string_key) -> Map.put(acc, key, map[string_key])
          true -> acc
        end
      end)

    if converted == %{} do
      map
    else
      converted
    end
  end
end
