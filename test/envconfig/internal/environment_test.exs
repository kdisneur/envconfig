defmodule Envconfig.Internal.EnvironmentTest do
  use ExUnit.Case

  [
    %{
      name: "when type is bool and data is false",
      variable: "TOGGLE_FEATURE",
      raw_value: "false",
      type: :bool,
      expected: {:ok, false}
    },
    %{
      name: "when type is bool and data is 0",
      variable: "TOGGLE_FEATURE",
      raw_value: "0",
      type: :bool,
      expected: {:ok, false}
    },
    %{
      name: "when type is bool and data is 1",
      variable: "TOGGLE_FEATURE",
      raw_value: "1",
      type: :bool,
      expected: {:ok, true}
    },
    %{
      name: "when type is bool and data is true",
      variable: "TOGGLE_FEATURE",
      raw_value: "true",
      type: :bool,
      expected: {:ok, true}
    },
    %{
      name: "when type is bool and data is empty",
      variable: "TOGGLE_FEATURE",
      raw_value: "",
      type: :bool,
      expected: {:ok, false}
    },
    %{
      name: "when type is int and data is 1337",
      variable: "ISSUE_ID",
      raw_value: "1337",
      type: :int,
      expected: {:ok, 1337}
    },
    %{
      name: "when type is int and data is -5",
      variable: "THRESHOLD",
      raw_value: "-5",
      type: :int,
      expected: {:ok, -5}
    },
    %{
      name: "when type is int and data is 9h35",
      variable: "HUMAN_TIME",
      raw_value: "9h35",
      type: :int,
      expected:
        {:error,
         %Envconfig.Internal.Parser.InvalidValueError{expected_type: :int, raw_value: "9h35"}}
    },
    %{
      name: "when type is int and data is empty",
      variable: "ISSUE_ID",
      raw_value: "",
      type: :int,
      expected:
        {:error, %Envconfig.Internal.Parser.InvalidValueError{expected_type: :int, raw_value: ""}}
    }
  ]
  |> Enum.each(fn data ->
    test "read: #{data.name}" do
      System.put_env(unquote(data.variable), unquote(data.raw_value))

      assert unquote(Macro.escape(data.expected)) ==
               Envconfig.Internal.Environment.read(unquote(data.variable), unquote(data.type))
    end

    test "read!: #{data.name}" do
      System.put_env(unquote(data.variable), unquote(data.raw_value))

      case unquote(Macro.escape(data.expected)) do
        {:error, error} ->
          assert_raise(error.__struct__, fn ->
            Envconfig.Internal.Environment.read!(
              unquote(data.variable),
              unquote(data.type)
            )
          end)

        {:ok, value} ->
          assert value ==
                   Envconfig.Internal.Environment.read!(
                     unquote(data.variable),
                     unquote(data.type)
                   )
      end
    end
  end)
end
