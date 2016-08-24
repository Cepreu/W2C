defmodule W2C.Cession do
  # Internal structure is changed here. Instead of keeping plain list of entries,
  # we split it per each day. This allows us to quickly fetch entries for the
  # given day, but also to reduce the amount of data that must be store to the
  # database on each change.
  defstruct days: HashDict.new, size: 0

  def new(cession_params) do
#    Enum.reduce(
#      entries,
#      %W2C.Cession{},
#      &add_entry(&2, &1)
#    )
     cession_params
  end

  def add_entry(todo_list, entry) do
    %W2C.Cession{todo_list |
      days: HashDict.update(todo_list.days, entry.date, [entry], &[entry | &1]),
      size: todo_list.size + 1
    }
  end

  def entries(%W2C.Cession{days: days}, date) do
    days[date]
  end

  # We need this to restore entries for the given date from the database.
  def set_entries(todo_list, date, entries) do
    %W2C.Cession{todo_list | days: HashDict.put(todo_list.days, date, entries)}
  end
end
