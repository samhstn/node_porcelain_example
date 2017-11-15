defmodule NodePorcelainExampleTest do
  use ExUnit.Case, async: false

  test "request" do
    assert NodePorcelainExample.request() =~ "<h1>Hello World</h1>"
  end
end
