defmodule ExLemonwayTest do
  use ExUnit.Case
  doctest ExLemonway

  import ExLemonway.Factory
  alias ExLemonway.Wallet

  test "greets the world" do
    wallet1 = build(:wallet)
    wallet2 = build(:wallet)
    assert %Wallet{} = wallet1
    refute wallet1.id === wallet2.id
  end
end
