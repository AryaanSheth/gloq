import dot_env as dot
import dot_env/env
import gleam/hackney
import gleam/http
import gleam/http/request
import gleam/json

// dev use
// loads the .env file and returns the value of the GROQ_API_KEY
fn read_env(key_name) -> String {
  dot.new()
  |> dot.set_path(".env")
  |> dot.set_debug(True)
  |> dot.load()

  case env.get_string(key_name) {
    Ok(key) -> key
    Error(e) -> "Key Not Found" <> e
  }
}

/// Makes a request to the GroqCloud API for chat completions.
///
/// This function sends a POST request to the Groq API endpoint for chat completions.
/// It constructs the request body with the provided user message and context,
/// sets the necessary headers including the API key, and handles the response.
///
/// Parameters:
/// - key: String - The API key for authentication with Groq.
/// - user: String - The role of the message sender (e.g., "user" or "system").
/// - context: String - The content of the message or prompt.
/// - model: String - The name of the Groq model to use for the completion.
///
/// Returns:
/// - String - The response body from the API if successful, or an error message if the request fails.
///
/// Note: This function uses the hackney HTTP client for making the request.
pub fn groq_request(
  key: String,
  user: String,
  context: String,
  model: String,
) -> String {
  let body =
    json.object([
      #(
        "messages",
        json.array(
          [
            json.object([
              #("role", json.string(user)),
              #("content", json.string(context)),
            ]),
          ],
          of: fn(x) { x },
        ),
      ),
      #("model", json.string(model)),
    ])

  let req =
    request.new()
    |> request.set_method(http.Post)
    |> request.set_host("api.groq.com")
    |> request.set_path("/openai/v1/chat/completions")
    |> request.set_header("Authorization", "Bearer " <> key)
    |> request.set_header("Content-Type", "application/json")
    |> request.set_body(json.to_string(body))

  let res = hackney.send(req)

  case res {
    Ok(r) -> {
      r.body
    }
    Error(_e) -> {
      "Error, Request Failed"
    }
  }
}
