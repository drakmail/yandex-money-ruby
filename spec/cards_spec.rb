require "spec_helper"

describe "auth" do
  before :all do
    VCR.use_cassette "obtain token for payments from bank cards without authorization" do
    end
  end
  it "should fail when try to register an instance of application without connected market" do
    VCR.use_cassette "get instance id fail" do
      @api = YandexMoney::Api.new(
        client_id: nil
      )
      expect { @api.get_instance_id }.to raise_exception("Illegal param client id")
    end
  end

  it "should register an instance of application" do
    VCR.use_cassette "get instance id success" do
      @api = YandexMoney::Api.new(
        client_id: CLIENT_ID
      )
      expect(@api.get_instance_id).to eq("zRhKWeiQVphBSd6I/A8p28R4uRMx9QPPW1nviyTFkQf+a73JuX2jSD0gVEQhWtOH")
    end
  end
end
