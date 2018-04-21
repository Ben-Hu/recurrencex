defmodule RecurrencexTest do
  use ExUnit.Case
  doctest Recurrencex

  describe "monthly_day" do
    setup [:base_date]

    test "day < all repeat_on", %{base_date: base_date} do
      r = %Recurrencex{frequency: 1, repeat_on: [21, 22, 23], type: :monthly_day}
      next = Recurrencex.next(base_date, r)
      assert next === Timex.to_datetime({{2018, 4, 21}, {0, 0, 0}}, "America/Toronto")
    end

    test "day inbetween repeat_on", %{base_date: base_date} do
      r = %Recurrencex{frequency: 2, repeat_on: [5, 10, 25, 30], type: :monthly_day}
      next = Recurrencex.next(base_date, r)
      assert next === Timex.to_datetime({{2018, 4, 25}, {0, 0, 0}}, "America/Toronto")
    end

    test "day > all repeat_on", %{base_date: base_date} do
      r = %Recurrencex{frequency: 3, repeat_on: [1, 2, 3, 4], type: :monthly_day}
      next = Recurrencex.next(base_date, r)
      assert next === Timex.to_datetime({{2018, 7, 1}, {0, 0, 0}}, "America/Toronto")
    end

    test "month rollover" do
      date = Timex.to_datetime({{2018, 1, 31}, {0, 0, 0}}, "America/Toronto")
      r = %Recurrencex{frequency: 1, repeat_on: [30], type: :monthly_day}
      next = Recurrencex.next(date, r)
      assert next === Timex.to_datetime({{2018, 2, 28}, {0, 0, 0}}, "America/Toronto")
    end

    test "date matches" do
      date = Timex.to_datetime({{2018, 4, 1}, {0, 0, 0}}, "America/Toronto")
      r = %Recurrencex{type: :monthly_day, frequency: 1, repeat_on: [1]}
      next = Recurrencex.next(date, r)
      assert next == Timex.to_datetime({{2018, 5, 1}, {0, 0, 0}}, "America/Toronto")
    end
  end

  describe "monthly_dow" do
    test "day < all repeat_on" do
      date = Timex.to_datetime({{2018, 1, 14}, {0, 0, 0}}, "America/Toronto")
      r = %Recurrencex{type: :monthly_dow, frequency: 2, repeat_on: [{5,4}, {4,3}]}
      next = Recurrencex.next(date, r)
      assert next == Timex.to_datetime({{2018, 1, 18}, {0, 0, 0}}, "America/Toronto")
    end

    test "day inbetween repeat_on" do
      date = Timex.to_datetime({{2018, 1, 14}, {0, 0, 0}}, "America/Toronto")
      r = %Recurrencex{type: :monthly_dow, frequency: 2, repeat_on: [{1,1}, {5,4}]}
      next = Recurrencex.next(date, r)
      assert next == Timex.to_datetime({{2018, 1, 26}, {0, 0, 0}}, "America/Toronto")
    end

    test "day > all repeat_on month rollover" do
      date = Timex.to_datetime({{2018, 1, 31}, {0, 0, 0}}, "America/Toronto")
      r = %Recurrencex{type: :monthly_dow, frequency: 1, repeat_on: [{3,4}]}
      next = Recurrencex.next(date, r)
      assert next == Timex.to_datetime({{2018, 2, 28}, {0, 0, 0}}, "America/Toronto")
    end

    test "day > all repeat_on 6mo freq" do
      date = Timex.to_datetime({{2018, 1, 31}, {0, 0, 0}}, "America/Toronto")
      r = %Recurrencex{type: :monthly_dow, frequency: 6, repeat_on: [{3,4}]}
      next = Recurrencex.next(date, r)
      assert next == Timex.to_datetime({{2018, 7, 25}, {0, 0, 0}}, "America/Toronto")
    end

    test "repeat_on sequence order" do
      date = Timex.to_datetime({{2018, 4, 1}, {0, 0, 0}}, "America/Toronto")
      r = %Recurrencex{type: :monthly_dow, frequency: 6, repeat_on: [{1,2}, {2,1}]}
      next = Recurrencex.next(date, r)
      assert next == Timex.to_datetime({{2018, 4, 3}, {0, 0, 0}}, "America/Toronto")
    end

    test "date matches 1" do
      date = Timex.to_datetime({{2018, 4, 1}, {0, 0, 0}}, "America/Toronto")
      r = %Recurrencex{type: :monthly_dow, frequency: 6, repeat_on: [{7,1}, {2,1}]}
      next = Recurrencex.next(date, r)
      assert next == Timex.to_datetime({{2018, 4, 3}, {0, 0, 0}}, "America/Toronto")
    end

    test "date matches 2" do
      date = Timex.to_datetime({{2018, 4, 1}, {0, 0, 0}}, "America/Toronto")
      r = %Recurrencex{type: :monthly_dow, frequency: 6, repeat_on: [{2,1}, {7,1}]}
      next = Recurrencex.next(date, r)
      assert next == Timex.to_datetime({{2018, 4, 3}, {0, 0, 0}}, "America/Toronto")
    end

    test "nth dow does not exist rollover" do
      date = Timex.to_datetime({{2018, 1, 1}, {0, 0, 0}}, "America/Toronto")
      r = %Recurrencex{type: :monthly_dow, frequency: 1, repeat_on: [{5, 6}]}
      next = Recurrencex.next(date, r)
      assert next == Timex.to_datetime({{2018, 2, 9}, {0, 0, 0}}, "America/Toronto")
    end
  end

  describe "weekly" do
    setup [:base_date]

    test "dow < all repeat on", %{base_date: base_date} do
      r = %Recurrencex{frequency: 1, repeat_on: [6, 7], type: :weekly}
      next = Recurrencex.next(base_date, r)
      assert next === Timex.to_datetime({{2018, 4, 21}, {0, 0, 0}}, "America/Toronto")
    end

    test "dow inbetween repeat on", %{base_date: base_date} do
      r = %Recurrencex{frequency: 2, repeat_on: [1, 2, 6, 7], type: :weekly}
      next = Recurrencex.next(base_date, r)
      assert next === Timex.to_datetime({{2018, 4, 21}, {0, 0, 0}}, "America/Toronto")
    end

    test "dow > all repeat on", %{base_date: base_date} do
      r = %Recurrencex{frequency: 3, repeat_on: [1, 2, 3,4], type: :weekly}
      next = Recurrencex.next(base_date, r)
      assert next === Timex.to_datetime({{2018, 5, 7}, {0, 0, 0}}, "America/Toronto")
    end

    test "date matches" do
      date = Timex.to_datetime({{2018, 4, 1}, {0, 0, 0}}, "America/Toronto")
      r = %Recurrencex{type: :weekly, frequency: 1, repeat_on: [7]}
      next = Recurrencex.next(date, r)
      assert next == Timex.to_datetime({{2018, 4, 8}, {0, 0, 0}}, "America/Toronto")
    end

    test "dow rollover", %{base_date: base_date} do
      r = %Recurrencex{frequency: 1, repeat_on: [5], type: :weekly}
      next = Recurrencex.next(base_date, r)
      assert next === Timex.to_datetime({{2018, 4, 27}, {0, 0, 0}}, "America/Toronto")
    end

  end

  describe "daily" do
    setup [:base_date]

    test "1 day", %{base_date: base_date} do
      r = %Recurrencex{frequency: 1, repeat_on: [], type: :daily}
      next = Recurrencex.next(base_date, r)
      assert next === Timex.to_datetime({{2018, 4, 21}, {0, 0, 0}}, "America/Toronto")
    end

    test "1 week", %{base_date: base_date} do
      r = %Recurrencex{frequency: 7, repeat_on: [], type: :daily}
      next = Recurrencex.next(base_date, r)
      assert next === Timex.to_datetime({{2018, 4, 27}, {0, 0, 0}}, "America/Toronto")
    end
  end

  defp base_date(context) do
    base_date = Timex.to_datetime({{2018, 4, 20}, {0, 0, 0}}, "America/Toronto")
    context |> Map.put(:base_date, base_date)
  end

end
