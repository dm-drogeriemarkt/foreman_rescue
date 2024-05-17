# frozen_string_literal: true

require 'test_plugin_helper'

class ProvisioningHostTest < ActiveSupport::TestCase
  setup do
    User.current = FactoryBot.build(:user, :admin)
    disable_orchestration
  end

  context 'provisioning template query' do
    context 'with type PXELinux' do
      let(:type) do
        'PXELinux'
      end

      test 'should return templates' do
        templates = ProvisioningTemplate.templates_by_kind(type)

        assert_includes templates, 'PXE Default Menu'
        assert_includes templates, 'PXELinux default local boot'
        assert_includes templates, 'PXELinux global default'
      end
    end
  end
end
