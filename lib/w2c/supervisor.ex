defmodule W2C.Supervisor do
  use Supervisor
  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    processes = [
      supervisor(W2C.Database, []),
      supervisor(W2C.CervixSupervisor, []),
      supervisor(W2C.ServerSupervisor, []),
      worker(W2C.W2Cache, []),
      worker(W2C.Cache, [])
    ]
    supervise(processes, strategy: :one_for_one)
  end
end
