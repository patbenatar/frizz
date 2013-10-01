require "frizz"

module Frizz
  module Middleman
    module CmdHelper
      def self.run_with_live_output(cmd)
        IO.popen(cmd) do |io|
          io.each do |line|
            puts line
          end
        end
      end
    end

    class Tasks
      include Rake::DSL

      def self.install!
        new.install
      end

      def install
        namespace :frizz do
          namespace :build do
            relevant_environments.each do |name, env|
              desc "Build #{env.name}"
              task env.name do
                CmdHelper.run_with_live_output "FRIZZ_ENV=#{env.name} middleman build"
              end
            end
          end

          namespace :deploy do
            relevant_environments.each do |name, env|
              desc "Build and deploy #{env.name}"
              task env.name => ["frizz:build:#{env.name}"] do
                Frizz::Site.new(env.bucket).deploy!
              end
            end
          end
        end
      end

      private

      def relevant_environments
        Frizz.configuration.environments.reject { |name, env| name == "development" }
      end
    end
  end
end

Frizz::Middleman::Tasks.install!