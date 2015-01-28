# two entrypoints.
source {
  type :unix_unimsg
  path "./tmp/in_literal.sock"
  tag "example.data.in_literal"
}
source {
  type :unix
  path "./tmp/in_unix.sock"
}

match("example.data.**") {
  type :stdout
}

