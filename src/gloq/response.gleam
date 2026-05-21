/// Types and decoders for GroqCloud chat completion responses.
///
/// Example:
/// ```gleam
/// import gleam/httpc
/// import gloq
/// import gloq/response
///
/// let req =
///   gloq.default_groq_request()
///   |> gloq.with_key(api_key)
///   |> gloq.with_context("What is 2+2?")
///   |> gloq.build()
///
/// case httpc.send(req) {
///   Ok(res) ->
///     case response.decode(res.body) {
///       Ok(completion) -> io.println(response.content(completion))
///       Error(_) -> io.println("Failed to decode response")
///     }
///   Error(_) -> io.println("Request failed")
/// }
/// ```

import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option}

/// Token usage statistics returned with every completion.
pub type Usage {
  Usage(
    prompt_tokens: Int,
    completion_tokens: Int,
    total_tokens: Int,
  )
}

/// The assistant message returned in a completion choice.
pub type ResponseMessage {
  ResponseMessage(role: String, content: String)
}

/// A single completion choice. Most requests return exactly one choice.
pub type Choice {
  Choice(
    index: Int,
    message: ResponseMessage,
    finish_reason: Option(String),
  )
}

/// A full chat completion response from the GroqCloud API.
pub type ChatCompletion {
  ChatCompletion(
    id: String,
    model: String,
    choices: List(Choice),
    usage: Usage,
  )
}

/// An error response from the GroqCloud API.
pub type ApiError {
  ApiError(message: String, error_type: String, code: Option(String))
}

fn usage_decoder() -> decode.Decoder(Usage) {
  use prompt_tokens <- decode.field("prompt_tokens", decode.int)
  use completion_tokens <- decode.field("completion_tokens", decode.int)
  use total_tokens <- decode.field("total_tokens", decode.int)
  decode.success(Usage(
    prompt_tokens: prompt_tokens,
    completion_tokens: completion_tokens,
    total_tokens: total_tokens,
  ))
}

fn response_message_decoder() -> decode.Decoder(ResponseMessage) {
  use role <- decode.field("role", decode.string)
  use content <- decode.field("content", decode.string)
  decode.success(ResponseMessage(role: role, content: content))
}

fn choice_decoder() -> decode.Decoder(Choice) {
  use index <- decode.field("index", decode.int)
  use message <- decode.field("message", response_message_decoder())
  use finish_reason <- decode.field(
    "finish_reason",
    decode.optional(decode.string),
  )
  decode.success(Choice(
    index: index,
    message: message,
    finish_reason: finish_reason,
  ))
}

fn chat_completion_decoder() -> decode.Decoder(ChatCompletion) {
  use id <- decode.field("id", decode.string)
  use model <- decode.field("model", decode.string)
  use choices <- decode.field("choices", decode.list(choice_decoder()))
  use usage <- decode.field("usage", usage_decoder())
  decode.success(ChatCompletion(
    id: id,
    model: model,
    choices: choices,
    usage: usage,
  ))
}

fn api_error_decoder() -> decode.Decoder(ApiError) {
  use message <- decode.field("message", decode.string)
  use error_type <- decode.field("type", decode.string)
  use code <- decode.field("code", decode.optional(decode.string))
  decode.success(ApiError(message: message, error_type: error_type, code: code))
}

/// Decode a JSON response string into a `ChatCompletion`.
/// Returns an error if the JSON is malformed or missing required fields.
pub fn decode(json_string: String) -> Result(ChatCompletion, json.DecodeError) {
  json.decode(json_string, chat_completion_decoder())
}

/// Decode an API error response. Use this when `decode` fails to check
/// whether the server returned a structured error object.
pub fn decode_error(json_string: String) -> Result(ApiError, json.DecodeError) {
  use outer <- decode.field("error", api_error_decoder())
  decode.success(outer)
  |> json.decode(json_string, _)
}

/// Extract the text content from the first choice in a completion.
/// Returns an empty string if there are no choices.
pub fn content(completion: ChatCompletion) -> String {
  case completion.choices {
    [] -> ""
    [choice, ..] -> choice.message.content
  }
}

/// Extract text content from all choices in a completion.
pub fn all_contents(completion: ChatCompletion) -> List(String) {
  list.map(completion.choices, fn(c) { c.message.content })
}
