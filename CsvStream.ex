defmodule CsvStream do
  def as_csv(e) do
    Stream.transform(e,
      fn -> {:start, ""} end,
      &parse_next/2,
      &finalize/1)
  end
  defp parse_next(chunk, acc) do
    case CsvParser.parse(chunk, acc) do
      {:ok, record, rest} -> 
    end
  end
end
