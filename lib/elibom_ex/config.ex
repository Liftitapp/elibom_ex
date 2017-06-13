defmodule ElibomEx.Config do
  @moduledoc """
  Stores configuration variables used to communicate with Elibom's API.
  All settings also accept `{:system, "ENV_VAR_NAME"}` to read their
  values from environment variables at runtime.
  """
  alias __MODULE__
  defstruct username: Application.get_env(:elibom_ex, :username),
            password: Application.get_env(:elibom_ex, :password),
            domain: nil

  @typedoc """
  Represents a config structure
  """
  @type t ::  %Config{username: String.t, password: String.t , domain: String.t}

  @doc """
  Fetch environmental data if not found it raises an Exception
  """
  @spec build! :: t
  def build! do
    unless Map.get(%Config{}, :username), do: raise ArgumentError, message: "username not specified"
    unless Map.get(%Config{}, :password), do: raise ArgumentError, message: "password not specified"

    %Config{domain: "https://www.elibom.com/"}
  end
end
