defmodule W2C.Database do
  @pool_size 3

  def start_link do
    # Initializes the mnesia database.
    :mnesia.stop    # First we stop mnesia, so we can create the schema.
    :mnesia.create_schema([node()])
    :mnesia.start
    :mnesia.create_table(:todo_lists, [attributes: [:name, :list], disc_only_copies: [node()]])
    :ok = :mnesia.wait_for_tables([:todo_lists], 5000)

    W2C.PoolSupervisor.start_link(@pool_size)
  end

  def store(key, data) do
    W2C.DatabaseWorker.store(choose_worker(key), key, data)
  end

  def get(key) do
    W2C.DatabaseWorker.get(choose_worker(key), key)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
