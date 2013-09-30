# Frizz

Frizz is a utility for deploying static sites to S3.

## Features

* Sets Content-Type (including CSS files which S3 is notoriously bad at)
* Only uploads files that have changed
* Removes files that have been deleted locally

## Installation

Add this line to your application's Gemfile:

    gem "frizz"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install frizz

## Usage

### Configure AWS

```ruby
Frizz.configure do |config|
  config.access_key_id = ENV["AWS_ACCESS_KEY_ID"]
  config.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
end
```

### Setup your site and deploy!

```ruby
site = Frizz::Site.new("my-bucket-name.com")
site.deploy!
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
