defmodule CarPoolingChallengeWeb.PageController do
  use CarPoolingChallengeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
