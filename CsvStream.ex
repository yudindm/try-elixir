defmodule CsvStream do
  def as_csv(e) do
    Stream.transform(e, nil, &parse_next/2)
  end
  defp parse_next(chunk, acc) do
    case CsvParser.parse_chunk(chunk, [], acc) do
      {:data, records, rest} -> {records, rest} 
      {:error, _} -> {:halt, nil}
    end
  end
end
