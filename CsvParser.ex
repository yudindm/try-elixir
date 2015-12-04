defmodule CsvParser do
  @docs """
  Разбор строки значений разделенных запятыми
  """
  def parse(str) do
    parse(String.next_codepoint(str), {:start, [""]})
  end
  
  def parse_chunk(chunk, acc, nil), do: parse_chunk(chunk, acc, {:start, [""]})

  def parse_chunk(chunk, acc, prev_part) do
    case parse(String.next_codepoint(chunk), prev_part) do
      {:ok, record, rest} -> parse_chunk(rest, [record | acc], nil)
      {:error, reason, _} -> {:error, reason}
      next_part -> {:data, acc, next_part}
    end
  end

  def parse(nil, result) do
    result
  end

  def parse({"\"", rest}, {:start, [_ | t]}) do
    parse(String.next_codepoint(rest), {:quot, ["" | t]})
  end
  def parse({",", rest}, {:start, data}) do
    parse(String.next_codepoint(rest), {:start, push_field(data)})
  end
  def parse({" ", rest}, {:start, data}) do
    parse(String.next_codepoint(rest), {:start, push_char(" ", data)})
  end
  def parse({"\n", rest}, {:start, data}) do
    {:ok, :lists.reverse(data), rest}
  end
  def parse({c, rest}, {:start, data}) do
    parse(String.next_codepoint(rest), {:norm, push_char(c, data)})
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
    parse({c, rest}, {:endquot, data})
  end

  def parse({" ", rest}, {:endquot, data}) do
    parse(String.next_codepoint(rest), {:endquot, data})
  end
  def parse({",", rest}, {:endquot, data}) do
    parse(String.next_codepoint(rest), {:start, push_field(data)})
  end
  def parse({"\n", rest}, {:endquot, data}) do
    {:ok, :lists.reverse(data), rest}
  end
  def parse({c, _}, {:endquot, _}) do
    {:error, :invalid_char, c}
  end

  def parse({"\n", rest}, {:norm, data}) do
    {:ok, :lists.reverse(data), rest}
  end
  def parse({",", rest}, {:norm, data}) do
    parse(String.next_codepoint(rest), {:norm, push_field(data)})
  end
  def parse({"\"", _rest}, {:norm, _data}) do
    {:error, :invalid_char, "\""}
  end
  def parse({c, rest}, {:norm, data}) do
    parse(String.next_codepoint(rest), {:norm, push_char(c, data)})
  end

  def push_char(c, [fld | flds]) do
    [fld <> c | flds]
  end
  def push_field(data) do
    ["" | data]
  end
end
