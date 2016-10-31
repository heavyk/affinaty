defmodule Affinaty.IdentityTest do
  use Affinaty.ModelCase

  alias Affinaty.Identity

  @valid_attrs %{hashword: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Identity.changeset(%Identity{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Identity.changeset(%Identity{}, @invalid_attrs)
    refute changeset.valid?
  end
end
