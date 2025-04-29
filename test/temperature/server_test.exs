defmodule Temperature.ServerTest do
  use ExUnit.Case, async: true

  alias Temperature.Server

  test "fetch_average_for_cities/0 returns the expected averages" do
    assert Server.fetch_average_for_cities() == [
             "São Paulo: 35.0°C",
             "Curitiba: 21.3°C",
             "Belo Horizonte: 18.6°C"
           ]
  end
end
