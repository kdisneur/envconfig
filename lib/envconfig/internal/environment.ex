defmodule Envconfig.Internal.Environment do
  @types %{
    bool: &Envconfig.Internal.Parser.to_bool/1,
    int: &Envconfig.Internal.Parser.to_int/1,
    non_empty_bool: &Envconfig.Internal.Parser.to_non_empty_bool/1,
    non_empty_string: &Envconfig.Internal.Parser.to_non_empty_string/1,
    string: &Envconfig.Internal.Parser.to_string/1
  }

  defmodule Error do
    defexception environment_name: nil, expected_type: nil, raw_value: nil

    def message(error) do
      "invalid variable #{error.environment_name}. expected #{error.expected_type}; got '#{
        error.raw_value
      }'"
    end
  end

  def read(name, type \\ :string) do
    case Map.fetch(@types, type) do
      {:ok, parser} ->
        name
        |> System.get_env()
        |> parser.()
        |> rebind_error(name)

      :error ->
        raise "unsupported type: #{type}"
    end
  end

  def read!(name, type \\ :string) do
    case read(name, type) do
      {:ok, value} ->
        value

      {:error, _error} = error ->
        {:error, exception} = rebind_error(error, name)

        raise exception
    end
  end

  defp rebind_error({:ok, _} = valid, _name), do: valid

  defp rebind_error({:error, exception}, name) do
    error = %Error{
      environment_name: name,
      expected_type: exception.expected_type,
      raw_value: exception.raw_value
    }

    {:error, error}
  end
end
