# gloq

[![Package Version](https://img.shields.io/hexpm/v/gloq)](https://hex.pm/packages/gloq)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gloq/)
![Tests](https://github.com/github/docs/actions/workflows/test.yml/badge.svg)

> [!Note]
> Library is in its very early stages      
> Feel free to create PR's and Issues

```sh
gleam add gloq
```
```gleam
import gleam/io
import gloq

pub fn main() {
  let key = "abc123"

  let response =
    gloq.new_groq_request()
    |> gloq.with_key(key)
    |> gloq.with_context("Explain the importance of fast language models")
    |> gloq.with_user("user")
    |> gloq.with_model("llama3-8b-8192")
    |> gloq.send()

  io.println(response)
}
```

Further documentation can be found at <https://hex.pm/packages/gloq>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
