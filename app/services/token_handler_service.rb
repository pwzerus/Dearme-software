# Class to wrap functionality of generating token
# and deciphering/decrypting back details from a token
class TokenHandlerService
  # Generate a token using the given ruby hash
  # (i.e. ruby hash -> string)
  def self.generate_token_from_hash(hash)
    hash_json = hash.to_json
    self.encryptor.encrypt_and_sign(hash_json)
  end

  # Retrieve a ruby hash from a generated token,
  # NOTE:
  # - returns hash with symbolized keys ! (and not string keys)
  # - the time values are returned as strings not as Time/DateTime objects
  #   so the caller needs to parse them.
  def self.retrieve_hash_from_token(token)
    decrypted_str = self.encryptor.decrypt_and_verify(token)
    if decrypted_str.nil?
      raise "Unable to decrypt and verify the token, got nil"
    end

    decrypted_hash = JSON.parse(decrypted_str)
    decrypted_hash.symbolize_keys
  end

  private
  def self.encryptor
    encoded_key = ENV["TOKEN_ENCRYPTOR_STRICT_BASE64_ENCODED_KEY"]
    key = Base64.strict_decode64(encoded_key)
    ActiveSupport::MessageEncryptor.new(key)
  end
end
