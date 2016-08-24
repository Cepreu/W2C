defmodule W2C.Authorization do
  def passed?(username, pwd) do

    f9req = """ 
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.admin.ws.five9.com/">
   <soapenv:Header/>
   <soapenv:Body>
      <ser:getUsersInfo>
      <userNamePattern>WG</userNamePattern></ser:getUsersInfo>
   </soapenv:Body>
</soapenv:Envelope>
"""
    auth = [hackney: [basic_auth: {username, pwd}]]
    HTTPoison.start
    f9resp = HTTPoison.request(:post, "https://api.five9.com/wsadmin/v4/AdminWebService", f9req, %{}, auth)
    IO.inspect f9resp
    true
  end
end
