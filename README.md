# YandexMoney Api

[![Build Status](https://travis-ci.org/drakmail/yandex-money-ruby.svg)](https://travis-ci.org/drakmail/yandex-money-ruby)
[![Coverage Status](https://img.shields.io/coveralls/drakmail/yandex-money-ruby.svg)](https://coveralls.io/r/drakmail/yandex-money-ruby)
[![Code Climate](https://codeclimate.com/github/drakmail/yandex-money-ruby/badges/gpa.svg)](https://codeclimate.com/github/drakmail/yandex-money-ruby)

Simple gem for Yandex Money usage.

## Installation

Add this line to your application's Gemfile:

    gem 'yandex-money-ruby'

And then execute:

    $ bundle

Or install it manually with:

    $ gem install yandex-money-ruby

## Usage

### 1. Initialize API

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
```

### 2. User browser OS to send auth request to Yandex.Money server

After visiting `api.client_url` client will be redirected to `REDIRECT_URL` with `code` parameter. It is authorization code, needed for token obtaining.

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
  api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history", TOKEN)
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
  api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, 'payment.to-account("410000000000000")', TOKEN)
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
  api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, 'payment.to-account("410000000000000")', TOKEN)
  server_response = api.process_payment(
    request_id: "test-p2p",
  )
  #<OpenStruct status="success", payer="41001565326286", payee="test", credit_amount=20.3, payee_uid=56809635, test_payment="true", payment_id="test">
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
