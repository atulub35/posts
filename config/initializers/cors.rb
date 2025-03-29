Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://outsider-react-8de83560ff04.herokuapp.com', 'http://localhost:3000' # Or specify your React app's domain
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization', 'access-token', 'expiry', 'token-type', 'uid', 'client'],
      credentials: false # Set to true if using cookies
  end
end
