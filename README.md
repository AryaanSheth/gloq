# gloq

[![Package Version](https://img.shields.io/hexpm/v/gloq)](https://hex.pm/packages/gloq)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gloq/)
[![test](https://github.com/AryaanSheth/gloq/actions/workflows/test.yml/badge.svg)](https://github.com/AryaanSheth/gloq/actions/workflows/test.yml)

A Gleam library for the [GroqCloud](https://console.groq.com) inference API.
Build type-safe chat completion requests using a fluent builder, then send
them with any HTTP client you choose.

```sh
gleam add gloq
```

After adding, run `gleam deps download` if prompted.

---

## Quick start

```gleam
import gleam/httpc
import gleam/io
import gloq
import gloq/response

pub fn main() {
  let assert Ok(res) =
    gloq.default_groq_request()
    |> gloq.with_key("YOUR_API_KEY")
    |> gloq.with_context("What is the capital of France?")
    |> gloq.build()
    |> httpc.send()

  let assert Ok(completion) = response.decode(res.body)
  io.println(response.content(completion))
}
```

---

## Choosing a model

Import constants from `gloq/models` instead of using raw strings:

```gleam
import gloq
import gloq/models

gloq.default_groq_request()
|> gloq.with_key(api_key)
|> gloq.with_model(models.llama_3_3_70b_versatile)
|> gloq.with_context("Explain monads in one sentence.")
|> gloq.build()
```

Available model constants (see [`gloq/models`](src/gloq/models.gleam) for the full list):

| Constant | Model ID |
|---|---|
| `models.llama_3_3_70b_versatile` | `llama-3.3-70b-versatile` |
| `models.llama_3_1_8b_instant` | `llama-3.1-8b-instant` *(default)* |
| `models.llama_3_1_70b_versatile` | `llama-3.1-70b-versatile` |
| `models.mixtral_8x7b_32768` | `mixtral-8x7b-32768` |
| `models.gemma2_9b_it` | `gemma2-9b-it` |
| `models.deepseek_r1_distill_llama_70b` | `deepseek-r1-distill-llama-70b` |

---

## Multi-turn conversations

Use `add_user_message`, `add_assistant_message`, and `with_system_prompt` to
build a full conversation thread:

```gleam
gloq.default_groq_request()
|> gloq.with_key(api_key)
|> gloq.with_model(models.llama_3_3_70b_versatile)
|> gloq.with_system_prompt("You are a terse assistant. Reply in one sentence.")
|> gloq.add_user_message("What is Gleam?")
|> gloq.add_assistant_message("Gleam is a type-safe language that runs on the Erlang VM.")
|> gloq.add_user_message("What is its mascot?")
|> gloq.build()
```

---

## Structured JSON output

Pass `"json_object"` to `with_response_format` and instruct the model to
return JSON in the system prompt:

```gleam
gloq.default_groq_request()
|> gloq.with_key(api_key)
|> gloq.with_system_prompt("Respond only with valid JSON.")
|> gloq.with_context("Give me a person with a name and age.")
|> gloq.with_response_format("json_object")
|> gloq.build()
```

---

## Decoding responses

`gloq/response` provides types and a decoder for the API response:

```gleam
import gloq/response

case response.decode(res.body) {
  Ok(completion) -> {
    io.println(response.content(completion))
    // completion.usage.total_tokens
    // completion.model
    // response.all_contents(completion)
  }
  Error(_) ->
    // Try decoding an API error instead
    case response.decode_error(res.body) {
      Ok(err) -> io.println(err.message)
      Error(_) -> io.println("Unknown error")
    }
}
```

---

## All builder options

| Function | Type | Default | Description |
|---|---|---|---|
| `with_key` | `String` | `""` | GroqCloud API key |
| `with_model` | `String` | `"llama-3.1-8b-instant"` | Model to use |
| `with_context` | `String` | `""` | Single-turn prompt |
| `with_user` | `String` | `"user"` | Role label for single-turn message |
| `with_system_prompt` | `String` | — | System message prepended to every request |
| `add_user_message` | `String` | — | Append a user turn |
| `add_assistant_message` | `String` | — | Append an assistant turn |
| `with_messages` | `List(Message)` | `[]` | Replace the full message list |
| `with_temperature` | `Float` | `1.0` | 0–2, higher = more random |
| `with_top_p` | `Float` | `1.0` | Nucleus sampling threshold |
| `with_max_tokens` | `Int` | *(model default)* | Max tokens to generate |
| `with_frequency_penalty` | `Float` | `0.0` | -2.0–2.0, penalises repetition |
| `with_presence_penalty` | `Float` | `0.0` | -2.0–2.0, encourages new topics |
| `with_seed` | `Int` | — | Enables deterministic sampling |
| `with_stop` | `String` | — | Stop sequence |
| `with_stream` | `Bool` | `False` | Enable SSE streaming |
| `with_n` | `Int` | `1` | Number of completions (only 1 supported) |
| `with_logprobs` | `Bool` | — | Return token log probabilities |
| `with_parallel_tool_calls` | `Bool` | `True` | Allow parallel tool calls |
| `with_response_format` | `String` | — | `"json_object"` for structured output |

---

## Model listing

```gleam
import gleam/httpc
import gloq

// List all available models
let req = gloq.list_models(api_key)

// Get a specific model's details
let req = gloq.get_model(api_key, "llama-3.1-8b-instant")
```

---

## Migration from v1.x

### Changed defaults
- Default model changed from `"llama3-8b-8192"` to `"llama-3.1-8b-instant"`.
  Set the model explicitly if you need the old default.

### `new_groq_request` behaviour
- `new_groq_request()` now returns `None` for all optional fields instead of
  inheriting defaults. If you relied on `new_groq_request()` giving you
  temperature `1.0` etc., switch to `default_groq_request()`.

### JSON body fix
- Optional fields that are `None` are no longer serialised. Previously `seed: None`
  would send `"seed": 0` to the API; now it is omitted entirely.

### New fields on `GroqRequestBuilder`
- Three new fields were added: `system_prompt`, `messages`, `response_format`.
  If you construct `GroqRequestBuilder(...)` directly (rather than using the
  builder functions) you must add these fields. Recommended: use
  `default_groq_request()` or `new_groq_request()` as a base.

### Removed dependencies
- `dot_env`, `dotenv`, and `gleam_httpc` were removed from the package
  dependencies (they were never used). Run `gleam deps download` after updating.

### `send` is still present but deprecated
- `send/1` still works but remains deprecated. Use `build/1` with your own
  HTTP client.

---

Further documentation at <https://hexdocs.pm/gloq>.
