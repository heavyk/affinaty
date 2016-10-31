defmodule Affinaty.SessionController do
  use Affinaty.Web, :controller

  # plug :scrub_params, "session" when action in [:create]
  plug :scrub_params, "ident" when action in [:create]
  plug :scrub_params, "password" when action in [:create]

  def create(conn, %{"ident" => ident, "password" => password}) do
    case Affinaty.Session.authenticate(%{"ident" => ident, "password" => password}) do
      {:ok, ident} ->
        {:ok, jwt, _full_claims} = ident |> Guardian.encode_and_sign(:token)
        IO.inspect jwt

        conn
        |> put_status(:created)
        |> render("show.json", jwt: jwt, ident: ident)

      :error ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json")
    end
  end

  def delete(conn, _) do
    {:ok, claims} = Guardian.Plug.claims(conn)

    conn
    |> Guardian.Plug.current_token
    |> Guardian.revoke!(claims)

    conn
    |> render("delete.json")
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> render(Affinaty.SessionView, "forbidden.json", error: "Not Authenticated")
  end
end
