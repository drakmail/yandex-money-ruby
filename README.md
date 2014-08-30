# YandexMoney Api

Simple gem for Yandex Money usage.

## Installation

Add this line to your application's Gemfile:

    gem 'yandex-money-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yandex-money-ruby

## Usage

### 1. Initialize API

```ruby
# If TOKEN was obtained previosly
api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history", TOKEN)
```

```ruby
# If TOKEN need to be obtained
api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
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

Getting information about the status of the user account. Required permissions: `account-info`.

```ruby
api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history", TOKEN)
api.account_info
#<OpenStruct account="41001565326286", balance=48.98, currency="643", avatar={"ts"=>"2012-05-02T17:22:59.000+04:00", "url"=>"https://avatars.yandex.net/get-yamoney-profile/yamoney-profile-56809635-2/normal?1335964979000"}, account_type="personal", identified=false, account_status="named">
```

## Caveats

This library very unstable. Pull requests welcome!

## Contributing

1. Fork it ( https://github.com/drakmail/yandex-money-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write tests with rspec + VCR
4. Write code
5. Test code
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create a new Pull Request
