OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.dig(:openai, :api_key) || ENV["OPENAI_API_KEY"]
  
  # Add organization ID for project-based keys
  if ENV["OPENAI_ORGANIZATION_ID"].present?
    config.organization_id = ENV["OPENAI_ORGANIZATION_ID"]
  end
end