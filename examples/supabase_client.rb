require 'httparty'

class SupabaseClient
  attr_reader :url, :anon_key

  def initialize
    @url = ENV.fetch("SUPABASE_URL", "http://localhost:54321")
    @anon_key = ENV.fetch("SUPABASE_ANON_KEY", "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH")
  end

  def current_user
    HTTParty.get("#{url}/auth/v1/user", headers: auth_headers)
  end

  def signup(email:, password:, display_name:)
    HTTParty.post("#{url}/auth/v1/signup",
      headers: {
        "apikey" => anon_key,
        "Content-Type" => "application/json"
      },
      body: {
        email: email,
        password: password,
        data: {
          display_name: display_name
        }
      }.to_json
    ).tap do |response|
      @access_token = response["access_token"]
      @user_id = response.dig("user", "id")
    end
  end

  def signin(email:, password:)
    HTTParty.post("#{url}/auth/v1/token?grant_type=password",
      headers: {
        "apikey" => anon_key,
        "Content-Type" => "application/json"
      },
      body: {
        email: email,
        password: password
      }.to_json
    ).tap do |response|
      @access_token = response["access_token"]
      @user_id = response.dig("user", "id")
    end
  end

  def update_profile(display_name: nil, avatar_url: nil)
    body = {}
    body[:display_name] = display_name if display_name
    body[:avatar_url] = avatar_url if avatar_url

    HTTParty.patch("#{url}/rest/v1/profiles",
      headers: auth_headers,
      query: {
        id: "eq.#{user_id}"
      },
      body: body.to_json
    )
  end

  def get_profiles
    HTTParty.get("#{url}/rest/v1/profiles",
      headers: auth_headers,
      query: {
        id: "eq.#{user_id}"
      }
    )
  end

  def get_sessions
    HTTParty.get("#{url}/rest/v1/sessions", headers: auth_headers)
  end

  def get_session(session_id:)
    HTTParty.get("#{url}/rest/v1/sessions",
      headers: auth_headers,
      query: {
        id: "eq.#{session_id}"
      }
    )
  end

  def create_session(studio_name:)
    HTTParty.post("#{url}/rest/v1/sessions",
      headers: auth_headers,
      body: {
        studio_name: studio_name
      }.to_json
    )
  end

  def delete_session(session_id:)
    HTTParty.delete("#{url}/rest/v1/sessions",
      headers: auth_headers,
      query: {
        id: "eq.#{session_id}"
      }
    )
  end

  def update_session(session_id:, studio_name: nil)
    body = {}
    body[:studio_name] = studio_name if studio_name

    HTTParty.patch("#{url}/rest/v1/sessions",
      headers: auth_headers,
      query: {
        id: "eq.#{session_id}"
      },
      body: body.to_json
    )
  end

  def upload_avatar(local_file_path:)
    storage_path = "#{user_id}/avatar.webp"

    upload_response = HTTParty.post(
      "#{@url}/storage/v1/object/avatars/#{storage_path}",
      headers: auth_headers.merge(
        "Content-Type" => "image/webp",
        "x-upsert" => "true"
      ),
      body: File.binread(local_file_path)
    )
    raise upload_response.body unless upload_response.success?

    profile_response = update_profile(avatar_url: storage_path)
    raise profile_response.body unless profile_response.success?

    {
      avatar_path: storage_path,
      avatar_url: "#{@url}/storage/v1/object/public/avatars/#{storage_path}"
    }
  end

  private

  def access_token
    @access_token || raise("You must login first to get an access token")
  end

  def auth_headers
    {
      "apikey" => anon_key,
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json",
      "Prefer" => "return=representation"
    }
  end

  def user_id
    @user_id ||= access_token and current_user.fetch("id")
  end
end
