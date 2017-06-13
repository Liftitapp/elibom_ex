defmodule ElibomEx.Client do
  @moduledoc """
  Wrap api calls
  """
  alias ElibomEx.Config

  @spec deliver_sms(%Config{}, map) ::
    {:ok, map()} | {:error, String.t} | {:error, String.t}
  def deliver_sms(config, request_body) do
    case perform_request(:post, config, "/messages", request_body) do
      {:ok, %HTTPoison.Response{body: body, headers: _, status_code: 200}} ->
        {:ok, Poison.decode!(body)}
      {:ok, %HTTPoison.Response{body: body, headers: _, status_code: status_code}} when status_code >= 400 ->
        {:error, body, code: status_code}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Unable to comunicate with Elibom service. Reason: #{reason}"}
    end
  end

  defp perform_request(method, config, service, request_body) do
    url = URI.parse(config.domain <> service)
    auth_token = Base.encode64("#{config.username}:#{config.password}")
    headers = [{"Accept", "application/json"}, {"Authorization", "Basic #{auth_token}"}]

    body = Poison.encode!(request_body)

    HTTPoison.request(method, url, body, headers)
  end
end
