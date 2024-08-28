import gleam/hackney
import gleam/http
import gleam/http/request
import gleam/io
import gleam/json

// example request from Groq API documentation
// curl -X POST "https://api.groq.com/openai/v1/chat/completions" \
//      -H "Authorization: Bearer $GROQ_API_KEY" \
//      -H "Content-Type: application/json" \
//      -d '{"messages": [{"role": "user", "content": "Explain the importance of fast language models"}], "model": "llama3-8b-8192"}'
pub fn main() {
  let api_key = "YOUR_GROQ_API_KEY"
  // Replace with your actual API key

  // request body
  let body =
    json.object([
      #(
        "messages",
        json.array(
          [
            json.object([
              #("role", json.string("user")),
              #(
                "content",
                json.string("Explain the importance of fast language models"),
              ),
            ]),
          ],
          of: fn(x) { x },
        ),
      ),
      #("model", json.string("llama3-8b-8192")),
    ])

  // create request
  let req =
    request.new()
    |> request.set_method(http.Post)
    |> request.set_host("api.groq.com")
    |> request.set_path("/openai/v1/chat/completions")
    |> request.set_header("Authorization", "Bearer " <> api_key)
    |> request.set_header("Content-Type", "application/json")
    |> request.set_body(json.to_string(body))

  let res = hackney.send(req)

  case res {
    Ok(r) -> {
      io.println("Response:" <> r.body)
    }
    Error(_e) -> {
      io.println("Error, Request Failed")
    }
  }
}
