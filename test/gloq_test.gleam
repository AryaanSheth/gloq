import gleeunit
import gleeunit/should
import gleam/http
import gleam/http/request
import gleam/option.{None, Some}
import gleam/string
import gloq

pub fn main() {
  gleeunit.main()
}

// ── Builder initialisation ──────────────────────────────────────────────────

pub fn default_groq_request_test() {
  let builder = gloq.default_groq_request()
  builder.key |> should.equal("")
  builder.user |> should.equal("user")
  builder.context |> should.equal("")
  builder.model |> should.equal("llama-3.1-8b-instant")
  builder.system_prompt |> should.equal(None)
  builder.messages |> should.equal([])
  builder.response_format |> should.equal(None)
}

pub fn new_groq_request_test() {
  let builder = gloq.new_groq_request()
  builder.key |> should.equal("")
  builder.user |> should.equal("")
  builder.context |> should.equal("")
  builder.model |> should.equal("")
  builder.frequency_penalty |> should.equal(None)
  builder.temperature |> should.equal(None)
  builder.max_tokens |> should.equal(None)
  builder.seed |> should.equal(None)
  builder.messages |> should.equal([])
}

// ── Core setters ────────────────────────────────────────────────────────────

pub fn with_key_test() {
  gloq.new_groq_request()
  |> gloq.with_key("sk-test")
  |> fn(b) { b.key }
  |> should.equal("sk-test")
}

pub fn with_user_test() {
  gloq.new_groq_request()
  |> gloq.with_user("assistant")
  |> fn(b) { b.user }
  |> should.equal("assistant")
}

pub fn with_context_test() {
  gloq.new_groq_request()
  |> gloq.with_context("Hello, world!")
  |> fn(b) { b.context }
  |> should.equal("Hello, world!")
}

pub fn with_model_test() {
  gloq.new_groq_request()
  |> gloq.with_model("llama-3.3-70b-versatile")
  |> fn(b) { b.model }
  |> should.equal("llama-3.3-70b-versatile")
}

// ── Optional parameter setters ──────────────────────────────────────────────

pub fn with_temperature_test() {
  gloq.new_groq_request()
  |> gloq.with_temperature(0.7)
  |> fn(b) { b.temperature }
  |> should.equal(Some(0.7))
}

pub fn with_max_tokens_test() {
  gloq.new_groq_request()
  |> gloq.with_max_tokens(512)
  |> fn(b) { b.max_tokens }
  |> should.equal(Some(512))
}

pub fn with_frequency_penalty_test() {
  gloq.new_groq_request()
  |> gloq.with_frequency_penalty(0.5)
  |> fn(b) { b.frequency_penalty }
  |> should.equal(Some(0.5))
}

pub fn with_presence_penalty_test() {
  gloq.new_groq_request()
  |> gloq.with_presence_penalty(-0.5)
  |> fn(b) { b.presence_penalty }
  |> should.equal(Some(-0.5))
}

pub fn with_top_p_test() {
  gloq.new_groq_request()
  |> gloq.with_top_p(0.9)
  |> fn(b) { b.top_p }
  |> should.equal(Some(0.9))
}

pub fn with_seed_test() {
  gloq.new_groq_request()
  |> gloq.with_seed(42)
  |> fn(b) { b.seed }
  |> should.equal(Some(42))
}

pub fn with_stop_test() {
  gloq.new_groq_request()
  |> gloq.with_stop("\n")
  |> fn(b) { b.stop }
  |> should.equal(Some("\n"))
}

pub fn with_stream_test() {
  gloq.new_groq_request()
  |> gloq.with_stream(True)
  |> fn(b) { b.stream }
  |> should.equal(Some(True))
}

pub fn with_n_test() {
  gloq.new_groq_request()
  |> gloq.with_n(1)
  |> fn(b) { b.n }
  |> should.equal(Some(1))
}

pub fn with_logprobs_test() {
  gloq.new_groq_request()
  |> gloq.with_logprobs(True)
  |> fn(b) { b.logprobs }
  |> should.equal(Some(True))
}

pub fn with_parallel_tool_calls_test() {
  gloq.new_groq_request()
  |> gloq.with_parallel_tool_calls(False)
  |> fn(b) { b.parallel_tool_calls }
  |> should.equal(Some(False))
}

// ── New v2 features ─────────────────────────────────────────────────────────

pub fn with_system_prompt_test() {
  gloq.new_groq_request()
  |> gloq.with_system_prompt("You are a helpful assistant.")
  |> fn(b) { b.system_prompt }
  |> should.equal(Some("You are a helpful assistant."))
}

pub fn with_response_format_test() {
  gloq.new_groq_request()
  |> gloq.with_response_format("json_object")
  |> fn(b) { b.response_format }
  |> should.equal(Some("json_object"))
}

pub fn add_user_message_test() {
  let builder =
    gloq.new_groq_request()
    |> gloq.add_user_message("Hello!")
  builder.messages |> should.equal([gloq.Message(role: "user", content: "Hello!")])
}

pub fn add_assistant_message_test() {
  let builder =
    gloq.new_groq_request()
    |> gloq.add_assistant_message("Hi there!")
  builder.messages
  |> should.equal([gloq.Message(role: "assistant", content: "Hi there!")])
}

