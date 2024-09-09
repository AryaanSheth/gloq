import gleam/hackney
import gleam/http
import gleam/http/request
import gleam/json

pub type GroqRequestBuilder {
  GroqRequestBuilder(key: String, user: String, context: String, model: String)
}

/// Creates a new GroqRequestBuilder with default model and user values.
pub fn default_groq_request() -> GroqRequestBuilder {
  GroqRequestBuilder(
    key: "",
    user: "user",
    context: "",
    model: "llama3-8b-8192",
  )
}

/// Create a new GroqRequestBuilder with no default values. 
pub fn new_groq_request() -> GroqRequestBuilder {
  GroqRequestBuilder(key: "", user: "", context: "", model: "")
}

/// Enum of all models available for the GroqRequestBuilder.
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
