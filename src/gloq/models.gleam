/// Constants for all currently available GroqCloud models.
/// Use these instead of raw strings to avoid typos and get IDE completion.
///
/// Example:
/// ```gleam
/// import gloq
/// import gloq/models
///
/// gloq.default_groq_request()
/// |> gloq.with_key(api_key)
/// |> gloq.with_model(models.llama_3_1_8b_instant)
/// |> gloq.with_context("Hello!")
/// |> gloq.build()
/// ```

// ── Llama 3.3 ──────────────────────────────────────────────────────────────

/// Llama 3.3 70B — latest generation, 128k context. Recommended default.
pub const llama_3_3_70b_versatile = "llama-3.3-70b-versatile"

/// Llama 3.3 70B with speculative decoding for faster output.
pub const llama_3_3_70b_specdec = "llama-3.3-70b-specdec"

// ── Llama 3.1 ──────────────────────────────────────────────────────────────

/// Llama 3.1 8B — fast, lightweight, 128k context. Good for high-throughput.
pub const llama_3_1_8b_instant = "llama-3.1-8b-instant"

/// Llama 3.1 70B — powerful, 128k context.
pub const llama_3_1_70b_versatile = "llama-3.1-70b-versatile"

// ── Llama 3.2 ──────────────────────────────────────────────────────────────

/// Llama 3.2 1B — ultra-lightweight model for edge use cases.
pub const llama_3_2_1b_preview = "llama-3.2-1b-preview"

/// Llama 3.2 3B — small but capable.
pub const llama_3_2_3b_preview = "llama-3.2-3b-preview"

/// Llama 3.2 11B Vision — multimodal model supporting image inputs.
pub const llama_3_2_11b_vision_preview = "llama-3.2-11b-vision-preview"

/// Llama 3.2 90B Vision — large multimodal model.
pub const llama_3_2_90b_vision_preview = "llama-3.2-90b-vision-preview"

// ── Llama 3 (legacy) ───────────────────────────────────────────────────────

/// Llama 3 8B — legacy model, 8k context. Prefer llama_3_1_8b_instant.
pub const llama3_8b_8192 = "llama3-8b-8192"

/// Llama 3 70B — legacy model, 8k context. Prefer llama_3_1_70b_versatile.
pub const llama3_70b_8192 = "llama3-70b-8192"

// ── Mixtral ────────────────────────────────────────────────────────────────

/// Mixtral 8x7B MoE — 32k context. Strong at reasoning and code.
pub const mixtral_8x7b_32768 = "mixtral-8x7b-32768"

// ── Gemma ──────────────────────────────────────────────────────────────────

/// Gemma 2 9B — Google's efficient instruction-tuned model.
pub const gemma2_9b_it = "gemma2-9b-it"

/// Gemma 7B — legacy Google model. Prefer gemma2_9b_it.
pub const gemma_7b_it = "gemma-7b-it"

// ── DeepSeek ───────────────────────────────────────────────────────────────

/// DeepSeek R1 distilled on Llama 70B — strong reasoning model.
pub const deepseek_r1_distill_llama_70b = "deepseek-r1-distill-llama-70b"

// ── Qwen ───────────────────────────────────────────────────────────────────

/// Qwen QwQ 32B — strong reasoning and long-context model.
pub const qwen_qwq_32b = "qwen-qwq-32b"
