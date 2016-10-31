defmodule Affinaty.Identity do
  use Affinaty.Web, :model

  @derive {Poison.Encoder, only: [:id, :ident, :created, :mundial]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "identity" do
    field :ident,    :string
    field :hashword, :string
    field :created,  :float
    # field :created,  Ecto.DateTime
    field :mundial,  {:array, :binary_id}
  end


  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:ident, :hashword, :created, :mundial])
    # |> validate_required([:hashword])
  end

end
