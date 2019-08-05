defmodule CarPoolingChallengeWeb.FallbackController do
  use CarPoolingChallengeWeb, :controller

  @doc """

  This function is called when there is a valid path with a wrong verb

  """
  def invalid_method(conn, _) do
    conn |> send_resp(405, "Method not allowed")
  end
end
