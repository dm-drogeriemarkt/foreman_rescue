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

    initializer 'foreman_rescue.register_plugin', :before => :finisher_hook do |_app| # rubocop:disable Metrics/BlockLength
      Foreman::Plugin.register :foreman_rescue do # rubocop:disable Metrics/BlockLength
        requires_foreman '>= 3.9'

        settings do
          category :rescue, N_('Rescue') do
            setting('rescue_pxelinux_tftp_template',
              type: :string,
              default: 'Kickstart rescue PXELinux',
              full_name: N_('PXELinux rescue template'),
              description: N_('PXELinux template used when booting rescue system'),
              collection: proc { ProvisioningTemplate.templates_by_kind('PXELinux') })

            setting('rescue_pxegrub_tftp_template',
              type: :string,
              default: '',
              full_name: N_('PXEGrub rescue template'),
              description: N_('PXEGrub template used when booting rescue system'),
              collection: proc { ProvisioningTemplate.templates_by_kind('PXEGrub') })

            setting('rescue_pxegrub2_tftp_template',
              type: :string,
              default: '',
              full_name: N_('PXEGrub2 rescue template'),
              description: N_('PXEGrub2 template used when booting rescue system'),
              collection: proc { ProvisioningTemplate.templates_by_kind('PXEGrub2') })
          end
        end

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
      ProvisioningTemplate.prepend ForemanRescue::ProvisioningTemplateExtensions
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
