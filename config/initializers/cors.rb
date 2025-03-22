Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://outsider-react-8de83560ff04.herokuapp.com", "https://outsider-react-8de83560ff04.herokuapp.com", "http://localhost:3000"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['X-CSRF-Token'] # Expose CSRF token for Rails
  end
end 