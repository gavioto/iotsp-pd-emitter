# two entrypoints.
source {
  type :unix_unimsg
  path "./tmp/example_in_literal.sock"
  tag "example.data.in_literal"
}
source {
  type :unix
  path "./tmp/example_in_unix.sock"
}

match("example.data.**") {
  type :stdout
}

