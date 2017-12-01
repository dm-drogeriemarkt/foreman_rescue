require 'test_plugin_helper'

class HostTest < ActiveSupport::TestCase
  setup do
    User.current = FactoryGirl.build(:user, :admin)
    setup_settings
    disable_orchestration
  end

  context 'a host with tftp orchestration' do
    let(:organization) { FactoryGirl.create(:organization) }
    let(:tax_location) { FactoryGirl.create(:location) }
    let(:template) do
      FactoryGirl.create(
        :provisioning_template,
        :template_kind => TemplateKind.find_by_name('PXELinux'),
        :locations => [tax_location],
        :organizations => [organization]
      )
    end
    let(:os) do
      FactoryGirl.create(
        :operatingsystem,
        :with_os_defaults,
        :with_associations,
        :family => 'Redhat',
        :provisioning_templates => [template]
      )
    end
    let(:host) do
      FactoryGirl.create(
        :host,
        :managed,
        :with_tftp_orchestration,
        :operatingsystem => os,
        :pxe_loader => 'PXELinux BIOS',
        :organization => organization,
        :location => tax_location
      )
    end

    context 'with rescue mode enabled' do
      setup do
        host.queue.clear
        host.rescue_mode = true
      end

      test 'should queue tftp update' do
        assert_valid host
        tasks = host.queue.all.map(&:name)
        assert_includes tasks, "Deploy TFTP PXEGrub2 config for #{host}"
        assert_includes tasks, "Deploy TFTP PXELinux config for #{host}"
        assert_includes tasks, "Deploy TFTP PXEGrub config for #{host}"
        assert_equal 3, tasks.size
      end

      test 'should deploy rescue template' do
        Setting['rescue_pxelinux_tftp_template'] = template.name
        ProxyAPI::TFTP.any_instance.expects(:set).with('PXELinux', host.mac, :pxeconfig => template.template).once
        host.stubs(:skip_orchestration?).returns(false) # Enable orchestration
        assert host.save
      end
    end
  end

  context 'rescue mode tftp remplate rendering' do
    let(:host) { FactoryGirl.build(:host, :managed, :rescue_mode) }
    let(:template) do
      FactoryGirl.create(:provisioning_template, :name => 'my template',
                                                 :template => 'test content',
                                                 :template_kind => template_kinds(:pxelinux))
    end

    test 'renders tftp template' do
      Setting['rescue_pxelinux_tftp_template'] = template.name
      rendered = host.primary_interface.send(:rescue_mode_pxe_render, 'PXELinux')
      assert_equal template.template, rendered
    end
  end
end
