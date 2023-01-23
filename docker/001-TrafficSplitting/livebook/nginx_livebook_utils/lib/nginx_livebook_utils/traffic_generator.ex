defmodule NginxLivebookUtils.TrafficGenerator do
  @moduledoc """
  Simple module to generate http requests. We use
  https://github.com/elixir-mint/mint since it's very explicit
  about keeping connections open and the like
  """
  def start(opts) do
    # request_count = Keyword.get(opts, :call_count, 1)
    # calls_per_second = Keyword.get(opts, :calls_per_second, 1)
    :ok
  end
end
