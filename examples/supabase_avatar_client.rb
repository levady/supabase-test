require "httparty"
require "json"

class SupabaseAvatarClient
  def initialize(access_token:)
    @url = ENV.fetch("SUPABASE_URL", "http://127.0.0.1:54321")
    @key = ENV.fetch("SUPABASE_ANON_KEY", "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH")
    @access_token = access_token
  end

  def upload_avatar(user_id:, local_file_path:)
    storage_path = "#{user_id}/avatar.webp"

    upload_response = HTTParty.post(
      "#{@url}/storage/v1/object/avatars/#{storage_path}",
      headers: auth_headers.merge(
        "Content-Type" => "image/webp",
        "x-upsert" => "true"
      ),
      body: File.binread(local_file_path)
    )
binding.irb
    raise upload_response.body unless upload_response.success?

    profile_response = HTTParty.patch(
      "#{@url}/rest/v1/profiles?id=eq.#{user_id}",
      headers: auth_headers.merge(
        "Content-Type" => "application/json",
        "Prefer" => "return=representation"
      ),
      body: {
        avatar_url: storage_path,
      }.to_json
    )

    raise profile_response.body unless profile_response.success?

    {
      avatar_path: storage_path,
      avatar_url: "#{@url}/storage/v1/object/public/avatars/#{storage_path}"
    }
  end

  private

  def auth_headers
    {
      "apikey" => @key,
      "Authorization" => "Bearer #{@access_token}"
    }
  end
end