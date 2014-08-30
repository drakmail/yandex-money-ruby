require "spec_helper"

describe "Payments from the Yandex.Money wallet" do
  describe "make payment to an account" do
    before :all do
      VCR.use_cassette "obtain token for making payments to an account" do
        @api = YandexMoney::Api.new(
          client_id: CLIENT_ID,
          redirect_uri: REDIRECT_URI,
          scope: 'payment.to-account("410011285611534")'
        )
        @api.code = "F0EF348A2AE89F87040E46618C029CB9D6EFC2BFC9254F959D9A629FDD3A4EB6DA067D6422D0E008D098802A0B612F583B72FA9E332C73D21E1F770CBCC6AAF81818859E79AA6018621504572A0B217B7F7456FEE5422AF85D7790C04D51779966700EF8E45B32B4342E411A3E185C3E58B72BBEAAE069D681BCC3D542B3CE1D"
        @api.obtain_token
      end
    end

    it "success request payment" do
      VCR.use_cassette "success request payment to an account" do
        server_response = @api.request_payment(
          pattern_id: "p2p",
          to: "410011285611534",
          amount: "1.0",
          comment: "test payment comment from yandex-money-ruby",
          message: "test payment message from yandex-money-ruby",
          label: "testPayment",
          test_payment: "true",
          test_result: "success"
        )
        expect(server_response.status).to eq "success"
      end
    end

    it "raise exception without requered params when request payment" do
      VCR.use_cassette "request payment to an account with failure" do
        expect {
          @api.request_payment(
            pattern_id: "p2p",
            to: "410011285611534",
            test_payment: "true",
            test_result: "success"
          )
        }.to raise_error "Illegal params"
      end
    end
  end
end
