Rails.application.config.session_store :cookie_store,
  key: '_interslice_session',
  same_site: :lax,
  secure: Rails.env.production?,
  httponly: true,
  max_age: 1.day 