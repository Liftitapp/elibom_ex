defmodule ElibomEx.ClientTest do
  use ExUnit.Case
  use ElibomEx.VcrCase
  alias ElibomEx.{Config, Client}

  describe "deliver_sms/2" do
    test "delivers a sms" do
      use_cassette "dispatched_elibom_sms" do
        response =
          Client.deliver_sms(Config.build!, %{to: "573142272251", text: "Sample SMS"})

          assert response == {:ok, %{"deliveryToken" => "1857014352691220612"}}
      end
    end
  end

  describe "consult_delivery/2" do
    test "fetch the current state of a delivered SMS" do
      use_cassette "consult_delivered_sms" do
        {:ok, response} =
          Client.consult_delivery(Config.build!, "1857014352691220612")

        assert Map.has_key?(response, "deliveryId") == true
        assert Map.has_key?(response, "messages") == true
        assert Map.has_key?(response, "numSent") == true
      end
    end

    test "raise an ArgumentError Exception without a provided delivery id" do
      assert_raise ArgumentError, fn() ->
        Client.consult_delivery(Config.build!, nil)
      end
    end

    test "returns http 404 status if the delivery id does not exists" do
      use_cassette "elibom_not_found_request" do
        {:error, response, status_code} =
          Client.consult_delivery(Config.build!, "fake_delivery_id")

        assert response["code"] == "not_found"
        assert response["description"] != nil
        assert status_code == 404
      end
    end
  end
end
