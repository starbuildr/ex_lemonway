defmodule ExLemonway.Util.RequestTest do
  use ExUnit.Case

  alias ExLemonway.Util.Request

  @json_header {"Content-Type", "application/json"}

  describe "get" do
    test "should work with generic html" do
      assert {:ok, _html} = Request.get("https://www.google.com")
    end

    test "should parse JSON response" do
      assert {:ok, %{"id" => 1}} =
               Request.get("https://jsonplaceholder.typicode.com/posts/1", [@json_header])
    end

    test "should support unexpected responses" do
      assert {:error, %{code: 301}} = Request.get("https://google.com")
    end
  end

  describe "post" do
    test "should publish map as JSON payload" do
      payload = %{title: "foo", body: "bar", userId: 1}

      assert {:ok, %{"userId" => 1}} =
               Request.post("https://jsonplaceholder.typicode.com/posts", payload, [@json_header])
    end

    test "should handle invalid requests gracefully" do
      assert {:error, %{code: 404}} =
               Request.post("https://jsonplaceholder.typicode.com/posts/1", %{}, [@json_header])
    end
  end

  describe "put" do
    test "should publish map as JSON payload" do
      payload = %{id: 1, title: "foo", body: "bar", userId: 2}

      assert {:ok, %{"userId" => 2}} =
               Request.put("https://jsonplaceholder.typicode.com/posts/1", payload, [@json_header])
    end

    test "should handle invalid requests gracefully" do
      assert {:error, %{code: 404}} =
               Request.put("https://jsonplaceholder.typicode.com/posts", %{}, [@json_header])
    end
  end

  describe "delete" do
    test "should delete existing resource" do
      assert {:ok, %{}} = Request.delete("https://jsonplaceholder.typicode.com/posts/1")
    end

    test "should handle invalid requests gracefully" do
      assert {:error, %{code: 404}} =
               Request.delete("https://jsonplaceholder.typicode.com/posts", %{}, [@json_header])
    end
  end
end
