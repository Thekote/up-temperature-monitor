defmodule Temperature.ReqClient do
  @behaviour Temperature.HttpClient
  def get(url, opts), do: Req.get(url, opts)
end
