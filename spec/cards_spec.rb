require "spec_helper"

describe "Payments from bank cards without authorization" do
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
      expect(@api.get_instance_id).to eq(INSTANCE_ID)
    end
  end

  it "should request external payment" do
    VCR.use_cassette "request external payment" do
      @api = YandexMoney::Api.new(
        client_id: CLIENT_ID,
        instance_id: INSTANCE_ID
      )
      expect(@api.request_external_payment({
        pattern_id: "p2p",
        to: "410011285611534",
        amount_due: "1.00",
        message: "test"
      }).status).to eq("success")
    end
  end

  it "should process external payment" do
    VCR.use_cassette "process external payment" do
      @api = YandexMoney::Api.new(
        instance_id: INSTANCE_ID
      )
      expect(@api.process_external_payment({
        request_id: REQUEST_ID,
        ext_auth_success_uri: "http://drakmail.ru/success",
        ext_auth_fail_uri: "http://drakmail.ru/fail"
      }).status).to eq("ext_auth_required")
    end
  end
end
