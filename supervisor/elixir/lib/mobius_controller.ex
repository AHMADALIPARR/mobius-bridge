defmodule Mobius.Controller do
  @moduledoc """
  14-round stateful Möbius recursive optimization controller.
  Atomic commit / reject. Never corrupts last valid parameter state.
  """

  use GenServer
  require Logger

  @max_rounds 14
  @phase_bounds {-:math.pi(), :math.pi()}

  defstruct [
    :experiment_id,
    :round,
    :params,
    :best_params,
    :best_energy,
    :audit_log,
    :cancelled
  ]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    dim = Keyword.fetch!(opts, :dim)
    experiment_id = Keyword.get(opts, :experiment_id, generate_id())

    state = %__MODULE__{
      experiment_id: experiment_id,
      round: 0,
      params: List.duplicate(0.0, dim),
      best_params: List.duplicate(0.0, dim),
      best_energy: :infinity,
      audit_log: [],
      cancelled: false
    }

    {:ok, state}
  end

  def run_round(telemetry) do
    GenServer.call(__MODULE__, {:run_round, telemetry}, 60_000)
  end

  def cancel do
    GenServer.cast(__MODULE__, :cancel)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def handle_call({:run_round, telemetry}, _from, state) do
    if state.cancelled or state.round >= @max_rounds do
      {:reply, {:done, state.best_params, state.best_energy, state.audit_log}, state}
    else
      case do_round(state, telemetry) do
        {:ok, new_state, result} ->
          {:reply, {:ok, result}, new_state}

        {:reject, new_state, reason} ->
          {:reply, {:reject, reason}, new_state}

        {:converged, new_state} ->
          {:reply, {:converged, new_state.best_params, new_state.best_energy}, new_state}
      end
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:cancel, state) do
    {:noreply, %{state | cancelled: true}}
  end

  defp do_round(state, telemetry) do
    prev = state.params

    with {:ok, energy, uncertainty} <- validate_telemetry(telemetry),
         {:ok, candidates} <- schedule_and_generate(prev, energy, uncertainty),
         {:ok, candidate} <- select_and_validate(candidates, length(prev)),
         accept? = acceptance_rule(energy, state.best_energy, uncertainty) do
      new_round = state.round + 1

      if accept? do
        new_state = %{
          state
          | round: new_round,
            params: candidate,
            best_params: candidate,
            best_energy: energy,
            audit_log: [{new_round, :commit, candidate, energy} | state.audit_log]
        }

        {:ok, new_state, %{round: new_round, params: candidate, energy: energy}}
      else
        new_state = %{
          state
          | round: new_round,
            audit_log: [{new_round, :reject, candidate, energy} | state.audit_log]
        }

        {:reject, new_state, :energy_worse}
      end
    else
      {:error, reason} ->
        {:reject, state, reason}
    end
  end

  defp validate_telemetry(%{energy: e, uncertainty: u})
       when is_number(e) and is_number(u) and u >= 0 do
    if finite?(e) and finite?(u), do: {:ok, e * 1.0, u * 1.0}, else: {:error, :non_finite}
  end

  defp validate_telemetry(_), do: {:error, :invalid_telemetry}

  defp schedule_and_generate(prev, _obj, _unc) do
    dim = length(prev)

    candidates =
      for i <- 0..(dim - 1) do
        Enum.map(prev, fn p -> p + 0.01 * :math.sin(i + p) end)
      end

    {:ok, candidates}
  end

  defp select_and_validate(candidates, expected_dim) do
    case Enum.find(candidates, fn c ->
           length(c) == expected_dim and
             Enum.all?(c, &finite?/1) and
             Enum.all?(c, fn p ->
               p >= elem(@phase_bounds, 0) and p <= elem(@phase_bounds, 1)
             end)
         end) do
      nil -> {:error, :no_valid_candidate}
      c -> {:ok, c}
    end
  end

  defp acceptance_rule(new_e, best_e, uncertainty) when best_e == :infinity, do: true

  defp acceptance_rule(new_e, best_e, uncertainty) do
    new_e < best_e - 0.5 * uncertainty
  end

  defp finite?(x) when is_number(x), do: x == x and x != :infinity and x != :neg_infinity
  defp finite?(_), do: false

  defp generate_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end
end
