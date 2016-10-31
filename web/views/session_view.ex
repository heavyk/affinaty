defmodule Affinaty.SessionView do
  use Affinaty.Web, :view

  def render("show.json", %{jwt: jwt, ident: ident}) do
    # TODO: insert the mundial references -- Repo.all mundial
    %{
      jwt: jwt,
      ident: ident
    }
  end

  def render("error.json", _) do
    %{error: "Invalid email or password"}
  end

  def render("delete.json", _) do
    %{ok: true}
  end

  def render("forbidden.json", %{error: error}) do
    %{error: error}
  end
end
