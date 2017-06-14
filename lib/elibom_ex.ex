defmodule ElibomEx do
  @moduledoc """
  Base module for interacting with Elibom's API. Elibom's credentials must
  be provided in your applications project's configuration.

    ## Configuration
    You must provide a configuration which includes your `username` and `password`.

    ```
    config :elibom_ex,
      username: "user@example.com",
      password: "elibom_pass"
    ```
  """
  alias ElibomEx.Client

  def send_sms(body), do: Client.deliver_sms(body)

  def show_sms(id), do: Client.consult_delivery(id)

  def show_scheduled_sms(id), do: Client.consult_scheduled_deliveries(id)

  def cancel_scheduled_sms(id), do: Client.cancel_scheduled_sms(id)

  def show_account, do: Client.consult_account()

  def show_users(id \\ nil), do: Client.consult_users(id)
end
