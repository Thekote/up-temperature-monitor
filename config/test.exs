import Config

config :temperature, :req_options, plug: {Req.Test, Temperature.Server}
