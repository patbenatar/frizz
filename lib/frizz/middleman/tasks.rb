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
                FileUtils.rm_rf(Dir[".cache"])
                CmdHelper.run_with_live_output "FRIZZ_ENV=#{env.name} middleman build"
              end
            end
          end

          namespace :deploy do
            relevant_environments.each do |name, env|
              desc "Deploy build dir to #{env.name}: #{env.bucket}"
              task env.name do
                Frizz::Site.new(
                  env.bucket,
                  distribution: env.distribution,
                  ignore: env.ignore,
                  redirect_rules: env.redirect_rules,
                  region: env.region
                ).deploy!
              end
            end
          end

          namespace :release do
            relevant_environments.each do |name, env|
              desc "Build and deploy #{env.name}: #{env.bucket}"
              task env.name => ["frizz:build:#{env.name}", "frizz:deploy:#{env.name}"] do; end
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
