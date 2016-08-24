defmodule W2C.Web do
  use Plug.Router

  plug Plug.Parsers, parsers: [:urlencoded, :json],
    pass: ["text/*"],
    json_decoder: Poison
  plug :match
  plug :dispatch

  def start_server do
    case Application.get_env(:w2c, :port) do
      nil -> raise("W2C port not specified!")
      port ->
        Plug.Adapters.Cowboy.http(__MODULE__, nil, port: port)
    end
  end

  # curl 'http://localhost:5454/entries?list=bob&date=20131219'
  get "/entries" do
    conn
    |> Plug.Conn.fetch_query_params
    |> fetch_entries
    |> respond
  end

  defp fetch_entries(conn) do
    Plug.Conn.assign(
      conn,
      :response,
      entries(conn.params["list"], parse_date(conn.params["date"]))
    )
  end

  defp entries(list_name, date) do
    list_name
    |> W2C.Cache.server_process
    |> W2C.Server.entries(date)
    |> format_entries
  end

  defp format_entries(entries) do
    for entry <- entries do
      {y,m,d} = entry.date
      "#{y}-#{m}-#{d}    #{entry.title}"
    end
    |> Enum.join("\n")
  end

  # curl -d '' 'http://localhost:5454/add_entry?list=bob&date=20131219&title=Dentist'
  # post "/add_entry" do

  get "/add_entry" do
    conn
    |> Plug.Conn.fetch_query_params
    |> add_entry
    |> respond
  end

  defp add_entry(conn) do
    conn.params["list"]
    |> W2C.Cache.server_process
    |> W2C.Server.add_entry(
          %{
            date: parse_date(conn.params["date"]),
            title: conn.params["title"]
          }
        )

    Plug.Conn.assign(conn, :response, "OK")
  end

  defp parse_date(
    # Using pattern matching to extract parts from YYYYMMDD string
    << year::binary-size(4), month::binary-size(2), day::binary-size(2) >>
  ) do
    {String.to_integer(year), String.to_integer(month), String.to_integer(day)}
  end

  defp respond(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, conn.assigns[:response])
  end

# ========= curl -d '' 'http://localhost:5454/domains/12345/new_session
  post "/domains/:domain_id/new_session" do
    conn
    |> debug_print
    |> new_cession(domain_id)
    |> respond
  end

  defp new_cession(conn, domain_id) do
    cess_creds = parse_auth(get_auth_header(conn))

    {domain_id, cession_id = UUID.uuid4}
    |> W2C.W2Cache.w2cession_process([cess_creds, conn.body_params])

    Plug.Conn.assign(conn, :response, cession_id)
  end

  defp get_auth_header(conn) do
    get_req_header(conn, "authorization")
  end

  defp parse_auth(["Basic " <> encoded_creds]) do
    {:ok, decoded_creds} = Base.decode64(encoded_creds)
    [user, pwd] = String.split(decoded_creds, ":", parts: 2)
    {user, pwd}
  end
  defp parse_auth(_), do: {nil, nil}

  defp debug_print(conn) do
    IO.puts inspect(conn)
    conn
  end

# =========  curl 'http://localhost:5454/domains/12345/sessions/a1b2c3/?date=20131219'
  get "/domains/:domain_id/sessions/:session_id/add_contact" do
    conn
    |> Plug.Conn.fetch_query_params
    |> fetch_sessions(domain_id, session_id)
    |> respond
  end

  defp fetch_sessions(conn, domain_id, session_id) do
    Plug.Conn.assign(
      conn,
      :response,
      sessions({domain_id, session_id}, parse_date(conn.params["date"]))
    )
  end

  defp sessions(name, date) do
    name
    |> W2C.W2Cache.server_process
    |> W2C.Cervix.entries(date)
    |> format_sessions
  end

  defp format_sessions(sessions) do
    for entry <- sessions do
      {y,m,d} = entry.date
      "#{y}-#{m}-#{d}    #{entry.title}"
    end
    |> Enum.join("\n")
  end

# =========================== 404 NOT FOUND 
  match _ do
    IO.inspect conn
    Plug.Conn.send_resp(conn, 404, "Sorry: Not found")
  end
end
