import gleeunit
import gleeunit/should
import gloq

pub fn main() {
  gleeunit.main()
}

pub fn default_groq_request_test() {
  let builder = gloq.default_groq_request()
  builder.key |> should.equal("")
  builder.user |> should.equal("user")
  builder.context |> should.equal("")
  builder.model |> should.equal("llama3-8b-8192")
}

pub fn new_groq_request_test() {
  let builder = gloq.new_groq_request()
  builder.key |> should.equal("")
  builder.user |> should.equal("")
  builder.context |> should.equal("")
  builder.model |> should.equal("")
}

pub fn with_key_test() {
  let builder = gloq.new_groq_request() |> gloq.with_key("test_key")
  builder.key |> should.equal("test_key")
}

pub fn with_user_test() {
  let builder = gloq.new_groq_request() |> gloq.with_user("test_user")
  builder.user |> should.equal("test_user")
}

pub fn with_context_test() {
  let builder = gloq.new_groq_request() |> gloq.with_context("test_context")
  builder.context |> should.equal("test_context")
}

pub fn with_model_test() {
  let builder = gloq.new_groq_request() |> gloq.with_model("test_model")
  builder.model |> should.equal("test_model")
}

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
