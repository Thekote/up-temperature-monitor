import Config

config :temperature,
  http_client: Temperature.ReqClient,
  req_options: [],
  max_concurrency: 10,
  http_timeout: 15_000,
  max_attempts: 5,
  backoff_base: 500,
  backoff_factor: 2

config :req,
  http_client: Finch,
  finch_name: Temperature.Finch

import_config "#{config_env()}.exs"
