# Posts Application

A Ruby on Rails application for managing posts with a modern web interface.

## Prerequisites

- Ruby 3.2.2
- Node.js
- Redis
- PostgreSQL

## Live Demo
https://outsider-284373f8936c.herokuapp.com
User Name
```bash
atul612@gmail.com
```
Password
```bash
12345678
```

## Setup

1. Clone the repository:
```bash
git clone <your-repository-url>
cd posts
```

2. Install dependencies:
```bash
bundle install
yarn install
```

3. Set up the database:
```bash
rails db:create db:migrate
```

4. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

## Running the Application

1. Start the development server:
```bash
./bin/dev
```

This will start:
- Rails server
- Vite dev server
- Redis server

2. Visit http://localhost:3000 in your browser

## Testing

Run the test suite:
```bash
rails test
```

## Features

- Modern web interface using Hotwire and Turbo
- Real-time updates
- User authentication
- Post management
- Comments system

## Deployment

The application is configured for deployment on platforms like Heroku. Make sure to:

1. Set up the required environment variables
2. Configure the database
3. Set up Redis
4. Run migrations

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request
