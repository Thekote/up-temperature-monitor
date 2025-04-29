defmodule Temperature.TestClient do
  @behaviour Temperature.HttpClient

  @impl true
  def get(url, _opts) do
    params = url |> URI.parse() |> Map.get(:query) |> URI.decode_query()

    body =
      case params["latitude"] do
        # São Paulo
        "-23.55" ->
          %{"daily" => %{"temperature_2m_max" => [10, 20, 30, 40, 50, 60, 70]}}

        # Curitiba
        "-25.43" ->
          %{"daily" => %{"temperature_2m_max" => [20.5, 22.3, 20, 19.8, 21, 24, 33]}}

        # Belo Horizonte
        "-19.92" ->
          %{"daily" => %{"temperature_2m_max" => [15, 18.1, 19, 21.9, 19, 18.5, 22]}}

        _ ->
          %{"daily" => %{"temperature_2m_max" => []}}
      end

    {:ok, %{status: 200, body: body}}
  end
end
