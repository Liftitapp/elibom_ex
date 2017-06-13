defmodule ElibomEx.ClientTest do
  use ExUnit.Case
  use ElibomEx.VcrCase
  alias ElibomEx.{Config, Client}

  setup do
    {:ok, config: Config.build!}
  end

  describe "deliver_sms/2" do
    test "delivers a sms", %{config: config} do
      use_cassette "dispatched_elibom_sms" do
        response =
          Client.deliver_sms(config, %{to: "573142222222", text: "Sample SMS"})

          assert response == {:ok, %{"deliveryToken" => "1857014352691220612"}}
      end
    end

    test "function supports message scheduling", %{config: config} do
      use_cassette "dispatched_scheduled_sms" do
        response =
          Client.deliver_sms(
            config,
            %{to: "573142222222", text: "Sample SMS", "scheduleDate": "2017-06-18 19:10"}
          )

        assert response == {:ok, %{"scheduleId" => "1410585"}}
      end
    end

    test "Raises ArgumentError if any of the required params is missing",
      %{config: config} do

      assert_raise ArgumentError, fn() ->
        Client.deliver_sms(config, %{text: "YOLO"})
      end

      assert_raise ArgumentError, fn() ->
        Client.deliver_sms(config, %{})
      end

      assert_raise ArgumentError, fn() ->
        Client.deliver_sms(config, %{to: "572222222"})
      end
    end
  end

  describe "consult_delivery/2" do
    test "fetch the current state of a delivered SMS", %{config: config} do
      use_cassette "consult_delivered_sms" do
        {:ok, response} =
          Client.consult_delivery(config, "1857014352691220612")

        assert Map.has_key?(response, "deliveryId") == true
        assert Map.has_key?(response, "messages") == true
        assert Map.has_key?(response, "numSent") == true
      end
    end

    test "raise an ArgumentError Exception without a provided delivery id",
      %{config: config} do

      assert_raise ArgumentError, fn() ->
        Client.consult_delivery(config, nil)
      end
    end

    test "returns http 404 status if the delivery id does not exists",
      %{config: config} do

      use_cassette "elibom_not_found_request" do
        {:error, response, status_code} =
          Client.consult_delivery(config, "fake_delivery_id")

        assert response["code"] == "not_found"
        assert response["description"] != nil
        assert status_code == 404
      end
    end
  end

  describe "consult_scheduled_deliveries/2" do
    test "fetch the state of a scheduled sms", %{config: config} do
      use_cassette "scheduled_sms_state" do
        {:ok, %{"scheduleId" => scheduled_sms}} =
          Client.deliver_sms(
            config,
            %{to: "573145552211", text: "WHOT", "scheduleDate": "2017-06-18 19:10"}
          )

        {:ok, response} =
          Client.consult_scheduled_deliveries(config, scheduled_sms)

        assert Map.has_key?(response, "creationTime") == true
        assert Map.has_key?(response, "destinations") == true
        assert Map.has_key?(response, "id") == true
        assert Map.has_key?(response, "scheduledTime") == true
        assert Map.has_key?(response, "text") == true

        assert response["text"] == "WHOT"
      end
    end

    test "Raises error if schedule_id is missing", %{config: config} do
      assert_raise ArgumentError, fn() ->
        Client.cancel_scheduled_sms(config, nil)
      end
    end
  end

  describe "perform_request/2" do
    test "cancels a scheduled sms", %{config: config} do
      use_cassette "canceled_scheduled_sms" do
        {:ok, %{"scheduleId" => scheduled_sms}} =
          Client.deliver_sms(
            config,
            %{to: "573145552211", text: "WHOT", "scheduleDate": "2017-06-18 19:10"}
          )

        response = Client.cancel_scheduled_sms(config, scheduled_sms)

        assert response == :ok
      end
    end
  end
end
