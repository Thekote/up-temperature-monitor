# Temperature

A tiny Elixir application that concurrently fetches 6-day maximum temperature forecasts for a set of cities, computes averages, and exposes a simple GenServer API.

## Features

- Concurrent HTTP requests via `Task.Supervisor.async_stream/4` with configurable concurrency and timeouts.
- Automatic retries with exponential backoff on failed requests.
- Configurable HTTP client (Req + Finch in prod, test stub in test).
- Clean separation of HTTP logic behind a behaviour for easy stubbing and testing.
- Helpers for URL building, response parsing, and result formatting.

## Table of Contents

- [Getting Started](#getting-started)
- [Usage](#usage)
- [Testing](#testing)
- [Project Structure](#project-structure)

## Getting Started

### Prerequisites

- Elixir 1.17+ (compiled with Erlang/OTP 26)
- Erlang/OTP 26
- Internet access for real API calls

### Installation

1. Clone the repo:

   ```bash
   git clone https://github.com/Thekote/up-temperature-monitor
   cd temperature
   ```

2. Install dependencies and compile:

   ```bash
   mix deps.get
   mix compile
   ```

3. Start IEx with the application:

   ```bash
   iex -S mix
   ```

## Usage

Call the public API from IEx:

```elixir
iex> Temperature.Server.fetch_average_for_cities()
["São Paulo: 28.3°C", "Curitiba: 22.1°C", "Belo Horizonte: 26.7°C"]
```

## Testing

Support modules and test clients compile from `test/support`.

Run all tests:

```bash
mix test
```

## Project Structure

```
lib/
  temperature/
    application.ex       # Application entry
    http_client.ex       # HTTP client behaviour
    request_client.ex        # Req + Finch implementation
    server.ex            # GenServer with fetch logic

config/
  config.exs
  dev.exs (optional)
  test.exs
  prod.exs (optional)

test/
  support/
    temperature_test_client.ex
  temperature/
    server_test.exs

mix.exs
README.md
```

