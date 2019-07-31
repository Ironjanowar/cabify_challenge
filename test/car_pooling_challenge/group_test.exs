defmodule CarPoolingChallenge.GroupTest do
  use ExUnit.Case

  alias CarPoolingChallenge.Model.Group

  describe "groups" do
    test "Creates a group with valid data" do
      valid_data = %{"id" => 1, "people" => 3}
      group = Group.changeset(valid_data)

      assert group.valid?
    end

    test "Tries to create a group with invalid data" do
      invalid_data = %{"id" => 1}
      group = Group.changeset(invalid_data)

      refute group.valid?
    end

    test "Tries to create a group with people out of range" do
      invalid_data = %{id: 1, people: 8}
      group = Group.changeset(invalid_data)

      refute group.valid?
    end
  end
end
