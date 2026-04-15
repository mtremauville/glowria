RubyLLM.configure do |c|
  c.anthropic_api_key  = ENV["ANTHROPIC_API_KEY"]
  c.gemini_api_key     = ENV["GEMINI_API_KEY"]
  c.openai_api_key     = ENV["OPENAI_API_KEY"]
  c.use_new_acts_as    = true
end
