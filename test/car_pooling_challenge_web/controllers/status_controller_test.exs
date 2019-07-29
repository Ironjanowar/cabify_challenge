defmodule CarPoolingChallengeWeb.StatusControllerTest do
  use CarPoolingChallengeWeb.ConnCase

  test "Checks status", %{conn: conn} do
    response =
      conn
      |> get(Routes.status_path(conn, :status))
      |> response(200)

    assert response =~ ""
  end
end
