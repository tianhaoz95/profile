use candle_core::Device;
use candle_transformers::models::quantized_llama::ModelWeights;
use flutter_rust_bridge::frb;
use tokenizers::Tokenizer;

#[frb(init)]
pub fn init_app() {
    #[cfg(target_family = "wasm")]
    console_error_panic_hook::set_once();
}

pub struct LocalAi {
    model: ModelWeights,
    tokenizer: Tokenizer,
}

impl LocalAi {
    #[frb(sync)]
    pub fn new(weights_bytes: Vec<u8>, tokenizer_bytes: Vec<u8>) -> Self {
        let device = Device::Cpu;
        let mut reader = std::io::Cursor::new(weights_bytes);
        let model_content = candle_core::quantized::gguf_file::Content::read(&mut reader).expect("Failed to read GGUF content");
        let model = ModelWeights::from_gguf(model_content, &mut reader, &device).expect("Failed to load model");
        let tokenizer = Tokenizer::from_bytes(&tokenizer_bytes).expect("Failed to load tokenizer");
        Self { model, tokenizer }
    }

    #[frb(sync)]
    pub fn generate(&self, prompt: String, max_tokens: usize) -> String {
        format!("Thinking about: {} (max tokens: {})", prompt, max_tokens)
    }
}

#[frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[frb(sync)]
pub fn ping(input: String) -> String {
    format!("Rust says: {}", input)
}
