defmodule CsvParser do
  @docs """
  Разбор строки значений разделенных запятыми
  """
  def parse(str) do
    parse(String.next_codepoint(str), {:start, [""]})
  end
  
  def parse(nil, result) do
    result
  end
  def parse({"\"", rest}, {:quot, data}) do
    parse(String.next_codepoint(rest), {:qquot, data})
  end
  def parse({c, rest}, {:quot, data}) do
    parse(String.next_codepoint(rest), {:quot, push_char(c, data)})
  end
  def parse({"\"", rest}, {:qquot, data}) do
    parse(String.next_codepoint(rest), {:quot, push_char("\"", data)})
  end
  def parse({c, rest}, {:qquot, data}) do
    parse({c, rest}, {:end, data})
  end
  def parse({"\n", rest}, {_, data}) do
    {:ok, :lists.reverse(data), rest}
  end
  def parse({",", rest}, {:part, data}) do
    parse(String.next_codepoint(rest), push_field(data))
  end
  def parse({"\"", rest}, {:part, data}) do
    parse(String.next_codepoint(rest), {:quot, data})
  end
  def parse({c, rest}, {status, data}) do
    parse(String.next_codepoint(rest), {status, push_char(c, data)})
  end
  def push_char(c, [fld | flds]) do
    [fld <> c | flds]
  end
  def push_field(data) do
    {:part, ["" | data] }
  end
end
