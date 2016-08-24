defmodule W2C.Cervix do
  use GenServer

  def start_link(name, parameters) do
    IO.puts "Starting w2cession server for #{inspect(parameters)}"
    GenServer.start_link(W2C.Cervix, [name, parameters], name: via_tuple(name))
  end

  def add_entry(todo_server, new_entry) do
    GenServer.call(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def whereis(name) do
    :gproc.whereis_name({:n, :l, {:todo_server, name}})
  end

  defp via_tuple(name) do
    {:via, :gproc, {:n, :l, {:todo_server, name}}}
  end

#========== GS Callbacks =========

  def init([name, params]) do
    {:ok, {name, W2C.Cession.new(params)}}
  end


  def handle_call({:add_entry, new_entry}, _, {name, todo_list}) do
    new_list =
      todo_list
      |> initialize_entries(name, new_entry.date)
      |> W2C.Cession.add_entry(new_entry)

    # We will store just the entries for the given date, thus reducing the amount
    # of data that needs to be stored. This could have been made even more fine-grained
    # but at the expense of more complex queries, so this is a simplistic trade-off.
    W2C.Database.store(
      {name, new_entry.date},     # The key is now more complex
      W2C.Cession.entries(new_list, new_entry.date)
    )

    {:reply, :ok, {name, new_list}}
  end


  def handle_call({:entries, date}, _, {name, todo_list}) do
    new_list = initialize_entries(todo_list, name, date)
    {:reply, W2C.Cession.entries(new_list, date), {name, new_list}}
  end

  # Needed for testing purposes
  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}

  # Initializes entries for the given date if needed. We use cached data, if we
  # have it. Otherwise, we attempt to load from the database, or use an empty list
  # if nothing is stored in the database.
  defp initialize_entries(todo_list, name, date) do
    case W2C.Cession.entries(todo_list, date) do
      nil ->
        entries = W2C.Database.get({name, date}) || []
        W2C.Cession.set_entries(todo_list, date, entries)

      _found -> todo_list
    end
  end
end
