# Yandex-Money-Ruby

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
api = Yandex::Money::Ruby::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
```

### 2. User browser OS to send auth request to Yandex.Money server

After visiting `api.client_url` client will be redirected to `REDIRECT_URL` with `code` parameter. It is authorization code, needed for token obtaining.

To get token use `Yandex::Money::Ruby::Api#obtain_token`:

```ruby
api.code = "ACEB6F56EC46B66F280AFB9C805C61A66A8B5" # obtained code
token = api.obtain_token # token contains valid client token
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
