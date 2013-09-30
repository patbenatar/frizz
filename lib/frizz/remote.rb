require "s3"
require "mime-types"

module Frizz
  class Remote
    def initialize(bucket_name)
      @bucket_name = bucket_name
    end

    def files
      @files ||= bucket.objects
    end

    def upload(file, key)
      bucket.objects.build(key).tap do |obj|
        obj.acl = :public_read
        obj.content = file
        obj.content_type = MIME::Types.type_for(key).first.content_type
      end.save
    end

    private

    attr_reader :bucket_name

    def bucket
      @bucket ||= service.buckets.find(bucket_name)
    end

    def service
      @service ||= S3::Service.new(
        access_key_id: Frizz.configuration.access_key_id,
        secret_access_key: Frizz.configuration.secret_access_key,
      )
    end
  end
end