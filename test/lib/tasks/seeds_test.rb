require 'test_plugin_helper'

module ForemanRescue
  class SeedsTest < ActiveSupport::TestCase
    setup do
      Foreman.stubs(:in_rake?).returns(true)
    end

    teardown do
      User.current = nil
    end

    test 'seeds rescue provisioning templates' do
      seed
      assert ProvisioningTemplate.unscoped.where(:default => true).exists?
      expected_template_names = ['Kickstart rescue PXELinux']

      seeded_templates = ProvisioningTemplate.unscoped.where(:default => true, :vendor => 'ForemanRescue').pluck(:name)

      expected_template_names.each do |template|
        assert_includes seeded_templates, template
      end
    end

    private

    def seed
      User.current = FactoryBot.build(:user, :admin => true,
                                             :organizations => [], :locations => [])
      load Rails.root.join('db', 'seeds.rb')
    end
  end
end
