defmodule RabbitMQ.CloudWatchExporter.ConnectionMetrics do
  @moduledoc """
  Collects Connection related metrics.
  """

  require RabbitMQ.CloudWatchExporter.Common

  alias :rabbit_mgmt_db, as: RabbitMGMTDB
  alias RabbitMQ.CloudWatchExporter.Common, as: Common

  @doc """
  Collect Connection metrics in AWS CW format.
  """
  @spec collect_connection_metrics() :: List.t
  def collect_connection_metrics() do
    RabbitMGMTDB.get_all_connections(Common.no_range)
      |> Enum.flat_map(&connection_metrics/1)
  end

  defp connection_metrics(connection) do
    metrics =
      [
        [metric_name: "Channels",
         unit: "Count",
         value: Keyword.get(connection, :channels, 0)],
        [metric_name: "Sent",
         unit: "Count",
         value: Keyword.get(connection, :send_cnt, 0)],
        [metric_name: "Received",
         unit: "Count",
         value: Keyword.get(connection, :recv_cnt, 0)],
        [metric_name: "BytesSent",
         unit: "Bytes",
         value: Keyword.get(connection, :send_oct, 0)],
        [metric_name: "BytesReceived",
         unit: "Bytes",
         value: Keyword.get(connection, :recv_oct, 0)],
      ]
    dimensions = [{"Metric", "Connection"},
                  {"Node", Keyword.get(connection, :node)},
                  {"Connection", Keyword.get(connection, :name)},
                  {"Protocol", Keyword.get(connection, :protocol)},
                  {"AuthMechanism", Keyword.get(connection, :auth_mechanism)},
                  {"User", Keyword.get(connection, :user)},
                  {"VHost", Keyword.get(connection, :vhost)}]

    Enum.map(metrics, fn(m) -> m ++ [dimensions: dimensions] end)
  end
end
