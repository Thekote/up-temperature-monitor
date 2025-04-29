defmodule Temperature.Server do
  use GenServer

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
    max_conc = Application.get_env(:temperature, :max_concurrency)
    timeout = Application.get_env(:temperature, :http_timeout)

    results =
      Task.Supervisor.async_stream(
        Temperature.TaskSupervisor,
        cities,
        &fetch_with_retries/1,
        max_concurrency: max_conc,
        timeout: timeout
      )
      |> Enum.map(&format_task_result/1)

    {:reply, results, cities}
  end

  defp fetch_with_retries(city) do
    max_attempts = Application.get_env(:temperature, :max_attempts)
    base_delay = Application.get_env(:temperature, :backoff_base)

    do_fetch(city, max_attempts, base_delay)
  end

  defp do_fetch(%{name: name}, 0, _delay), do: {:error, name, "max retries reached"}

  defp do_fetch(
         %{name: name, latitude: lat, longitude: lon, timezone: tz} = city,
         attempts,
         delay
       )
       when attempts > 0 do
    url = build_url(lat, lon, tz)
    client = Application.get_env(:temperature, :http_client, Temperature.ReqClient)
    opts = Application.get_env(:temperature, :req_options, [])

    result =
      with {:ok, %{status: 200, body: %{"daily" => %{"temperature_2m_max" => temps}}}} <-
             client.get(url, opts),
           list when list != [] <- Enum.take(temps, 6) do
        {:ok, name, Enum.sum(list) / length(list)}
      else
        {:ok, %{status: _status}} when attempts > 1 ->
          retry(city, attempts, delay)

        {:error, _reason} when attempts > 1 ->
          retry(city, attempts, delay)

        {:ok, _bad} ->
          {:error, name, "bad status"}

        [] ->
          {:error, name, "no data"}

        {:error, reason} ->
          {:error, name, reason}
      end

    case result do
      {:ok, city, avg} -> {:ok, city, Float.round(avg, 1)}
      other -> other
    end
  end

  defp retry(city, attempts, delay) do
    :timer.sleep(delay)
    backoff = Application.get_env(:temperature, :backoff_factor)
    do_fetch(city, attempts - 1, delay * backoff)
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
