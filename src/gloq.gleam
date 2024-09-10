import gleam/hackney
import gleam/http
import gleam/http/request
import gleam/json
import gleam/option.{type Option, None, Some}

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
    tool_choice: Option(String),
    top_p: Option(Float),
  )
}

/// Creates a new GroqRequestBuilder with default model and user values.
/// Uses the default model `llama3-8b-8192` and user role `user`.
pub fn default_groq_request() -> GroqRequestBuilder {
  GroqRequestBuilder(
    key: "",
    user: "user",
    context: "",
    model: "llama3-8b-8192",
    frequency_penalty: Some(0.0),
    logprobs: Some(False),
    max_tokens: None,
    n: Some(1),
    parallel_tool_calls: Some(True),
    presence_penalty: Some(0.0),
    seed: None,
    stop: None,
    stream: Some(False),
    temperature: Some(1.0),
    tool_choice: None,
    top_p: Some(1.0),
  )
}

/// Create a new GroqRequestBuilder with no default values. 
pub fn new_groq_request() -> GroqRequestBuilder {
  GroqRequestBuilder(
    ..default_groq_request(),
    key: "",
    user: "",
    context: "",
    model: "",
  )
}

/// Sets the API key for the GroqRequestBuilder.
pub fn with_key(builder: GroqRequestBuilder, key: String) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, key: key)
}

/// Sets the user role for the GroqRequestBuilder.
pub fn with_user(
  builder: GroqRequestBuilder,
  user: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, user: user)
}

/// Sets the context/prompt for the GroqRequestBuilder.
pub fn with_context(
  builder: GroqRequestBuilder,
  context: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, context: context)
}

/// Sets the model for the GroqRequestBuilder.
pub fn with_model(
  builder: GroqRequestBuilder,
  model: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, model: model)
}

pub fn with_frequency_penalty(
  builder: GroqRequestBuilder,
  frequency_penalty: Float,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, frequency_penalty: Some(frequency_penalty))
}

pub fn with_logprobs(
  builder: GroqRequestBuilder,
  logprobs: Bool,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, logprobs: Some(logprobs))
}

pub fn with_max_tokens(
  builder: GroqRequestBuilder,
  max_tokens: Int,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, max_tokens: Some(max_tokens))
}

pub fn with_n(builder: GroqRequestBuilder, n: Int) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, n: Some(n))
}

pub fn with_parallel_tool_calls(
  builder: GroqRequestBuilder,
  parallel_tool_calls: Bool,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, parallel_tool_calls: Some(parallel_tool_calls))
}

pub fn with_presence_penalty(
  builder: GroqRequestBuilder,
  presence_penalty: Float,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, presence_penalty: Some(presence_penalty))
}

pub fn with_seed(builder: GroqRequestBuilder, seed: Int) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, seed: Some(seed))
}

pub fn with_stop(
  builder: GroqRequestBuilder,
  stop: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, stop: Some(stop))
}

pub fn with_stream(
  builder: GroqRequestBuilder,
  stream: Bool,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, stream: Some(stream))
}

pub fn with_temperature(
  builder: GroqRequestBuilder,
  temperature: Float,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, temperature: Some(temperature))
}

pub fn with_tool_choice(
  builder: GroqRequestBuilder,
  tool_choice: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, tool_choice: Some(tool_choice))
}

pub fn with_top_p(
  builder: GroqRequestBuilder,
  top_p: Float,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, top_p: Some(top_p))
}

/// Builds the request body for the GroqCloud API that can be sent using the appropriate HTTP client.
pub fn build(builder: GroqRequestBuilder) {
  let body =
    json.object([
      #(
        "messages",
        json.array(
          [
            json.object([
              #("role", json.string(builder.user)),
              #("content", json.string(builder.context)),
            ]),
          ],
          of: fn(x) { x },
        ),
      ),
      #("model", json.string(builder.model)),
    ])

  let request =
    request.new()
    |> request.set_method(http.Post)
    |> request.set_host("api.groq.com")
    |> request.set_path("/openai/v1/chat/completions")
    |> request.set_header("Authorization", "Bearer " <> builder.key)
    |> request.set_header("Content-Type", "application/json")
    |> request.set_body(json.to_string(body))

  request
}

/// Sends the request to the GroqCloud API for chat completions.
/// > [!Warning]
/// > Function is deprecated, send logic is left to consumer
/// To create a request, use the `build` function and send the request using the appropriate HTTP client of your choice.
/// Uses the `hackney` HTTP client to send the request, this command is no longer supported.
pub fn send(builder: GroqRequestBuilder) -> String {
  let req = build(builder)

  let res = hackney.send(req)

  case res {
    Ok(r) -> r.body
    Error(_) -> "Error, Request Failed"
  }
}

/// Builds the request body for the GroqCloud API that can be sent using the appropriate HTTP client.
pub fn view_models(api_key: String) {
  let request =
    request.new()
    |> request.set_method(http.Get)
    |> request.set_host("api.groq.com")
    |> request.set_path("/openai/v1/models")
    |> request.set_header("Authorization", "Bearer " <> api_key)
    |> request.set_header("Content-Type", "application/json")

  request
}
