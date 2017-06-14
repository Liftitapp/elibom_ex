defmodule ElibomEx.ClientTest do
  use ExUnit.Case
  use ElibomEx.VcrCase
  alias ElibomEx.Client

  describe "deliver_sms/2" do
    test "delivers a sms" do
      use_cassette "dispatched_elibom_sms" do
        {:ok, response} =
          Client.deliver_sms(%{to: "573142222222", text: "Sample SMS"})

        assert response == %{"deliveryToken" => response["deliveryToken"]}
      end
    end

    test "function supports message scheduling" do
      use_cassette "dispatched_scheduled_sms" do
        {:ok, response} =
          Client.deliver_sms(
            %{to: "573142222222", text: "Sample SMS", "scheduleDate": "2017-06-18 19:10"}
          )

        assert response == %{"scheduleId" => response["scheduleId"]}
      end
    end

    test "Raises ArgumentError if any of the required params is missing" do
      assert_raise ArgumentError, fn() ->
        Client.deliver_sms(%{text: "YOLO"})
      end

      assert_raise ArgumentError, fn() ->
        Client.deliver_sms(%{})
      end

      assert_raise ArgumentError, fn() ->
        Client.deliver_sms(%{to: "572222222"})
      end
    end
  end

  describe "consult_delivery/2" do
    test "fetch the current state of a delivered SMS" do
      use_cassette "consult_delivered_sms" do
        {:ok, response} =
          Client.consult_delivery("1857014352691220612")

        assert Map.has_key?(response, "deliveryId") == true
        assert Map.has_key?(response, "messages") == true
        assert Map.has_key?(response, "numSent") == true
      end
    end

    test "raise an ArgumentError Exception without a provided delivery id" do
      assert_raise ArgumentError, fn() ->
        Client.consult_delivery(nil)
      end
    end

    test "returns http 404 status if the delivery id does not exists" do

      use_cassette "elibom_not_found_request" do
        {:error, response, status_code} =
          Client.consult_delivery("fake_delivery_id")

        assert response["code"] == "not_found"
        assert response["description"] != nil
        assert status_code == 404
      end
    end
  end

  describe "consult_scheduled_deliveries/2" do
    test "fetch the state of a scheduled sms" do
      use_cassette "scheduled_sms_state" do
        {:ok, %{"scheduleId" => scheduled_sms}} =
          Client.deliver_sms(
            %{to: "573145552211", text: "WHOT", "scheduleDate": "2017-06-18 19:10"}
          )

        {:ok, response} =
          Client.consult_scheduled_deliveries(scheduled_sms)

        assert Map.has_key?(response, "creationTime") == true
        assert Map.has_key?(response, "destinations") == true
        assert Map.has_key?(response, "id") == true
        assert Map.has_key?(response, "scheduledTime") == true
        assert Map.has_key?(response, "text") == true

        assert response["text"] == "WHOT"
      end
    end

    test "Raises error if schedule_id is missing" do
      assert_raise ArgumentError, fn() ->
        Client.consult_delivery(nil)
      end
    end
  end

  describe "perform_request/2" do
    test "cancels a scheduled sms" do
      use_cassette "canceled_scheduled_sms" do
        {:ok, %{"scheduleId" => scheduled_sms}} =
          Client.deliver_sms(
            %{to: "573145552211", text: "WHOT", "scheduleDate": "2017-06-18 19:10"}
          )

        response = Client.cancel_scheduled_sms(scheduled_sms)

        assert response == :ok
      end
    end

    test "returns HTTP 404 status if sms cannot be found" do
      use_cassette "canceled_sms_not_found" do
        response = Client.cancel_scheduled_sms("0000")

        assert response ==
          {:error, %{"code" => "not_found", "description" => "null"}, 404}
      end
    end

    test "raises error if the schedule_id is not provided" do
      assert_raise ArgumentError, fn() ->
        Client.cancel_scheduled_sms(nil)
      end
    end
  end

  describe "consult_account/1" do
    test "retrieves the actual account state" do
      use_cassette "consult_account_request" do
        {:ok, response} = Client.consult_account

        assert Map.has_key?(response, "credits") == true
        assert Map.has_key?(response, "name") == true
        assert Map.has_key?(response, "owner") == true
        assert Map.has_key?(response, "type") == true
      end
    end
  end

  describe "consult_users/1" do
    test "fetch related account users" do
      use_cassette "consult_users" do
        {:ok, response} = Client.consult_users

        assert Map.has_key?(hd(response), "email") == true
        assert Map.has_key?(hd(response), "id") == true
        assert Map.has_key?(hd(response), "name") == true
        assert Map.has_key?(hd(response), "status") == true
      end
    end

    test "Fails if the user does not exist in Elibom service" do
      use_cassette "consult_user_by_id" do
        {:error, response, status_code} = Client.consult_users("-1")

        assert response == %{"code" => "not_found", "description" => "null"}
        assert status_code == 404
      end
    end
  end
end
