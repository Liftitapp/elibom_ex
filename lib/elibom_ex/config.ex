defmodule ElibomEx.Config do
  @moduledoc """
  Stores configuration variables used to communicate with Elibom's API.
  All settings also accept `{:system, "ENV_VAR_NAME"}` to read their
  values from environment variables at runtime.
  """

  @typedoc """
  Represents a config structure
  """
  @type t ::  %{username: String.t, password: String.t , domain: String.t}

  @doc """
  Fetch environmental data if not found it raises an Exception
  """
  @spec build!(String.t) :: t | no_return()
  def build!(domain \\ "https://www.elibom.com/") do
    %{
      username: fetch_variable!(:username),
      password: fetch_variable!(:password),
      domain: domain
    }
  end

  defp fetch_variable!(value) do
    Application.get_env(:elibom_ex, value) ||
      raise(ArgumentError, message: "#{value} not specified")
  end
end
