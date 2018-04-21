## Recurrencex

Simple date recurrences

## Installation
To use Recurrencex with your projects, add it as a dependency in your mix.exs file

```elixir
def deps do
  [
    {:recurrencex, "~> 0.1.0"}
  ]
end
```

## Recurrencex does:

* Repeat every n days

* Repeat on [weekdays] every n weeks

* Repeat on [i, j, k] days every n months

* Repeat on the [i'th weekdays] every n months


## Examples

```elixir
iex> date = Timex.to_datetime({{2018, 4, 20}, {0, 0, 0}}, "America/Toronto")
...> # repeat every 7 days
...> next = Recurrencex.next(date, %Recurrencex{type: :daily, frequency: 7, repeat_on: []})
...> next == Timex.to_datetime({{2018, 4, 27}, {0, 0, 0}}, "America/Toronto")
true

iex> date = Timex.to_datetime({{2018, 4, 20}, {0, 0, 0}}, "America/Toronto")
...> # repeat on Mondays, Wednesdays, Fridays every week
...> next = Recurrencex.next(date, %Recurrencex{type: :weekly, frequency: 1, repeat_on: [1, 3, 5]})
...> # date was a Friday the 20th, the next recurrence would be Monday the 23rd
...> next == Timex.to_datetime({{2018, 4, 23}, {0, 0, 0}}, "America/Toronto")
true

iex> date = Timex.to_datetime({{2018, 4, 20}, {0, 0, 0}}, "America/Toronto")
...> # repeat on the 20th and 25th of every month
...> next = Recurrencex.next(date, %Recurrencex{type: :monthly_day, frequency: 1, repeat_on: [20, 25]})
...> next == Timex.to_datetime({{2018, 5, 20}, {0, 0, 0}}, "America/Toronto")
true

iex> date = Timex.to_datetime({{2018, 4, 20}, {0, 0, 0}}, "America/Toronto")
...> # repeat on the first thursday of every month
...> next = Recurrencex.next(date, %Recurrencex{type: :monthly_dow, frequency: 1, repeat_on: [{4,1}]})
...> next == Timex.to_datetime({{2018, 5, 3}, {0, 0, 0}}, "America/Toronto")
true

iex> r = %Recurrencex{type: :monthly_day, frequency: 12, repeat_on: [20]}
...> Timex.to_datetime({{2018, 4, 20}, {0, 0, 0}}, "America/Toronto")
...> |> Recurrencex.next(r)
...> |> Recurrencex.next(r)
...> next == Timex.to_datetime({{2020, 4, 20}, {0, 0, 0}}, "America/Toronto")
true
```

Documentation: [https://hexdocs.pm/recurrencex](https://hexdocs.pm/recurrencex).

---

## Note:
Behaviour with different days in months (Timex handles this like so)

```elixir
iex> date = Timex.to_datetime({{2018, 1, 30}, {0, 0, 0}}, "America/Toronto")
iex> Timex.shift(date, months: 1)
#DateTime<2018-03-02 00:00:00-05:00 EST America/Toronto>

iex> date = Timex.to_datetime({{2018, 5, 1}, {0, 0, 0}}, "America/Toronto")
iex> Timex.shift(date, months: 1)
#DateTime<2018-07-01 00:00:00-04:00 EDT America/Toronto>
```

Recurrencex will opt to align with the end of the month as defined by Timex.end_of_month in these cases
instead of rolling over to the next month.

```elixir
iex> date = Timex.to_datetime({{2018, 1, 31}, {0, 0, 0}}, "America/Toronto")
iex> r = %Recurrencex{type: :monthly_day, frequency: 1, repeat_on: [31]}
iex> Recurrencex.next(date, r)
#DateTime<2018-02-28 00:00:00-05:00 EST America/Toronto>
```

Repeat on the nth weekday will rollover to the next month if for example there is no 6th Friday in January.

```elixir
iex> date = Timex.to_datetime({{2018, 1, 1}, {0, 0, 0}}, "America/Toronto")
iex> r = %Recurrencex{type: :monthly_dow, frequency: 1, repeat_on: [{5, 6}]}
iex> Recurrencex.next(date, r)
#DateTime<2018-02-09 00:00:00-05:00 EST America/Toronto>
```