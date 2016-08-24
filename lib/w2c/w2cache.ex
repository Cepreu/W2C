defmodule W2C.W2Cache do
  use GenServer

  def start_link do
    IO.puts "Starting w2c cache"
    GenServer.start_link(__MODULE__, nil, name: :w2c_cache)
  end

  def w2cession_process(w2cession_name, [{username,pwd}|_] = w2cession_params) do
    if W2C.Authorization.passed?(username, pwd) do
      GenServer.call(:w2c_cache, {:w2cession_process, w2cession_name, w2cession_params})
    else
      nil
    end
  end

#---------------------
# GenServer callbacks
#---------------------
  def init(_) do
    {:ok, nil}
  end

  def handle_call({:w2cession_process, name, params}, _, state) do
    # Sanity check if the server exists:
    w2cession_pid = case W2C.Cervix.whereis(name) do
      :undefined ->
        {:ok, pid} = W2C.CervixSupervisor.start_child(name, params)
        pid
      pid -> pid
    end
    {:reply, w2cession_pid, state}
  end

end
