defmodule Recurrencex do
  @moduledoc """
  Simple date recurrences
  """
  require Logger

  @enforce_keys [
    :frequency,
    :repeat_on,
    :type
  ]

  defstruct [
    :frequency,
    :repeat_on,
    :type
  ]

  @type t :: %__MODULE__{
    type: atom,
    frequency: integer,
    repeat_on: [integer] | [{integer, integer}]
  }

  @doc """
  A function that finds the date of the next occurence after 'date' with recurrence 'recurrencex'

  ## Examples

  ```elixir
  iex> date = Timex.to_datetime({{2018, 4, 20}, {0, 0, 0}}, "America/Toronto")
  ...> # repeat every 7 days
  ...> next = Recurrencex.next(date, %Recurrencex{type: :daily, frequency: 7, repeat_on: []})
  ...> next == Timex.to_datetime({{2018, 4, 27}, {0, 0, 0}}, "America/Toronto")
  true

  iex> date = Timex.to_datetime({{2018, 4, 20}, {0, 0, 0}}, "America/Toronto")
  ...> # repeat on Mondays, Wednesdays, Fridays every week
  ...> recurrencex = %Recurrencex{type: :weekly, frequency: 1, repeat_on: [1, 3, 5]}
  ...> next = Recurrencex.next(date, recurrencex)
  ...> # date was a Friday the 20th, the next recurrence would be Monday the 23rd
  ...> next == Timex.to_datetime({{2018, 4, 23}, {0, 0, 0}}, "America/Toronto")
  true

  iex> date = Timex.to_datetime({{2018, 4, 20}, {0, 0, 0}}, "America/Toronto")
  ...> # repeat on the 20th and 25th of every month
  ...> recurrencex = %Recurrencex{type: :monthly_day, frequency: 1, repeat_on: [20, 25]}
  ...> next = Recurrencex.next(date, recurrencex)
  ...> next == Timex.to_datetime({{2018, 4, 25}, {0, 0, 0}}, "America/Toronto")
  true

  iex> date = Timex.to_datetime({{2018, 4, 20}, {0, 0, 0}}, "America/Toronto")
  ...> # repeat on the first Thursday of every month
  ...> recurrencex = %Recurrencex{type: :monthly_dow, frequency: 1, repeat_on: [{4,1}]}
  ...> next = Recurrencex.next(date, recurrencex)
  ...> next == Timex.to_datetime({{2018, 5, 3}, {0, 0, 0}}, "America/Toronto")
  true

  iex> r = %Recurrencex{type: :monthly_day, frequency: 12, repeat_on: [20]}
  ...> next = Timex.to_datetime({{2018, 4, 20}, {0, 0, 0}}, "America/Toronto")
  ...> |> Recurrencex.next(r)
  ...> |> Recurrencex.next(r)
  ...> next == Timex.to_datetime({{2020, 4, 20}, {0, 0, 0}}, "America/Toronto")
  true
  ```

  """
  @spec next(%DateTime{}, %Recurrencex{}) :: %DateTime{}
  def next(date, recurrencex) do
    next_occurence(date, recurrencex)
  end

  defp next_occurence(date, %Recurrencex{type: :daily} = recurrencex) do
    Timex.shift(date, [days: recurrencex.frequency])
  end

  defp next_occurence(date, %Recurrencex{type: :weekly} = recurrencex) do
    dow = Timex.weekday(date)
    day_shift = next_in_sequence(dow, Enum.sort(recurrencex.repeat_on)) - dow
    cond do
      day_shift <= 0 ->
        Timex.shift(date, [days: day_shift, weeks: recurrencex.frequency])
      day_shift > 0 ->
        Timex.shift(date, [days: day_shift])
    end
  end

  defp next_occurence(date, %Recurrencex{type: :monthly_day} = recurrencex) do
    day_shift = next_in_sequence(date.day, Enum.sort(recurrencex.repeat_on)) - date.day
    cond do
      day_shift <= 0 ->
        shifted_date = Timex.shift(date, [days: day_shift, months: recurrencex.frequency])
        if shifted_date.month == rem(date.month + recurrencex.frequency, 12) do
          shifted_date
        else
          Timex.shift(shifted_date, [days: -3])
          |> Timex.end_of_month
          |> Timex.set([
            hour: date.hour,
            minute: date.minute,
            second: date.second,
            microsecond: date.microsecond
          ])
        end
      day_shift > 0 ->
        Timex.shift(date, [days: day_shift])
    end
  end

  defp next_occurence(date, %Recurrencex{type: :monthly_dow} = recurrencex) do
    base_pair = {Timex.weekday(date), nth_dow(date)}
    repeat_on = Enum.sort(recurrencex.repeat_on, fn {_a, b}, {_x, y} -> b < y end)
    {dow, n} = next_in_tuple_sequence(base_pair, repeat_on, Timex.beginning_of_month(date))
    cond do
      n >= nth_dow(date) ->
        date_of_nth_dow(Timex.beginning_of_month(date), dow, n)
      n < nth_dow(date) ->
        shifted_date = Timex.shift(date, [months: recurrencex.frequency])
        if shifted_date.month == date.month + recurrencex.frequency do
          date_of_nth_dow(Timex.beginning_of_month(shifted_date), dow, n)
        else
          # Offset by 3 to be safe we don't skip a month (February/30/31th) because of the way
          # Timex shifts by months
          start_date = shifted_date
          |> Timex.shift([days: -3])
          |> Timex.beginning_of_month
          |> Timex.set([
            hour: date.hour,
            minute: date.minute,
            second: date.second,
            microsecond: date.microsecond
          ])
          date_of_nth_dow(start_date, dow, n)
        end
    end
  end

  defp date_of_nth_dow(date, dow, n) do
    cond do
      Timex.weekday(date) == dow and n == 1 -> date
      Timex.weekday(date) == dow -> date_of_nth_dow(Timex.shift(date, [weeks: 1]), dow, n - 1)
      Timex.weekday(date) != dow -> date_of_nth_dow(Timex.shift(date, [days: 1]), dow, n)
    end
  end

  defp nth_dow(date) do
    Enum.filter(1..5, fn n -> nth_dow?(date, n) end)
    |> Enum.at(0)
  end

  defp nth_dow?(date, n) do
    date == date_of_nth_dow(Timex.beginning_of_month(date), Timex.weekday(date), n)
  end

  defp next_in_tuple_sequence(base, sequence, date) do
    {base_x, base_y} = base
    sequence
    |> Enum.find(Enum.at(sequence, 0), fn {x, y} ->
      cond do
        y == base_y ->
          Timex.compare(date_of_nth_dow(date, base_x, base_y), date_of_nth_dow(date, x, y)) == -1
        y > base_y -> true
        y < base_y -> false
      end
    end)
  end

  defp next_in_sequence(base, sequence) do
    sequence
    |> Enum.find(Enum.at(sequence, 0), fn x -> x > base end)
  end

end
