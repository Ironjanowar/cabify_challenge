defmodule CarPoolingChallengeWeb.FallbackController do
  use CarPoolingChallengeWeb, :controller

  def invalid_method(conn, _) do
    conn |> send_resp(405, "Method not allowed")
  end
end
