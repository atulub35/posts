# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ['https://outsider-react-8de83560ff04.herokuapp.com', 'http://localhost:3002', 'http://localhost:3000', 'https://outsider-vue-fef499229de9.herokuapp.com'] # Updated to match client port

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['Authorization']
  end
end
