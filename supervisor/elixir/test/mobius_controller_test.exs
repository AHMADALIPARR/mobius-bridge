defmodule Mobius.ControllerTest do
  use ExUnit.Case, async: false

  setup do
    {:ok, pid} = Mobius.Controller.start_link(dim: 4, experiment_id: "test-001")
    on_exit(fn -> if Process.alive?(pid), do: GenServer.stop(pid) end)
    :ok
  end

  test "runs multiple rounds and accepts improving candidates" do
    result =
      Enum.reduce(1..5, nil, fn r, _ ->
        telemetry = %{energy: 2.0 - 0.2 * r, uncertainty: 0.05}
        Mobius.Controller.run_round(telemetry)
      end)

    assert match?({:ok, %{round: 5}}, result) or match?({:done, _, _, _}, result)
  end

  test "rejects non-finite telemetry" do
    assert {:reject, :non_finite} =
             Mobius.Controller.run_round(%{energy: :nan, uncertainty: 0.1})
  end

  test "never exceeds 14 rounds" do
    Enum.each(1..20, fn r ->
      Mobius.Controller.run_round(%{energy: 1.0 - 0.01 * r, uncertainty: 0.01})
    end)

    state = Mobius.Controller.get_state()
    assert state.round <= 14
  end
end
