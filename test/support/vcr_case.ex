defmodule ElibomEx.VcrCase do

  use ExUnit.CaseTemplate

  using do
    quote do
      use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
    end
  end

  setup_all do
    HTTPoison.start
  end

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes")
    :ok
  end
end
