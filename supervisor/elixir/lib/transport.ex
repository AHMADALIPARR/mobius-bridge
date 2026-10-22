defmodule Mobius.Transport do
  @protocol_version 1

  def decode(<<len::32, rest::binary>>) when byte_size(rest) == len do
    case rest do
      <<@protocol_version::16, exp_id::binary-size(16), iter::32, dim::16,
        params_bin::binary-size(dim * 4), energy::float-64, unc::float-64,
        digest::binary-size(32), seq::64>> ->
        params = for <<p::float-32 <- params_bin>>, do: p
        computed = :crypto.hash(:sha256, params_bin)

        cond do
          computed != digest ->
            {:error, :digest_mismatch}

          dim != length(params) ->
            {:error, :dim_mismatch}

          true ->
            {:ok,
             %{
               experiment_id: exp_id,
               iteration: iter,
               dim: dim,
               params: params,
               telemetry: %{energy: energy, uncertainty: unc},
               sequence: seq
             }}
        end

      _ ->
        {:error, :malformed}
    end
  end

  def decode(_), do: {:error, :length_prefix}

  def encode_ack(result) do
    payload = :erlang.term_to_binary(result)
    <<byte_size(payload)::32, payload::binary>>
  end

  def encode_reject(reason) do
    payload = :erlang.term_to_binary({:reject, reason})
    <<byte_size(payload)::32, payload::binary>>
  end
end
