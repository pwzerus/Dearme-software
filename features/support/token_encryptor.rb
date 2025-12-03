Before do
  # So that the tests run properly on CI, set the environment
  # variable with a mock token encryptor key.
  len = ActiveSupport::MessageEncryptor.key_len
  salt  = SecureRandom.random_bytes(len)
  secret = "Very Very Very secret"
  key = ActiveSupport::KeyGenerator.new(secret).generate_key(salt, len)
  mock_strict_base64_key = Base64.strict_encode64(key)

  ENV["TOKEN_ENCRYPTOR_STRICT_BASE64_ENCODED_KEY"] = mock_strict_base64_key
end
