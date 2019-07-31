defmodule CarPoolingChallengeWeb.ErrorView do
  use CarPoolingChallengeWeb, :view

  def render("405.html", _assigns) do
    "Method not allowed"
  end

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
