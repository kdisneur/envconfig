defmodule Envconfig.Internal.Parser do
  defmodule InvalidValueError do
    defexception expected_type: nil, raw_value: nil

    def message(error) do
      "invalid configuration value. expected #{error.expected_type} but got '#{error.raw_value}'"
    end
  end

  def to_bool(invalid_value, default \\ false)

  def to_bool(invalid_value, default)
      when is_nil(invalid_value) or invalid_value == "" do
    {:ok, default}
  end

  def to_bool(raw_value, _default) do
    cond do
      String.downcase(raw_value) in ["1", "true"] ->
        {:ok, true}

      String.downcase(raw_value) in ["0", "false"] ->
        {:ok, false}

      true ->
        {:error, %InvalidValueError{expected_type: :non_empty_bool, raw_value: raw_value}}
    end
  end

  def to_int(invalid_value) when is_nil(invalid_value) or invalid_value == "" do
    {:error, %InvalidValueError{expected_type: :int, raw_value: invalid_value}}
  end

  def to_int(raw_value) do
    case Integer.parse(raw_value, 10) do
      {value, ""} ->
        {:ok, value}

      _error ->
        {:error, %InvalidValueError{expected_type: :int, raw_value: raw_value}}
    end
  end

  def to_non_empty_bool(invalid_value) when is_nil(invalid_value) or invalid_value == "" do
    {:error, %InvalidValueError{expected_type: :non_empty_bool, raw_value: invalid_value}}
  end

  def to_non_empty_bool(raw_value) do
    case to_bool(raw_value, nil) do
      {:ok, nil} ->
        {:error, %InvalidValueError{expected_type: :non_empty_bool, raw_value: raw_value}}

      result ->
        result
    end
  end

  def to_non_empty_string(invalid_value) when is_nil(invalid_value) or invalid_value == "" do
    {:error, %InvalidValueError{expected_type: :non_empty_string, raw_value: invalid_value}}
  end

  def to_non_empty_string(value) do
    {:ok, value}
  end

  def to_string(nil) do
    {:ok, ""}
  end

  def to_string(value) do
    {:ok, value}
  end
end
