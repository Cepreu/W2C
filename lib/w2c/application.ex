defmodule W2C.Application do
  use Application

  def start(_, _) do
    response = W2C.Supervisor.start_link
    W2C.Web.start_server
    response
  end

end
