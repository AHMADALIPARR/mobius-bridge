defmodule Benchmark do
  def run do
    {:ok, _} = Mobius.Controller.start_link(dim: 8)

    {us, _} =
      :timer.tc(fn ->
        Enum.each(1..14, fn _ ->
          Mobius.Controller.run_round(%{energy: :rand.uniform(), uncertainty: 0.05})
        end)
      end)

    IO.puts("14-round wall time: #{us / 1000} ms")
    IO.puts("Avg per round: #{us / 14 / 1000} ms")
  end
end

Benchmark.run()
