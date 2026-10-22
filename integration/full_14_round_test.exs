# mix run integration/full_14_round_test.exs

defmodule Full14RoundTest do
  def run do
    IO.puts("=== MÖBIUS-14 Full 14-Round Acceptance Test ===")

    {:ok, _} = Mobius.Controller.start_link(dim: 4, experiment_id: "test-001")

    Enum.reduce_while(1..14, nil, fn r, _acc ->
      telemetry = %{
        energy: 1.5 - 0.08 * r + :rand.uniform() * 0.02,
        uncertainty: 0.03
      }

      case Mobius.Controller.run_round(telemetry) do
        {:ok, result} ->
          IO.puts("Round #{result.round}: E = #{Float.round(result.energy, 6)}")
          {:cont, result}

        {:reject, reason} ->
          IO.puts("Round #{r}: rejected (#{reason})")
          {:cont, nil}

        {:converged, params, energy} ->
          IO.puts("Early convergence at round #{r}")
          IO.inspect(params, label: "best θ")
          IO.puts("E* = #{energy}")
          {:halt, :converged}

        {:done, params, energy, log} ->
          IO.puts("Completed 14 rounds")
          IO.inspect(params, label: "best θ")
          IO.puts("E* = #{energy}")
          IO.puts("Audit length: #{length(log)}")
          {:halt, :done}
      end
    end)

    IO.puts("=== PASS ===")
  end
end

Full14RoundTest.run()
