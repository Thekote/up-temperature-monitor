import Config

config :temperature,
  http_client: Temperature.TestClient,
  req_options: [],
  max_concurrency: 3,
  http_timeout: 15_000,
  max_attempts: 3,
  backoff_base: 500,
  backoff_factor: 2
