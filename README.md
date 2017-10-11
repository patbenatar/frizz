# Frizz

Frizz is a utility for deploying static sites to S3. It also comes with
some nifty Middleman integrations for managing environments.

## Features

* Sets Content-Type (including CSS files which S3 is notoriously bad at)
* Only uploads files that have changed
* Removes files that have been deleted locally
* Invalidate changed files on CloudFront
* Supports S3 redirects

### Middleman Features

* Free rake tasks for building and deploying your environments
* Accessing environment-specific configurations from your views

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

### Caveats

This gem is built against Ruby 2 and there are known issues when running
against 1.9. If you experience those issues, try upgrading your Ruby or please
add backwards compatibility and send a PR.

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

Deploy the contents of `build/` to your bucket named "my-static-site.com":

```ruby
site = Frizz::Site.new("my-static-site.com", region: "us-west-2")
site.deploy!
```

Specify a different local build dir:

```ruby
site = Frizz::Site.new("my-static-site.com", region: "us-west-2", from: "build/public")
```

### Deploy with CloudFront invalidation

Optionally provide a CloudFront Distribution ID and Frizz will invalidate
the cache for any files that changed or were removed in the deploy. Note:
invalidating a CloudFront cache can take some time.

```ruby
site = Frizz::Site.new("my-bucket", region: "us-west-2", distribution: "DISTRIBUTION_ID")
site.deploy!
```

### Prefer Gzipped files in a deploy

If you want to serve gzipped files, you can specify that for each environment in `frizz.yml`:

```yaml
environments:
  production:
    prefer_gzip: true
```

### Ignore files in a deploy

If you want to ignore files or directories when syncing local with remote
(`logs/` for example), you can specify patterns to ignore for each environment
in `frizz.yml`:

```yaml
environments:
  production:
    ignore:
      - "logs/*"
```

### Redirects

You can setup [S3 redirects](http://docs.aws.amazon.com/AmazonS3/latest/dev/how-to-page-redirect.html)
in `frizz.yml`:

```yaml
environments:
  production:
    redirect_rules:
      - from: "old/page.html"
        to: "/new/page.html"
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

Based on your `frizz.yml`, Frizz will create useful Rake tasks for building
and deploying.

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
    host: "staging.example.com"
    region: "us-west-2"
  production:
    host: "example.com"
    region: "us-west-2"
    distribution: "CLOUDFRONT_DISTRIBUTION_ID"
```

Frizz would give us the following Rake tasks:

```bash
$ rake -T
rake frizz:build:production    # Build production
rake frizz:build:staging       # Build staging
rake frizz:deploy:production   # Deploy build dir to production: example.com
rake frizz:deploy:staging      # Deploy build dir to staging: staging.example.com
rake frizz:release:production  # Build and deploy production: example.com
rake frizz:release:staging     # Build and deploy staging: staging.example.com
```

##### Custom bucket names

If your buckets aren't named following the S3 static site naming conventions
(maybe you're putting a CDN in front of it and not using S3 static site
hosting), you can set a `bucket:` key along for each environment in `frizz.yml`
and it will be used to determine where to upload the build to.

### Settings and Variables for each of your environments

Ever built a frontend app and wanted to hit a different API for dev, staging,
and production environments? Frizz lets you specify arbitrary environment-specific
configurations in `frizz.yml` and access them later in your Middleman app's views.

#### Configuration

Active the Extension in your `config.rb`:

```ruby
require "frizz/middleman/extension"
activate :frizz
```

#### Usage

With the following `frizz.yml`:

```yaml
environments:
  staging:
    host: "staging.example.com"
    region: "us-west-2"
    api_root: http://api.staging.example.com/v0
    welcome_message: I'm A Staging Server
  production:
    host: "example.com"
    region: "us-west-2"
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
