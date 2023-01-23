defmodule NginxLivebookUtils.TrafficCounter do
  use GenServer

  ## Client
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def stats_for_chart() do
    GenServer.call(__MODULE__, :for_chart)
  end

  def raw_stats() do
    GenServer.call(__MODULE__, :raw)
  end

  def increment(call_id) do
    GenServer.cast(__MODULE__, {:increment, call_id})
  end

  def clear() do
    GenServer.cast(__MODULE__, :clear)
  end

  def set_id_mappings(mappings) do
    GenServer.cast(__MODULE__, {:set_mappings, mappings})
  end

  ## Server
  @impl true
  def init(:ok) do
    {:ok, %{ id_mappings: %{}, stats: %{} }}
  end

  # Get the request counts formatted for charting
  # [{x: "192.168.0.1", y: 23}, ...]
  @impl true
  def handle_call(:for_chart, _from, %{ id_mappings: id_mappings, stats } = state) do
    data =
      Map.keys(stats)
      |> Enum.map(fn key ->
        label = Map.get(id_mappings, key, key)
        measure = Map.get(stats, key, 0)

        %{x: label, y: measure}
      end)

    {:reply, data, state}
  end

  # Raw data output
  @impl true
  def handle_call(:raw, _from, %{ id_mappings: id_mappings, stats: stats } = state) do
    output = id_mappings |> Enum.reduce(fn {id, mapping}, acc ->
      stat = Map.get(stats, id, 0)
      Map.puts(acc, mapping, stat)
    end)
    |> Map.merge(stats)

    {:reply, output, state}
  end

  # Increments the count for one IP address
  @impl true
  def handle_cast({:increment, ip}, %{ stats: stats } = state) do
    {_val, updated_stats} =
      Map.get_and_update(stats, ip, fn
        nil ->
          {nil, 1}

        current_value ->
          {current_value, current_value + 1}
      end)

    {:noreply, Map.puts(state, :stats, updated_stats)}
  end

  # Clear the counter
  @impl true
  def handle_cast(:clear, _stats) do
    {:noreply, %{}}
  end

  @impl true
  def handle_cast({:set_mappings, mappings}, stats) do
    {:noreply, Map.puts(stats, :id_mappings, mappings)}
  end
end