pub fn multi_turn_messages_test() {
  let builder =
    gloq.new_groq_request()
    |> gloq.add_user_message("What is 2+2?")
    |> gloq.add_assistant_message("4")
    |> gloq.add_user_message("And 3+3?")

  builder.messages
  |> should.equal([
    gloq.Message(role: "user", content: "What is 2+2?"),
    gloq.Message(role: "assistant", content: "4"),
    gloq.Message(role: "user", content: "And 3+3?"),
  ])
}

pub fn with_messages_replaces_list_test() {
  let msgs = [
    gloq.Message(role: "user", content: "Hi"),
    gloq.Message(role: "assistant", content: "Hello"),
  ]
  gloq.new_groq_request()
  |> gloq.add_user_message("ignored")
  |> gloq.with_messages(msgs)
  |> fn(b) { b.messages }
  |> should.equal(msgs)
}

// ── Build output ─────────────────────────────────────────────────────────────

pub fn build_method_test() {
  let req =
    gloq.default_groq_request()
    |> gloq.with_key("test-key")
    |> gloq.with_context("hi")
    |> gloq.build()
  req.method |> should.equal(http.Post)
}

pub fn build_host_test() {
  let req =
    gloq.default_groq_request()
    |> gloq.with_key("test-key")
    |> gloq.with_context("hi")
    |> gloq.build()
  req.host |> should.equal("api.groq.com")
}

pub fn build_path_test() {
  let req =
    gloq.default_groq_request()
    |> gloq.with_key("test-key")
    |> gloq.with_context("hi")
    |> gloq.build()
  req.path |> should.equal("/openai/v1/chat/completions")
}

pub fn build_auth_header_test() {
  let req =
    gloq.default_groq_request()
    |> gloq.with_key("my-api-key")
    |> gloq.with_context("hi")
    |> gloq.build()
  request.get_header(req, "authorization")
  |> should.equal(Ok("Bearer my-api-key"))
}

pub fn build_content_type_header_test() {
  let req =
    gloq.default_groq_request()
    |> gloq.with_key("test-key")
    |> gloq.with_context("hi")
    |> gloq.build()
  request.get_header(req, "content-type")
  |> should.equal(Ok("application/json"))
}

pub fn build_body_contains_model_test() {
  let req =
    gloq.default_groq_request()
    |> gloq.with_key("test-key")
    |> gloq.with_model("llama-3.3-70b-versatile")
    |> gloq.with_context("hi")
    |> gloq.build()
  req.body |> string.contains("llama-3.3-70b-versatile") |> should.equal(True)
}

pub fn build_body_contains_messages_test() {
  let req =
    gloq.default_groq_request()
    |> gloq.with_key("test-key")
    |> gloq.with_context("hello from test")
    |> gloq.build()
  req.body |> string.contains("messages") |> should.equal(True)
  req.body |> string.contains("hello from test") |> should.equal(True)
}

pub fn build_omits_none_fields_test() {
  let req =
    gloq.new_groq_request()
    |> gloq.with_key("test-key")
    |> gloq.with_model("llama-3.1-8b-instant")
    |> gloq.with_context("hi")
    |> gloq.build()
  // seed, stop, max_tokens were not set — must not appear in body
  req.body |> string.contains("\"seed\"") |> should.equal(False)
  req.body |> string.contains("\"stop\"") |> should.equal(False)
  req.body |> string.contains("\"max_tokens\"") |> should.equal(False)
}

pub fn build_system_prompt_in_messages_test() {
  let req =
    gloq.default_groq_request()
    |> gloq.with_key("test-key")
    |> gloq.with_system_prompt("You are concise.")
    |> gloq.with_context("hi")
    |> gloq.build()
  req.body |> string.contains("system") |> should.equal(True)
  req.body |> string.contains("You are concise.") |> should.equal(True)
}

pub fn build_response_format_test() {
  let req =
    gloq.default_groq_request()
    |> gloq.with_key("test-key")
    |> gloq.with_context("give me json")
    |> gloq.with_response_format("json_object")
    |> gloq.build()
  req.body |> string.contains("response_format") |> should.equal(True)
  req.body |> string.contains("json_object") |> should.equal(True)
}

// ── Model listing requests ───────────────────────────────────────────────────

pub fn list_models_method_test() {
  let req = gloq.list_models("test-key")
  req.method |> should.equal(http.Get)
  req.path |> should.equal("/openai/v1/models")
}

pub fn get_model_path_test() {
  let req = gloq.get_model("test-key", "llama-3.1-8b-instant")
  req.method |> should.equal(http.Get)
  req.path |> should.equal("/openai/v1/models/llama-3.1-8b-instant")
}

pub fn view_models_backwards_compat_test() {
  let a = gloq.view_models("key")
  let b = gloq.list_models("key")
  a.path |> should.equal(b.path)
  a.method |> should.equal(b.method)
}

// ── Legacy chained builder ───────────────────────────────────────────────────

pub fn chained_builder_test() {
  let builder =
    gloq.new_groq_request()
    |> gloq.with_key("test_key")
    |> gloq.with_user("test_user")
    |> gloq.with_context("test_context")
    |> gloq.with_model("test_model")

  builder.key |> should.equal("test_key")
  builder.user |> should.equal("test_user")
  builder.context |> should.equal("test_context")
  builder.model |> should.equal("test_model")
}
