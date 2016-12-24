defmodule Affinaty.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias Affinaty.{Repo, Identity}

  def for_token(ident = %Identity{}) do
    IO.puts "for_token!! #{ident.id}"
    { :ok, "Identity:#{ident.id}" }
  end
  def for_token(_), do: { :error, "Unknown resource type" }

  # def from_token("Identity:" <> id), do: { :ok, Repo.get(Identity, String.to_integer(id)) }
  def from_token("Identity:" <> id), do: { :ok, Repo.get(Identity, id) }
  def from_token(_), do: { :error, "Unknown resource type" }
end
