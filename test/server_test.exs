defmodule Temperature.ServerTest do
  use ExUnit.Case, async: true
  import Req.Test
  alias Temperature.Server

  setup do
    Application.put_env(:temperature, :req_test_owner, self())

    Application.put_env(:temperature, :req_options, plug: {Req.Test, Temperature.Server})

    {:ok, _} = Application.ensure_all_started(:temperature)
    :ok
  end

  test "fetch_average_for_cities/0 returns city-specific averages" do
    stub(Temperature.Server, fn conn ->
      params = URI.decode_query(conn.query_string)

      case params["latitude"] do
        "-23.55" ->
          json(conn, %{"daily" => %{"temperature_2m_max" => [10, 20, 30, 40, 50, 60, 70]}})

        "-25.43" ->
          json(conn, %{"daily" => %{"temperature_2m_max" => [20, 22, 21, 24, 27, 30, 33]}})

        "-19.92" ->
          json(conn, %{"daily" => %{"temperature_2m_max" => [15, 17, 19, 21, 18, 20, 30]}})

        _ ->
          json(conn, %{"daily" => %{"temperature_2m_max" => []}})
      end
    end)

    assert Server.fetch_average_for_cities() == [
             "São Paulo: 35.0°C",
             "Curitiba: 24.0°C",
             "Belo Horizonte: 18.3°C"
           ]
  end
end
