defmodule Envconfig.Internal.ParserTest do
  use ExUnit.Case

  test "to_bool: when parameter is not a valid boolean" do
    assert {:error, error} = Envconfig.Internal.Parser.to_bool("a value")
    assert %Envconfig.Internal.Parser.InvalidValueError{} = error
    assert "a value" == error.raw_value
    assert :non_empty_bool == error.expected_type
  end

  test "to_bool: when parameter is empty and default is not set" do
    assert {:ok, false} = Envconfig.Internal.Parser.to_bool("")
    assert {:ok, false} = Envconfig.Internal.Parser.to_bool(nil)
  end

  test "to_bool: when parameter is empty and default isset" do
    assert {:ok, true} = Envconfig.Internal.Parser.to_bool("", true)
    assert {:ok, true} = Envconfig.Internal.Parser.to_bool(nil, true)
  end

  test "to_bool: when parameter is false" do
    assert {:ok, false} = Envconfig.Internal.Parser.to_bool("false")
    assert {:ok, false} = Envconfig.Internal.Parser.to_bool("0")

    assert {:ok, false} = Envconfig.Internal.Parser.to_bool("false", true)
    assert {:ok, false} = Envconfig.Internal.Parser.to_bool("0", true)
  end

  test "to_bool: when parameter is true" do
    assert {:ok, true} = Envconfig.Internal.Parser.to_bool("true")
    assert {:ok, true} = Envconfig.Internal.Parser.to_bool("1")

    assert {:ok, true} = Envconfig.Internal.Parser.to_bool("true", true)
    assert {:ok, true} = Envconfig.Internal.Parser.to_bool("1", true)
  end

  test "to_int: when parameter is empty" do
    assert {:error, error} = Envconfig.Internal.Parser.to_int("")
    assert %Envconfig.Internal.Parser.InvalidValueError{} = error
    assert "" == error.raw_value
    assert :int == error.expected_type
  end

  test "to_int: when parameter is nil" do
    assert {:error, error} = Envconfig.Internal.Parser.to_int(nil)
    assert %Envconfig.Internal.Parser.InvalidValueError{} = error
    assert nil == error.raw_value
    assert :int == error.expected_type
  end

  test "to_int: when parameter is not an integer" do
    assert {:error, error} = Envconfig.Internal.Parser.to_int("a value")
    assert %Envconfig.Internal.Parser.InvalidValueError{} = error
    assert "a value" == error.raw_value
    assert :int == error.expected_type
  end

  test "to_int: when parameter is not only an integer" do
    assert {:error, error} = Envconfig.Internal.Parser.to_int("10 and a value")
    assert %Envconfig.Internal.Parser.InvalidValueError{} = error
    assert "10 and a value" == error.raw_value
    assert :int == error.expected_type
  end

  test "to_int: when parameter is an integer" do
    assert {:ok, 42} = Envconfig.Internal.Parser.to_int("42")
  end

  test "to_non_empty_bool: when parameter is empty" do
    assert {:error, error} = Envconfig.Internal.Parser.to_non_empty_bool("")
    assert %Envconfig.Internal.Parser.InvalidValueError{} = error
    assert "" == error.raw_value
    assert :non_empty_bool == error.expected_type
  end

  test "to_non_empty_bool: when parameter is nil" do
    assert {:error, error} = Envconfig.Internal.Parser.to_non_empty_bool(nil)
    assert %Envconfig.Internal.Parser.InvalidValueError{} = error
    assert nil == error.raw_value
    assert :non_empty_bool == error.expected_type
  end

  test "to_non_empty_bool: when parameter is not a valid boolean" do
    assert {:error, error} = Envconfig.Internal.Parser.to_non_empty_bool("a value")
    assert %Envconfig.Internal.Parser.InvalidValueError{} = error
    assert "a value" == error.raw_value
    assert :non_empty_bool == error.expected_type
  end

  test "to_non_empty_bool: when parameter is false" do
    assert {:ok, false} = Envconfig.Internal.Parser.to_non_empty_bool("false")
    assert {:ok, false} = Envconfig.Internal.Parser.to_non_empty_bool("0")
  end

  test "to_non_empty_bool: when parameter is true" do
    assert {:ok, true} = Envconfig.Internal.Parser.to_non_empty_bool("true")
    assert {:ok, true} = Envconfig.Internal.Parser.to_non_empty_bool("1")
  end

  test "to_non_empty_string: when parameter is empty" do
    assert {:error, error} = Envconfig.Internal.Parser.to_non_empty_string("")
    assert %Envconfig.Internal.Parser.InvalidValueError{} = error
    assert "" == error.raw_value
    assert :non_empty_string == error.expected_type
  end

  test "to_non_empty_string: when parameter is nil" do
    assert {:error, error} = Envconfig.Internal.Parser.to_non_empty_string(nil)
    assert %Envconfig.Internal.Parser.InvalidValueError{} = error
    assert nil == error.raw_value
    assert :non_empty_string == error.expected_type
  end

  test "to_non_empty_string: when parameter is present" do
    assert {:ok, "a value"} = Envconfig.Internal.Parser.to_non_empty_string("a value")
  end

  test "to_string: when parameter is empty" do
    assert {:ok, ""} = Envconfig.Internal.Parser.to_string("")
    assert {:ok, ""} = Envconfig.Internal.Parser.to_string(nil)
  end

  test "to_string: when parameter is present" do
    assert {:ok, "a value"} = Envconfig.Internal.Parser.to_string("a value")
  end
end
