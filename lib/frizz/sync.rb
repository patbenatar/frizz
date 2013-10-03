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
        local_path = remote_file.key
        local_file_md5 = local_index[local_path]

        if local_file_md5.nil?
          puts "#{local_path}: deleted".red

          remote_file.destroy
          changes << remote_file.key
        elsif local_file_md5 == remote_file.etag
          puts "#{local_path}: unchanged"

          local_index.delete(local_path)
        else
          puts "#{local_path}: updated".green

          remote.upload local.file_for(local_path), local_path
          local_index.delete(local_path)
          changes << local_path
        end
      end

      # Upload new files
      local_index.each do |local_path, md5|
        puts "#{local_path}: new".green

        remote.upload local.file_for(local_path), local_path
        changes << local_path
      end

      changes
    end

    private

    attr_reader :local, :remote

    def local_index
      @local_index ||= local.files.each_with_object({}) do |file, obj|
        obj[file.key] = file.checksum
      end
    end
  end
end