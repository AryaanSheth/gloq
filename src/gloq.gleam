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

/// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency 
/// in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
pub fn with_frequency_penalty(
  builder: GroqRequestBuilder,
  frequency_penalty: Float,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, frequency_penalty: Some(frequency_penalty))
}

/// This is not yet supported by any of our models. Whether to return log probabilities of the output tokens or not.
///  If true, returns the log probabilities of each output token returned in the `content` of `message`.
pub fn with_logprobs(
  builder: GroqRequestBuilder,
  logprobs: Bool,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, logprobs: Some(logprobs))
}

/// The maximum number of tokens that can be generated in the chat completion. 
/// The total length of input tokens and generated tokens is limited by the model's context length.
pub fn with_max_tokens(
  builder: GroqRequestBuilder,
  max_tokens: Int,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, max_tokens: Some(max_tokens))
}

/// How many chat completion choices to generate for each input message. 
/// Note that the current moment, only n=1 is supported. Other values will result in a 400 response.
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

/// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they
///  appear in the text so far, increasing the model's likelihood to talk about new topics.
pub fn with_presence_penalty(
  builder: GroqRequestBuilder,
  presence_penalty: Float,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, presence_penalty: Some(presence_penalty))
}

/// If specified, our system will make a best effort to sample deterministically, such that 
/// repeated requests with the same seed and parameters should return the same result. 
/// Determinism is not guaranteed, and you should refer to the system_fingerprint response 
/// parameter to monitor changes in the backend.
pub fn with_seed(builder: GroqRequestBuilder, seed: Int) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, seed: Some(seed))
}

/// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
pub fn with_stop(
  builder: GroqRequestBuilder,
  stop: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, stop: Some(stop))
}

/// If set, partial message deltas will be sent. Tokens will be sent as data-only server-sent events as they become available, 
/// with the stream terminated by a data: [DONE] message.
pub fn with_stream(
  builder: GroqRequestBuilder,
  stream: Bool,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, stream: Some(stream))
}

/// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower 
/// values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both
pub fn with_temperature(
  builder: GroqRequestBuilder,
  temperature: Float,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, temperature: Some(temperature))
}

/// Controls which (if any) tool is called by the model. none means the model will not call any tool and instead generates a message.
///  auto means the model can pick between generating a message or calling one or more tools. required means the model must call one or more tools. 
/// Specifying a particular tool via {"type": "function", "function": {"name": "my_function"}} forces the model to call that tool. none is the default 
/// when no tools are present. auto is the default if tools are present.
pub fn with_tool_choice(
  builder: GroqRequestBuilder,
  tool_choice: String,
) -> GroqRequestBuilder {
  GroqRequestBuilder(..builder, tool_choice: Some(tool_choice))
}

/// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. 
/// So 0.1 means only the tokens comprising the top 10% probability mass are considered. We generally recommend altering this or temperature but not both.
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
