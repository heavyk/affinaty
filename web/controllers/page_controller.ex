defmodule Affinaty.PageController do
  use Affinaty.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def plugin(conn, params) do
    # render conn, "plugin.html"
    path = Enum.join(params["path"], "/")
    conn = put_layout conn, false
    render conn, "plugin.html", path: path
  end
end
