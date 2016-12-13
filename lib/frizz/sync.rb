module Frizz
  class Sync
    def initialize(local, remote)
      @local = local
      @remote = remote
    end

    def run!
      changes = []

      # Sync existing files
      remote.files.each do |remote_file|
        local_path = remote.file_local_path(remote_file.key)
        local_file = local_index[local_path]
        local_file_md5 = local_file && local_file.checksum

        if local_file_md5.nil?
          puts "#{local_path}: deleted".red

          remote.delete(remote_file)
          changes << remote_file.key
        elsif local_file_md5 == remote_file.etag.gsub('"', '')
          puts "#{local_path}: unchanged"

          local_index.delete(local_path)
        else
          puts "#{local_path}: updated".green

          upload(local_path, local_file)
          local_index.delete(local_path)
          changes << local_path
        end
      end

      # Upload new files
      local_index.each do |local_path, local_file|
        puts "#{local_path}: new".green

        upload(local_path, local_file)
        changes << local_path
      end

      changes
    end

    private

    attr_reader :local, :remote

    def local_index
      @local_index ||= local.files.each_with_object({}) do |file, obj|
        obj[file.key] = file
      end
    end

    def upload(local_path, local_file)
      remote.upload local.file_for(local_path), local_path, local_file.upload_options
    end
  end
end
