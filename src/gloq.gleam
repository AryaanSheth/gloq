import gleam/hackney
import gleam/http
import gleam/http/request.{type Request}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}

/// A single message in a conversation, used for multi-turn requests.
pub type Message {
  Message(role: String, content: String)
}

/// Builder for a GroqCloud chat completion request.
///
/// Construct one with `default_groq_request/0` or `new_groq_request/0`,
/// chain `with_*` setters, then call `build/1` to get an HTTP request
/// you can send with any client (e.g. `gleam_httpc` or `gleam_hackney`).
pub type GroqRequestBuilder {
  GroqRequestBuilder(
    key: String,
    user: String,
    context: String,
    model: String,
    frequency_penalty: Option(Float),
    logprobs: Option(Bool),
    max_tokens: Option(Int),
    n: Option(Int),
    parallel_tool_calls: Option(Bool),
    presence_penalty: Option(Float),
    seed: Option(Int),
    stop: Option(String),
    stream: Option(Bool),
    temperature: Option(Float),
    top_p: Option(Float),
    system_prompt: Option(String),
    messages: List(Message),
    response_format: Option(String),
  )
}

/// Creates a new `GroqRequestBuilder` with sensible defaults.
/// Default model: `llama-3.1-8b-instant`. Default user role: `"user"`.
pub fn default_groq_request() -> GroqRequestBuilder {
  GroqRequestBuilder(
    key: "",
    user: "user",
    context: "",
    model: "llama-3.1-8b-instant",
    frequency_penalty: Some(0.0),
    logprobs: None,
    max_tokens: None,
    n: Some(1),
    parallel_tool_calls: Some(True),
    presence_penalty: Some(0.0),
    seed: None,
    stop: None,
    stream: Some(False),
    temperature: Some(1.0),
    top_p: Some(1.0),
    system_prompt: None,
    messages: [],
    response_format: None,
  )
}

/// Creates a new `GroqRequestBuilder` with no preset values.
/// You must set `key`, `model`, `user`, and `context` (or `messages`) before calling `build/1`.
pub fn new_groq_request() -> GroqRequestBuilder {
  GroqRequestBuilder(
    key: "",
    user: "",
    context: "",
    model: "",
    frequency_penalty: None,
    logprobs: None,
    max_tokens: None,
    n: None,
    parallel_tool_calls: None,
    presence_penalty: None,
    seed: None,
    stop: None,
    stream: None,
    temperature: None,
    top_p: None,
    system_prompt: None,
    messages: [],
    response_format: None,
  )
}

/// Sets the GroqCloud API key.
pub fn with_key(builder: GroqRequestBuilder, key: String) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, key: key)
}

/// Sets the user role label for the single-turn message (default: `"user"`).
/// For multi-turn conversations use `add_user_message/2` instead.
pub fn with_user(
  builder: GroqRequestBuilder,
  user: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, user: user)
}

/// Sets the prompt text for a single-turn request.
/// For multi-turn conversations use `add_user_message/2` instead.
pub fn with_context(
  builder: GroqRequestBuilder,
  context: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, context: context)
}

/// Sets the model to use for inference. See `gloq/models` for available constants.
pub fn with_model(
  builder: GroqRequestBuilder,
  model: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, model: model)
}

/// Sets a system prompt that is prepended as the first message.
pub fn with_system_prompt(
  builder: GroqRequestBuilder,
  prompt: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, system_prompt: Some(prompt))
}

/// Replaces the entire conversation message list.
/// When messages is non-empty, `with_user/2` and `with_context/2` are ignored.
pub fn with_messages(
  builder: GroqRequestBuilder,
  messages: List(Message),
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, messages: messages)
}

/// Appends a message with the given role and content to the conversation.
pub fn add_message(
  builder: GroqRequestBuilder,
  role: String,
  content: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(
    ..builder,
    messages: list.append(builder.messages, [Message(role: role, content: content)]),
  )
}

/// Appends a user message to the conversation.
pub fn add_user_message(
  builder: GroqRequestBuilder,
  content: String,
) -> GroqRequestBuilder {
  add_message(builder, "user", content)
}

/// Appends an assistant message to the conversation (useful for continuing a thread).
pub fn add_assistant_message(
  builder: GroqRequestBuilder,
  content: String,
) -> GroqRequestBuilder {
  add_message(builder, "assistant", content)
}

/// Number between -2.0 and 2.0. Positive values penalize new tokens based on
/// their existing frequency, decreasing the likelihood of repetition.
pub fn with_frequency_penalty(
  builder: GroqRequestBuilder,
  frequency_penalty: Float,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, frequency_penalty: Some(frequency_penalty))
}

/// Whether to return log probabilities of the output tokens.
/// Not yet supported by all models.
pub fn with_logprobs(
  builder: GroqRequestBuilder,
  logprobs: Bool,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, logprobs: Some(logprobs))
}

/// Maximum number of tokens to generate. When `None` the model default is used.
pub fn with_max_tokens(
  builder: GroqRequestBuilder,
  max_tokens: Int,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, max_tokens: Some(max_tokens))
}

/// Number of completion choices to generate. Only `n = 1` is currently supported.
pub fn with_n(builder: GroqRequestBuilder, n: Int) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, n: Some(n))
}

/// Whether to enable parallel function calling during tool use.
pub fn with_parallel_tool_calls(
  builder: GroqRequestBuilder,
  parallel_tool_calls: Bool,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, parallel_tool_calls: Some(parallel_tool_calls))
}

/// Number between -2.0 and 2.0. Positive values penalize tokens that have
/// already appeared, encouraging the model to discuss new topics.
pub fn with_presence_penalty(
  builder: GroqRequestBuilder,
  presence_penalty: Float,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, presence_penalty: Some(presence_penalty))
}

