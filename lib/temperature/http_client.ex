defmodule Temperature.HttpClient do
  @callback get(String.t(), keyword()) ::
              {:ok, %{status: non_neg_integer(), body: any()}}
              | {:error, any()}
end
