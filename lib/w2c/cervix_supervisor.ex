
defmodule W2C.CervixSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil,
      name: :w2c_server_supervisor
    )
  end

  def start_child(w2cession_name, w2cession_params) do
    Supervisor.start_child(
      :w2c_server_supervisor,
      [w2cession_name, w2cession_params]
    )
  end

  def init(_) do
    supervise(
      [worker(W2C.Cervix, [])],
      strategy: :simple_one_for_one
    )
  end
end

