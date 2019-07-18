defmodule CarPoolingChallengeWeb.StatusController do
  use CarPoolingChallengeWeb, :controller

  def status(conn, _params) do
    conn |> send_resp(200, "")
  end
end
