require 'aws-sdk'
require "mime-types"

module Frizz
  class Remote
    def initialize(bucket_name, ignorance, options = {})
      @options = options
      @bucket_name = bucket_name
      @ignorance = ignorance
    end

    def files
      @files ||= objects.reject { |o| ignore?(o) }
    end

    def upload(file, key, options = {})
      object_options = {
        bucket: bucket_name,
        body: file,
        acl: 'public-read',
        content_type: MIME::Types.type_for(key).first.content_type,
        key: key
      }

      object_options[:website_redirect_location] = options[:redirect_to] if options[:redirect_to]

      client.put_object object_options
    end

    def delete(remote_file)
      client.delete_object(
        bucket: bucket_name,
        key: remote_file.key
      )
    end

    private

    attr_reader :bucket_name, :ignorance, :options

    def ignore?(object)
      ignorance.ignore?(object.key)
    end

    def objects
      paginate(client.list_objects(bucket: bucket_name), [])
    end

    def client
      @client ||= Aws::S3::Client.new(
        region: options[:region],
        credentials: Aws::Credentials.new(
          Frizz.configuration.access_key_id,
          Frizz.configuration.secret_access_key
        )
      )
    end

    def paginate(response, contents = [])
      contents.push *response.contents
      response.next_page? ? paginate(response.next_page, contents) : contents
    end
  end
end
