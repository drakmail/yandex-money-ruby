require "spec_helper"

describe "auth" do
  before :all do
    VCR.use_cassette "obtain token for payments from bank cards without authorization" do
      @api = YandexMoney::Api.new(
        client_id: CLIENT_ID
      )
    end
  end
  it "should fail when try to register an instance of application without connected market" do
    VCR.use_cassette "get instance id fail" do
      expect { @api.get_instance_id }.to raise_exception("Illegal param client id")
    end
  end

  it "should register an instance of application" do
    VCR.use_cassette "get instance id success" do
      expect(@api.get_instance_id).to eq("1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1")
    end
  end
end
