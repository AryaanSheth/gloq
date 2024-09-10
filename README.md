# gloq

[![Package Version](https://img.shields.io/hexpm/v/gloq)](https://hex.pm/packages/gloq)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gloq/)
[![test](https://github.com/AryaanSheth/gloq/actions/workflows/test.yml/badge.svg)](https://github.com/AryaanSheth/gloq/actions/workflows/test.yml)

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

  let req = 
    default_groq_request()
    |> with_key(key)
    |> with_user("user")
    |> with_context("Hello, how are you?")
    |> with_model("llama3-8b-8192")
    |> build()

  io.println(req.body)

}
```

Further documentation can be found at <https://hex.pm/packages/gloq>.
