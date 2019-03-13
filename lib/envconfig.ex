defmodule Envconfig do
  defmacro defenv(local_name, env_name, type \\ :string) do
    quote do
      def unquote(:"#{local_name}")(default_type \\ unquote(type)) do
        Envconfig.Internal.Environment.read(unquote(env_name), default_type)
      end

      def unquote(:"#{local_name}!")(default_type \\ unquote(type)) do
        Envconfig.Internal.Environment.read!(unquote(env_name), default_type)
      end
    end
  end

  defmacro __using__([]) do
    quote do
      require Envconfig
      import Envconfig
    end
  end
end
