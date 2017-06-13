defmodule ElibomEx.ClientTest do
  use ExUnit.Case
  use ElibomEx.VcrCase
  alias ElibomEx.{Config, Client}

  describe "deliver_sms/2" do
    test "delivers a sms" do
      use_cassette "dispatched_elibom_sms" do
        response =
          Client.deliver_sms(Config.build!, %{to: "573142272251", text: "Sample SMS"})

          assert response == {:ok, %{"deliveryToken" => "1234567890"}}
      end
    end
  end
end
