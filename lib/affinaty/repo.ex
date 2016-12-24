# defmodule Affinaty.Repo do
#   use Ecto.Repo, otp_app: :affinaty
# end

defmodule Affinaty.Repo do
  use Ecto.Repo,
    otp_app: :affinaty,
    adapter: Mongo.Ecto
end

# defmodule Weather do
#   use Ecto.Schema
#
#   @primary_key {:id, :binary_id, autogenerate: true}
#   schema "weather" do
#     field :city     # Defaults to type :string
#     field :temp_lo, :integer
#     field :temp_hi, :integer
#     field :prcp,    :float, default: 0.0
#   end
# end

defmodule Affinaty.Opinion do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "opinion" do
    field :creator, :binary_id
    field :debate,  :binary_id
    field :created, :float
    field :pos,     :integer
  end
end

# defmodule Affinaty.Identity do
#   use Ecto.Schema
#
#   @primary_key {:id, :binary_id, autogenerate: true}
#   schema "identity" do
#     field :ident
#     field :hashword
#     field :created, :float
#     field :mundial, {:array, :binary_id}
#   end
# end

defmodule Simple do
  import Ecto.Query

  def opinions do
    query = from o in Affinaty.Opinion,
          # where: w.prcp > 0 or is_nil(w.prcp),
          where: o.pos > 0 and o.creator == "55ca7638e297dc5c0046fef4",
          limit: 10,
         select: o
    # query = from w in Weather,
    #       where: w.prcp > 0 or is_nil(w.prcp),
    #      select: w
    Repo.all(query)
  end

  def identities do
    query = from o in Affinaty.Opinion,
          # where: w.prcp > 0 or is_nil(w.prcp),
          where: o.pos > 0 and o.creator == "55ca7638e297dc5c0046fef4",
          limit: 10,
         select: o
    # query = from w in Weather,
    #       where: w.prcp > 0 or is_nil(w.prcp),
    #      select: w
    Affinaty.Repo.all(query)
  end
end
