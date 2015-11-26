defmodule Notes do
  defmodule Date do
    defstruct day: 0, mon: 0, year: 0
  end
  defmodule Rec do
    defstruct text: nil, date: %Date{}, flag: :none
  end
  def read(filename) do
    File.stream!(filename) |>
    Stream.map(&(&1)) |>
    Enum.to_list()
  end
end
