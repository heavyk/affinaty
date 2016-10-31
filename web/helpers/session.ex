defmodule Affinaty.Session do
  alias Affinaty.{Repo, Identity}

  def authenticate(%{"ident" => ident, "password" => password}) do
    # ident = Repo.get_by(Identity, ident: String.downcase(ident))
    ident = Repo.get_by(Identity, ident: ident)

    case check_password(ident, password) do
      true -> {:ok, ident}
      _ -> :error
    end
  end

  defp check_password(ident, password) do
    case ident do
      nil -> false # Comeonin.Bcrypt.dummy_checkpw()
      # _ -> Comeonin.Bcrypt.checkpw(password, ident.encrypted_password)
      _ -> ident.hashword == :crypto.hash(:sha256, "chuck norris" <> password <> "crypto-christ") |> Base.encode16 |> String.downcase
    end
  end
end
