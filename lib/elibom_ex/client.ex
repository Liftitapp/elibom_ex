defmodule ElibomEx.Client do
  @moduledoc """
  Wrap api calls
  """
  alias ElibomEx.Config

  @typedoc """
  Describes the different type of responses from Elibom's API
  """
  @type http_succeed :: {:ok, map()}
  @type http_error_in_request :: {:error, map(), number()}
  @type http_error_calling_service :: {:error, String.t}
  @type http_empty_response :: :ok

  @doc """
  Requests to Elibom's service to dispatch a new sms.

  Raises `ArgumentError`exception when one or more of the required parameters
  are nil or empty.
  """
  @spec deliver_sms(map) ::
    http_succeed() |
    http_error_in_request() |
    http_error_calling_service() |
    http_empty_response()
  def deliver_sms(request_body) do
    unless Map.get(request_body, :to), do: raise ArgumentError,
      message: "username not specified"
    unless Map.get(request_body, :text), do: raise ArgumentError,
      message: "password not specified"

    perform_request(:POST, "messages", request_body)
  end

  @doc """
  Consults the current state of an already sent sms.

  Raises `ArgumentError`exception if the delivery_id is nil or empty
  """
  @spec consult_delivery(String.t) ::
    http_succeed() |
    http_error_in_request() |
    http_error_calling_service() |
    http_empty_response()
  def consult_delivery(nil), do: raise ArgumentError,
    message: "delivery_id cannot be empty or nil"
  def consult_delivery(delivery_id) do
    perform_request(:GET, "messages/#{delivery_id}")
  end

  @doc """
  Consults the state of an scheduled sms.

  Raises `ArgumentError` exception if the schedule_id is nil or empty
  """
  @spec consult_scheduled_deliveries(String.t) ::
    http_succeed() |
    http_error_in_request() |
    http_error_calling_service() |
    http_empty_response()
  def consult_scheduled_deliveries(nil), do: raise ArgumentError,
    message: "schedule_id cannot be empty or nil"
  def consult_scheduled_deliveries(schedule_id) do
    perform_request(:GET, "schedules/#{schedule_id}")
  end

  @doc"""
  Cancels a scheduled sms

  Raises `ArgumentError` exception if the schedule_id is nil or empty
  """
  @spec cancel_scheduled_sms(String.t) ::
    http_succeed() |
    http_error_in_request() |
    http_error_calling_service() |
    http_empty_response()
  def cancel_scheduled_sms(nil), do: raise ArgumentError,
    message: "schedule_id cannot be empty or nil"
  def cancel_scheduled_sms(schedule_id) do
    perform_request(:DELETE, "schedules/#{schedule_id}")
  end

  @doc"""
  consults account details
  """
  @spec consult_account() ::
    http_succeed() |
    http_error_in_request() |
    http_error_calling_service() |
    http_empty_response()
  def consult_account do
    perform_request(:GET, "account")
  end

  @doc """
  Fetch users attached to the current session
  """
  @spec consult_users(nil) ::
    http_succeed() |
    http_error_in_request() |
    http_error_calling_service() |
    http_empty_response()
  def consult_users do
    perform_request(:GET, "users")
  end

  @spec consult_users(integer()) ::
    http_succeed() |
    http_error_in_request() |
    http_error_calling_service() |
    http_empty_response()
  def consult_users(user_id) do
    perform_request(:GET, "users/#{user_id}")
  end

  defp perform_request(method, service, request_body \\ nil) do
    config = Config.build!

    url = URI.parse(config.domain <> service)

    auth_token = Base.encode64("#{config.username}:#{config.password}")

    headers = [{"Accept", "application/json"}, {"Authorization", "Basic #{auth_token}"}]

    body = Poison.encode!(request_body)

    case HTTPoison.request(method, url, body, headers) do
      {:ok, %HTTPoison.Response{body: body, headers: _, status_code: 200}} when body == "" ->
        :ok
      {:ok, %HTTPoison.Response{body: body, headers: _, status_code: 200}} ->
        {:ok, Poison.decode!(body)}
      {:ok, %HTTPoison.Response{body: body, headers: _, status_code: status_code}} when status_code >= 400 ->
        {:error, Poison.decode!(body), status_code}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Unable to comunicate with Elibom service. Reason: #{reason}"}
    end
  end
end
