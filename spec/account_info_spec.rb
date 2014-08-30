require "spec_helper"

describe "get account info" do
  before :all do
    VCR.use_cassette "obtain token for get account info" do
      @api = YandexMoney::Api.new(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        scope: "account-info operation-history operation-details"
      )
      @api.code = "39041180F6631E2B56DD0058F75A34C7504226178A45D624313495ECD417DCC3AA6CBF1B010E65BB09F3F9EB5AE63452129BAE2B732B7457C33BE6B2039B7B60A8058D2A387729A601DC817BBFB27CB0CC2D65E3C70997D981AC0E31F18CF32C0675DFD461E2F5C5639B75AC0E5074CE64FCF4546447BBDC566E3459FB1B3C3B"
      @api.obtain_token
    end
  end

  # http://api.yandex.ru/money/doc/dg/reference/account-info.xml
  it "should return account info" do
    VCR.use_cassette "get account info" do
      info = @api.account_info
      expect(info.account).to eq("41001565326286")
    end
  end

  # http://api.yandex.com/money/doc/dg/reference/operation-history.xml
  it "should return operation history" do
    VCR.use_cassette "get operation history" do
      history = @api.operation_history
      expect(history.operations.count).to eq 30
    end
  end

  # http://api.yandex.com/money/doc/dg/reference/operation-details.xml
  describe "operation details" do
    it "should return valid operation details" do
      VCR.use_cassette "get operation details" do
        details = @api.operation_details "462449992116028008"
        expect(details.status).to eq "success"
      end
    end

    it "should raise exception if operation_id is wrong" do
      VCR.use_cassette "get wrong operation details" do
        expect { @api.operation_details "unknown" }.to raise_error "Illegal param operation id"
      end
    end
  end
end
