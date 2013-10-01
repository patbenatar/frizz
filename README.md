# Frizz

Frizz is a utility for deploying static sites to S3.

## Features

* Sets Content-Type (including CSS files which S3 is notoriously bad at)
* Only uploads files that have changed
* Removes files that have been deleted locally

## Installation

Add this line to your application's Gemfile:

```ruby
gem "frizz"
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install frizz
```

## Usage

### Configuration

#### AWS

Frizz will automatically look for this in ENV vars: `AWS_ACCESS_KEY_ID`
and `AWS_SECRET_ACCESS_KEY`. Or you can optionally configure manually:

```ruby
Frizz.configure do |config|
  config.access_key_id = ENV["AWS_ACCESS_KEY_ID"]
  config.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
end
```

### Basic deploys

```ruby
site = Frizz::Site.new("my-bucket-name.com")
site.deploy!
```

## Usage With Middleman

Managing more than the basic two environments (dev and build) in a Middleman app
can be a pain, which is why Frizz comes with optional Middleman-specific
functionality to make things fun again!

### `frizz.yml`

Create a `frizz.yml` in the root of your project. This is how Frizz will know
what you want in each of your environments and where you want to deploy them
to.

### Rake tasks

Based on your `frizz.yml`, Frizz will create useful Rake tasks for you.

#### Configuration

Add it to your `Rakefile`:

```ruby
require "frizz/middleman/tasks"
```

#### Usage

With the following `frizz.yml`:

```yaml
environments:
  staging:
    bucket: "staging.example.com"
  production:
    bucket: "example.com"
```

Frizz would give us the following Rake tasks:

```bash
$ rake -T
rake frizz:build:production   # Build production
rake frizz:build:staging      # Build staging
rake frizz:deploy:production  # Build and deploy production
rake frizz:deploy:staging     # Build and deploy staging
```

### Settings and Variables for each of your environments

Ever built a frontend app and wanted to hit a different API for dev, staging,
and production environments? Frizz lets you specify arbitrary environment-specific
configurations in `frizz.yml` and access them later in your Middleman app's views.

#### Configuration

Add it to your `config.rb`:

```ruby
require "frizz/middleman/view_helpers"
helpers Frizz::Middleman::ViewHelpers
```

#### Usage

With the following `frizz.yml`:

```yaml
environments:
  staging:
    bucket: "staging.example.com"
    api_root: http://api.staging.example.com/v0
    welcome_message: I'm A Staging Server
  production:
    bucket: "example.com"
    api_root: http://api.example.com/v0
    welcome_message: I'm A Production Server
  development:
    api_root: http://localhost:3000/v0
    welcome_message: Developers! Developers! Developers!
```

You would be able to access your variables from views like so:

```html
<script type="text/javascript">MyApp.config.apiRoot = "<%= frizz.api_root %>";</script>
<h1><%= frizz.welcome_message %></h1>
<h2><%= "And hi QA team!" if frizz.staging? %></h2>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
