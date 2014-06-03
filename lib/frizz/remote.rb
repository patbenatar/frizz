require "s3"
require "mime-types"

module Frizz
  class Remote
    def initialize(bucket_name, ignorance)
      @bucket_name = bucket_name
      @ignorance = ignorance
    end

    def files
      @files ||= bucket.objects.reject { |o| ignore?(o) }
    end

    def upload(file, key)
      bucket.objects.build(key).tap do |obj|
        obj.acl = :public_read
        obj.content = file
        obj.content_type = MIME::Types.type_for(key).first.content_type
      end.save
    end

    private

    attr_reader :bucket_name, :ignorance

    def ignore?(object)
      ignorance.ignore?(object.key)
    end

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