/// Setting a seed makes the system attempt to sample deterministically so that
/// repeated requests with the same seed and parameters return the same result.
pub fn with_seed(builder: GroqRequestBuilder, seed: Int) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, seed: Some(seed))
}

/// Up to 4 sequences where the API stops generating tokens. The stop sequence
/// itself is not included in the output.
pub fn with_stop(
  builder: GroqRequestBuilder,
  stop: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, stop: Some(stop))
}

/// When `True`, partial message deltas are sent as server-sent events.
pub fn with_stream(
  builder: GroqRequestBuilder,
  stream: Bool,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, stream: Some(stream))
}

/// Sampling temperature between 0 and 2. Higher values increase randomness;
/// lower values increase focus. Do not use alongside `with_top_p/2`.
pub fn with_temperature(
  builder: GroqRequestBuilder,
  temperature: Float,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, temperature: Some(temperature))
}

/// Nucleus sampling threshold. The model considers only the top tokens whose
/// cumulative probability exceeds this value. Do not use alongside `with_temperature/2`.
pub fn with_top_p(
  builder: GroqRequestBuilder,
  top_p: Float,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, top_p: Some(top_p))
}

/// Request a structured response format. Pass `"json_object"` to get valid JSON.
/// When using this, instruct the model to produce JSON in your system prompt.
pub fn with_response_format(
  builder: GroqRequestBuilder,
  format: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, response_format: Some(format))
}

fn optional_field(
  key: String,
  value: Option(a),
  encoder: fn(a) -> Json,
) -> Option(#(String, Json)) {
  option.map(value, fn(v) { #(key, encoder(v)) })
}

/// Builds the HTTP request ready to send with your chosen HTTP client.
/// Only optional fields that have been explicitly set are included in the body.
///
/// Example:
/// ```gleam
/// import gleam/httpc
/// import gloq
///
/// let req =
///   gloq.default_groq_request()
///   |> gloq.with_key(api_key)
///   |> gloq.with_context("Hello!")
///   |> gloq.build()
///
/// let response = httpc.send(req)
/// ```
pub fn build(builder: GroqRequestBuilder) -> Request(String) {
  let system_msgs = case builder.system_prompt {
    None -> []
    Some(prompt) -> [
      json.object([
        #("role", json.string("system")),
        #("content", json.string(prompt)),
      ]),
    ]
  }

  let conversation_msgs = case builder.messages {
    [] -> [
      json.object([
        #("role", json.string(builder.user)),
        #("content", json.string(builder.context)),
      ]),
    ]
    msgs ->
      list.map(msgs, fn(m) {
        json.object([
          #("role", json.string(m.role)),
          #("content", json.string(m.content)),
        ])
      })
  }

  let all_messages = list.append(system_msgs, conversation_msgs)

  let optional_fields =
    [
      optional_field("frequency_penalty", builder.frequency_penalty, json.float),
      optional_field("logprobs", builder.logprobs, json.bool),
      optional_field("max_tokens", builder.max_tokens, json.int),
      optional_field("n", builder.n, json.int),
      optional_field(
        "parallel_tool_calls",
        builder.parallel_tool_calls,
        json.bool,
      ),
      optional_field("presence_penalty", builder.presence_penalty, json.float),
      optional_field("seed", builder.seed, json.int),
      optional_field("stop", builder.stop, json.string),
      optional_field("stream", builder.stream, json.bool),
      optional_field("temperature", builder.temperature, json.float),
      optional_field("top_p", builder.top_p, json.float),
      optional_field("response_format", builder.response_format, fn(fmt) {
        json.object([#("type", json.string(fmt))])
      }),
    ]
    |> list.filter_map(fn(x) { x })

  let required_fields = [
    #("messages", json.array(all_messages, fn(x) { x })),
    #("model", json.string(builder.model)),
  ]

  let body = json.object(list.append(required_fields, optional_fields))

  request.new()
  |> request.set_method(http.Post)
  |> request.set_host("api.groq.com")
  |> request.set_path("/openai/v1/chat/completions")
  |> request.set_header("Authorization", "Bearer " <> builder.key)
  |> request.set_header("Content-Type", "application/json")
  |> request.set_body(json.to_string(body))
}

/// Builds a request to list all available models.
///
/// > Note: `view_models` is kept for backwards compatibility.
/// > New code should prefer `list_models/1`.
pub fn view_models(api_key: String) -> Request(String) {
  list_models(api_key)
}

/// Builds a GET request to list all models available on your GroqCloud account.
pub fn list_models(api_key: String) -> Request(String) {
  request.new()
  |> request.set_method(http.Get)
  |> request.set_host("api.groq.com")
  |> request.set_path("/openai/v1/models")
  |> request.set_header("Authorization", "Bearer " <> api_key)
  |> request.set_header("Content-Type", "application/json")
}

/// Builds a GET request to retrieve details for a single model by ID.
pub fn get_model(api_key: String, model_id: String) -> Request(String) {
  request.new()
  |> request.set_method(http.Get)
  |> request.set_host("api.groq.com")
  |> request.set_path("/openai/v1/models/" <> model_id)
  |> request.set_header("Authorization", "Bearer " <> api_key)
  |> request.set_header("Content-Type", "application/json")
}

/// Sends the request to the GroqCloud API using the hackney HTTP client and
/// returns the raw response body.
///
/// > **Deprecated** — send logic is intentionally left to the consumer so you
/// > can use any HTTP client. Call `build/1` instead and send the request with
/// > `gleam_httpc`, `gleam_hackney`, or your preferred client.
pub fn send(builder: GroqRequestBuilder) -> String {
  let req = build(builder)
  case hackney.send(req) {
    Ok(r) -> r.body
    Error(_) -> "Error, Request Failed"
  }
}
