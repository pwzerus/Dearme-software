require 'rails_helper'

describe TokenHandlerService do
  # happy path
  it "should encrypt hash into a token and decrypt back properly" do
    h = {
      a: 10,
      b: "Bla Ble Blu"
    }

    token = TokenHandlerService.generate_token_from_hash(h)
    expect(token).not_to be_nil

    retrieved_h = TokenHandlerService.retrieve_hash_from_token(token)
    expect(retrieved_h).to eq(h)
  end

  describe "retrieve_hash_from_token" do
    it "should raise error if decryption returns ni;" do
      invalid_token = ""
      allow_any_instance_of(ActiveSupport::MessageEncryptor)
        .to receive(:decrypt_and_verify).and_return(nil)
      expect {
          described_class.retrieve_hash_from_token("bla")
      }.to raise_error(StandardError)
    end
  end
end
