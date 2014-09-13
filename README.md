# YandexMoney Api

[![Build Status](https://travis-ci.org/drakmail/yandex-money-ruby.svg)](https://travis-ci.org/drakmail/yandex-money-ruby)
[![Coverage Status](https://img.shields.io/coveralls/drakmail/yandex-money-ruby.svg)](https://coveralls.io/r/drakmail/yandex-money-ruby)
[![Code Climate](https://codeclimate.com/github/drakmail/yandex-money-ruby/badges/gpa.svg)](https://codeclimate.com/github/drakmail/yandex-money-ruby)

Simple gem for Yandex Money usage.

## Example application

You could find small example application in [sample](https://github.com/drakmail/yandex-money-ruby/tree/master/sample) directory.

## Installation

Add this line to your application's Gemfile:

    gem 'yandex-money-ruby'

And then execute:

    $ bundle

Or install it manually with:

    $ gem install yandex-money-ruby

## Usage

### Initialize API

#### Require gem

```ruby
  require 'yandex_money/api'
```

#### Initialize API

```ruby
  # If TOKEN was obtained previosly
  api = YandexMoney::Api.new(token: TOKEN)
```

```ruby
  # If TOKEN is need to be obtained
  api = YandexMoney::Api.new(
    client_id: CLIENT_ID,
    redirect_uri: REDIRECT_URI,
    scope: "account-info operation-history"
  )
  # If TOKEN is need to be obtained and client_secret key is set
  api = YandexMoney::Api.new(
    client_id: CLIENT_ID,
    redirect_uri: REDIRECT_URI,
    scope: "account-info operation-history",
    client_secret: "ACBECEBCB21411...123BCE"
  )
```

### Use user browser to send auth request to Yandex.Money server

After initializing `YandexMoney::Api` without token, you will find token request url in `api.client_url`. User need to visit that address with browser.

After visiting `api.client_url` the user will be redirected to `REDIRECT_URL` with `code` parameter. It is authorization code, needed for token obtaining.

To get token use `YandexMoney::Api#obtain_token`:

```ruby
  api.code = "ACEB6F56EC46B66F280AFB9C805C61A66A8B5" # obtained code
  token = api.obtain_token # token contains valid client token
```

## Methods

### Information about a user's account

#### account-info method

Getting information about the status of user's account. Required permissions: `account-info`.

```ruby
  api.account_info
  #<OpenStruct account="41001565326286", balance=48.98, currency="643", avatar={"ts"=>"2012-05-02T17:22:59.000+04:00", "url"=>"https://avatars.yandex.net/get-yamoney-profile/yamoney-profile-56809635-2/normal?1335964979000"}, account_type="personal", identified=false, account_status="named">
```

#### operation-history method

This method allows viewing the full or partial history of operations in page mode. History records are displayed in reverse chronological order (from most recent to oldest).

Required permissions: `operation-history`.

```ruby
  api.operation_history
  #<OpenStruct next_record="30", operations=[{"operation_id"=>"462449992116028008", "title"=>"Возврат средств от:", "amount"=>1.0, "direction"=>"in", "datetime"=>"2014-08-27T10:19:52Z", "status"=>"success", "type"=>"deposition"}, ..., {"pattern_id"=>"p2p", "operation_id"=>"460970888534110007", "title"=>"Перевод на счет 410011700000000", "amount"=>3.02, "direction"=>"out", "datetime"=>"2014-08-10T07:28:15Z", "status"=>"success", "type"=>"outgoing-transfer"}]>
  # you could pass params:
  api.operation_history(records: 1)
  #<OpenStruct next_record="1", operations=[{"pattern_id"=>"p2p", "operation_id"=>"463947376678019004", "title"=>"Перевод от 410011285000000", "amount"=>0.99, "direction"=>"in", "datetime"=>"2014-09-13T18:16:16Z", "status"=>"refused", "type"=>"incoming-transfer-protected"}]>
```

#### operation-details method

Provides detailed information about a particular operation from the history.

Required permissions: `operation-details`.

```ruby
  api.operation_details(OPERATION_ID)
  #<OpenStruct operation_id="462449992116028008", title="Возврат средств от:", amount=1.0, direction="in", datetime="2014-08-27T10:19:52Z", status="success", type="deposition", details="Отмена оплаты по банковской карте Яндекс.Денег\n , 5411, , \nНомер транзакции: 423910208430140827101810\nСумма в валюте платежа: 1.00 RUB">
```

If operation doesn't exist, exception will be raised:

```ruby
  api.operation_details "unknown"
  #   RuntimeError:
  #     Illegal param operation id
```

If scope is insufficient, expcetion will be raised:

```ruby
  api = YandexMoney::Api.new(token: TOKEN)
  api.operation_details(OPERATION_ID)
  #  RuntimeError:
  #     Insufficient Scope
```

### Payments from the Yandex.Money wallet

#### request-payment method

Creates a payment, checks parameters and verifies that the merchant can accept the payment, or that funds can be transferred to a Yandex.Money user account.

Permissions required for making a payment to a merchant: `payment.to-pattern` (Payment Pattern) or `payment-shop`.
Permissions required for transferring funds to the accounts of other users: `payment.to-account ("payee ID," "ID type")` or `payment-p2p`.

Basic request-payment method call:

```ruby
  api = YandexMoney::Api.new(token: TOKEN)
  server_response = api.request_payment(
    pattern_id: "p2p",
    to: "410011285611534",
    amount: "1.0",
    comment: "test payment comment from yandex-money-ruby",
    message: "test payment message from yandex-money-ruby",
    label: "testPayment",
  )
  #<OpenStruct status="success", contract="The generated test outgoing money transfer to 410011285611534, amount 1.0", recipient_account_type="personal", recipient_account_status="anonymous", request_id="test-p2p", test_payment="true", contract_amount=1.0, money_source={"wallet"=>{"allowed"=>true}}, recipient_identified=false>
```

#### process-payment method

Confirms a payment that was created using the `request_payment` method. Specifies the method for making the payment.

Basic process-payment method call:

```ruby
  api = YandexMoney::Api.new(token: TOKEN)
  api.process_payment(
    request_id: "test-p2p",
  )
  #<OpenStruct status="success", payer="41001565326286", payee="test", credit_amount=20.3, payee_uid=56809635, test_payment="true", payment_id="test">
```

#### incoming-transfer-accept method

Accepting incoming transfers with a secret code and deferred transfers.

There is a limit on the number of attempts to accept an incoming transfer with a secret code. When the allowed number of attempts have been used up, the transfer is automatically rejected (the transfer is returned to the sender).

Required token permissions: `incoming-transfers`.

```ruby
  api = YandexMoney::Api.new(token: TOKEN)
  api.incoming_transfer_accept "463937708331015004", "0208"
  # true
  api.incoming_transfer_accept "463937708331015004", "WRONG"
  #  RuntimeError:
  #     Illegal param protection code, attemps available: 2
```

#### incoming-transfer-reject method

Canceling incoming transfers with a secret code and deferred transfers. If the transfer is canceled, it is returned to the sender.

Required token permissions: `incoming-transfers`.

```ruby
  api = YandexMoney::Api.new(token: TOKEN)
  api.incoming_transfer_reject "463947376678019004"
  # true
  api.incoming_transfer_reject ""
  #  RuntimeError:
  #     Illegal param operation id
```

### Payments from bank cards without authorization

#### instance-id method

Registering an instance of the application.

```ruby
  api = YandexMoney::Api.new(client_id: CLIENT_ID)
  api.get_instance_id # returns string, contains instance id
```

If `client_id` is wrong - exception will be raised.

#### request-external-payment method

Creating a payment and checking its parameters.

```ruby
  api = YandexMoney::Api.new(
    client_id: CLIENT_ID,
    instance_id: INSTANCE_ID
  )
  api.request_external_payment({
    pattern_id: "p2p",
    to: "410011285611534",
    amount_due: "1.00",
    message: "test"
  })
  #<OpenStruct status="success", title="Перевод на счет 4100000000000000", contract_amount=50.0, request_id="313230...93134623165", money_source={"payment-card"=>{}}>
```

#### process-external-payment method

Making a payment. The application calls the method up until the final payment status is known (`status`=`success`/`refused`).
The recommended retry mode is determined by the `next_retry` response field (by default, 5 seconds).

```ruby
  api = YandexMoney::Api.new(instance_id: INSTANCE_ID)
  api.process_external_payment({
    request_id: REQUEST_ID,
    ext_auth_success_uri: "http://example.com/success",
    ext_auth_fail_uri: "http://example.com/fail"
  })
  #<OpenStruct status="ext_auth_required", acs_params={"cps_context_id"=>"31323039373...93134623165", "paymentType"=>"FC"}, acs_uri="https://m.sp-money.yandex.ru/internal/public-api/to-payment-type">
```

## Caveats

This library is very unstable. Pull requests welcome!

## Contributing

1. Fork it ( https://github.com/drakmail/yandex-money-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write tests with rspec + VCR
4. Write code
5. Test code
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create a new Pull Request
