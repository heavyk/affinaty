defmodule Affinaty.IdentityView do
  use Affinaty.Web, :view

  def render("index.json", %{identity: identity}) do
    IO.inspect "index"
    %{data: render_many(identity, Affinaty.IdentityView, "identity.json")}
  end

  def render("show.json", %{identity: identity}) do
    IO.inspect "show"
    %{data: render_one(identity, Affinaty.IdentityView, "identity.json")}
  end

  def render("identity.json", %{identity: identity}) do
    IO.inspect "identity"
    %{id: identity.id,
      hashword: identity.hashword,
      ident: identity.ident,
      created: identity.created,
      mundial: identity.mundial}
  end
end
