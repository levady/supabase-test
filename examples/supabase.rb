require 'httparty'

SUPABASE_URL = "http://127.0.0.1:54321"
ANON_KEY = "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH"

# Signup
resp = HTTParty.post("#{SUPABASE_URL}/auth/v1/signup",
  headers: {
    "apikey" => ANON_KEY,
    "Content-Type" => "application/json"
  },
  body: {
    email: "nut@email.com",
    password: "supabase01",
    data: {
      display_name: "Naning Utoyo"
    }
  }.to_json
)
ACCESS_TOKEN = resp["access_token"]

# Login
resp = HTTParty.post("#{SUPABASE_URL}/auth/v1/token?grant_type=password",
  headers: {
    "apikey" => ANON_KEY,
    "Content-Type" => "application/json"
  },
  body: {
    email: "nutoyo@email.com",
    password: "supabase01"
  }.to_json
)
ACCESS_TOKEN = resp["access_token"]

# current user
r = HTTParty.get("#{SUPABASE_URL}/auth/v1/user",
  headers: {
    "Authorization" => "Bearer #{ACCESS_TOKEN}",
    "Content-Type" => "application/json",
    "Accept" => "application/json",
    "Accept-Encoding" => "identity"
})

# CRUD operations on profiles table
r = HTTParty.get("#{SUPABASE_URL}/rest/v1/profiles",
  headers: {
    "Authorization" => "Bearer #{ACCESS_TOKEN}",
    "Content-Type" => "application/json",
    "Accept" => "application/json",
    "Accept-Encoding" => "identity"
}, query: {
  id: "eq.7599407a-4ce8-408a-bc88-7f9586f7f9d3"
})

resp = HTTParty.patch("#{SUPABASE_URL}/rest/v1/profiles", headers: {
  "Authorization" => "Bearer #{ACCESS_TOKEN}",
  "Content-Type" => "application/json",
  "Prefer" => "return=representation"
},
query: {
  id: "eq.a0cb459a-f3b6-4e8d-837c-8b588593e3b9"
},
body: {
  display_name: "Naning Utoyo Updated",
}.to_json)

# CRUD operations on sessions table
r = HTTParty.get("#{SUPABASE_URL}/rest/v1/sessions",
  headers: {
    "Authorization" => "Bearer #{ACCESS_TOKEN}",
    "Content-Type" => "application/json",
    "Accept" => "application/json",
    "Accept-Encoding" => "identity"
})

resp = HTTParty.post("#{SUPABASE_URL}/rest/v1/sessions", headers: {
  "Authorization" => "Bearer #{ACCESS_TOKEN}",
  "Content-Type" => "application/json",
  "Prefer" => "return=representation"
}, body: {
  studio_name: "Life At Studio",
}.to_json)

resp = HTTParty.patch("#{SUPABASE_URL}/rest/v1/sessions", headers: {
  "Authorization" => "Bearer #{ACCESS_TOKEN}",
  "Content-Type" => "application/json",
  "Prefer" => "return=representation"
},
query: {
  id: "eq.1"
},
body: {
  studio_name: "Kinerie Studio Updated",
}.to_json)

resp = HTTParty.delete("#{SUPABASE_URL}/rest/v1/sessions", headers: {
  "Authorization" => "Bearer #{ACCESS_TOKEN}",
  "Content-Type" => "application/json",
  "Prefer" => "return=representation"
},
query: {
  id: "eq.3"
})
