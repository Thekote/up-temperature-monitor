defmodule Temperature.Server do
  use GenServer

  @max_concurrency 3
  @timeout 15_000

  @max_attempts 3
  @initial_backoff 500
  @backoff_factor 2

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, city_list(), name: __MODULE__)
  end

  def fetch_average_for_cities do
    GenServer.call(__MODULE__, :fetch)
  end

  @impl true
  def init(cities), do: {:ok, cities}

  @impl true
  def handle_call(:fetch, _from, cities) do
    results =
      Task.Supervisor.async_stream(
        Temperature.TaskSupervisor,
        cities,
        &fetch_city_avg/1,
        max_concurrency: @max_concurrency,
        timeout: @timeout
      )
      |> Enum.map(&format_task_result/1)

    {:reply, results, cities}
  end

  defp fetch_city_avg(city) do
    do_fetch(city, @max_attempts, @initial_backoff)
  end

  defp do_fetch(%{name: name}, 0, _delay) do
    {:error, name, "max retries reached"}
  end

  defp do_fetch(
         %{name: name, latitude: lat, longitude: lon, timezone: tz} = city,
         attempts,
         delay
       ) do
    if owner = Application.get_env(:temperature, :req_test_owner) do
      Req.Test.allow(Temperature.Server, owner, self())
    end

    url = build_url(lat, lon, tz)

    opts = Application.get_env(:temperature, :req_options, [])

    case Req.get(url, opts) do
      {:ok, %{status: 200, body: %{"daily" => %{"temperature_2m_max" => temps}}}} ->
        parse_temps(temps, name)

      {:ok, %{status: _status}} when attempts > 1 ->
        :timer.sleep(delay)
        do_fetch(city, attempts - 1, delay * @backoff_factor)

      {:error, _} = _err when attempts > 0 ->
        :timer.sleep(delay)
        do_fetch(city, attempts - 1, delay * @backoff_factor)

      {:ok, %{status: status}} ->
        {:error, name, "status #{status}"}

      {:error, reason} ->
        {:error, name, reason}
    end
  end

  defp parse_temps(temps, name) do
    case Enum.take(temps, 6) do
      [] ->
        {:error, name, "no data"}

      list ->
        avg = Enum.sum(list) / length(list)
        {:ok, name, Float.round(avg, 1)}
    end
  end

  defp format_task_result({:ok, {:ok, city, avg}}), do: "#{city}: #{avg}°C"

  defp format_task_result({:ok, {:error, city, reason}}),
    do: "#{city}: Error – #{inspect(reason)}"

  defp format_task_result({:exit, reason}), do: "Task crashed: #{inspect(reason)}"

  defp build_url(lat, lon, tz) do
    URI.to_string(%URI{
      scheme: "https",
      host: "api.open-meteo.com",
      path: "/v1/forecast",
      query:
        URI.encode_query(%{
          latitude: lat,
          longitude: lon,
          daily: "temperature_2m_max",
          timezone: tz
        })
    })
  end

  defp city_list do
    [
      %{name: "São Paulo", latitude: -23.55, longitude: -46.63, timezone: "America/Sao_Paulo"},
      %{name: "Curitiba", latitude: -25.43, longitude: -49.27, timezone: "America/Sao_Paulo"},
      %{
        name: "Belo Horizonte",
        latitude: -19.92,
        longitude: -43.94,
        timezone: "America/Sao_Paulo"
      }
    ]
  end
end
