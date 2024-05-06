# frozen_string_literal: true

module ForemanRescue
  class Engine < ::Rails::Engine
    engine_name 'foreman_rescue'

    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]

    # Add any db migrations
    initializer 'foreman_rescue.load_app_instance_data' do |app|
      ForemanRescue::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_monitoring.load_default_settings',
      :before => :load_config_initializers do |_app|
      if begin
        Setting.table_exists?
      rescue StandardError
        false
      end
        require_dependency File.expand_path('../../app/models/setting/rescue.rb', __dir__)
      end
    end

    initializer 'foreman_rescue.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_rescue do
        requires_foreman '>= 3.9'

        # Add permissions
        security_block :foreman_rescue do
          permission :rescue_hosts, :'foreman_rescue/hosts' => [:rescue, :set_rescue, :cancel_rescue]
        end
      end
    end

    config.to_prepare do
      Host::Managed.prepend ForemanRescue::HostExtensions
      HostsHelper.prepend ForemanRescue::HostsHelperExtensions
      Nic::Managed.prepend ForemanRescue::Orchestration::TFTP
    rescue StandardError => e
      Rails.logger.warn "ForemanRescue: skipping engine hook (#{e})"
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        ForemanRescue::Engine.load_seed
      end
    end

    initializer 'foreman_rescue.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../..', __dir__), 'locale')
      locale_domain = 'foreman_rescue'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
