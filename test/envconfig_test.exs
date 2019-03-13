defmodule EnvconfigTest do
  use ExUnit.Case

  defmodule Dummy do
    use Envconfig

    defenv(:key1, "MY_KEY_1")

    defenv(:key2, "MY_KEY_2", :string)

    defenv(:key3, "MY_KEY_3", :int)
  end

  test "with default type" do
    System.put_env("MY_KEY_1", "avalue")
    System.put_env("MY_KEY_2", "anothervalue")
    System.put_env("MY_KEY_3", "1337")

    assert {:ok, "avalue"} == Dummy.key1()
    assert "avalue" == Dummy.key1!()

    assert {:ok, "anothervalue"} == Dummy.key2()
    assert "anothervalue" == Dummy.key2!()

    assert {:ok, 1337} == Dummy.key3()
    assert 1337 == Dummy.key3!()
  end

  test "with type override" do
    System.put_env("MY_KEY_1", "12")

    assert {:ok, "12"} == Dummy.key1()
    assert {:ok, 12} == Dummy.key1(:int)
  end

  test "with uncastable values" do
    System.put_env("MY_KEY_3", "not-a-int")

    assert {:error, error} = Dummy.key3()
    assert :int == error.expected_type
    assert "not-a-int" == error.raw_value
  end
end
