defmodule Mobius.TCPIngestion do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    port = Keyword.get(opts, :port, 14_014)
    {:ok, listen} = :gen_tcp.listen(port, [:binary, packet: 4, active: false, reuseaddr: true])
    spawn_link(fn -> accept_loop(listen) end)
    Logger.info("TCP ingestion listening on port #{port}")
    {:ok, %{listen: listen}}
  end

  defp accept_loop(listen) do
    {:ok, socket} = :gen_tcp.accept(listen)
    spawn(fn -> handle_client(socket) end)
    accept_loop(listen)
  end

  defp handle_client(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        case Mobius.Transport.decode(data) do
          {:ok, msg} ->
            result = Mobius.Controller.run_round(msg.telemetry)
            encoded = Mobius.Transport.encode_ack(result)
            :gen_tcp.send(socket, encoded)

          {:error, reason} ->
            Logger.warning("Rejected payload: #{inspect(reason)}")
            :gen_tcp.send(socket, Mobius.Transport.encode_reject(reason))
        end

        handle_client(socket)

      {:error, :closed} ->
        :ok
    end
  end
end
