defmodule Notes do
  defmodule Date do
    defstruct day: 0, mon: 0, year: 0

    def parse(str) do
      [day, mon, year] = String.split(str, ".")
      %Date{day: day, mon: mon, year: year}
    end
  end
  defmodule Rec do
    defstruct text: nil, date: %Date{}, flag: :none

    def create([text, date, flag]) do
      %Rec{text: text, date: Date.parse(date), flag: parse_flag(flag)}
    end
    defp parse_flag(str) do
      case str do
        "" -> :none
        "важная" -> :important
        "особая" -> :urgent
        "обычная" -> :normal
        "низкая" -> :notimportant
      end
    end
  end
  def read(filename) do
    File.stream!(filename) |>
    CsvStream.as_csv() |>
    Stream.map(&(Rec.create(&1))) |>
    Enum.to_list()
  end
end
