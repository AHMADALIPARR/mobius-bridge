defmodule Mobius.AuditLog do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, []}
  end

  def append(entry) do
    GenServer.cast(__MODULE__, {:append, entry})
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def handle_cast({:append, entry}, log) do
    {:noreply, [entry | log]}
  end

  def handle_call(:all, _from, log) do
    {:reply, Enum.reverse(log), log}
  end
end
