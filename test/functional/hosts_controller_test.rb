require 'test_plugin_helper'

module ForemanRescue
  class HostsControllerTest < ::ActionController::TestCase
    setup do
      User.current = FactoryBot.create(:user, :admin)
    end

    let(:host) { FactoryBot.create(:host, :managed) }

    describe '#set_rescue' do
      setup do
        @request.env['HTTP_REFERER'] = hosts_path
      end

      teardown do
        @request.env['HTTP_REFERER'] = ''
      end

      context 'when host is not saved' do
        test 'the flash should inform it' do
          Host::Managed.any_instance.expects(:set_rescue).returns(false)
          put :set_rescue, params: { :id => host.name }, session: set_session_user
          assert_response :found
          assert_redirected_to hosts_path
          assert flash[:error] =~ /Failed to enable #{host} for rescue system/
        end
      end

      context 'when host is saved' do
        setup do
          Host::Managed.any_instance.expects(:set_rescue).returns(true)
        end

        test 'the flash should inform it' do
          put :set_rescue, params: { :id => host.name }, session: set_session_user
          assert_response :found
          assert_redirected_to hosts_path
          assert_equal "Enabled #{host} for rescue system on next boot.", flash[:notice]
        end

        context 'when reboot is requested' do
          let(:power_mock) { mock('power') }

          setup do
            Host::Managed.any_instance.stubs(:power).returns(power_mock)
          end

          test 'the flash should inform it' do
            power_mock.stubs(:reset).returns(true)
            put :set_rescue, params: { :id => host.name, :host => { :rescue_mode => '1' } }, session: set_session_user
            assert_response :found
            assert_redirected_to hosts_path
            assert_equal "Enabled #{host} for reboot into rescue system.", flash[:notice]
          end

          test 'with failed reboot, the flash should inform it' do
            power_mock.stubs(:reset).returns(false)
            put :set_rescue, params: { :id => host.name, :host => { :rescue_mode => '1' } }, session: set_session_user
            host.power.reset
            assert_response :found
            assert_redirected_to hosts_path
            assert_equal "Enabled #{host} for boot into rescue system on next boot, but failed to power cycle the host.", flash[:notice]
          end

          test 'reboot raised exception, the flash should inform it' do
            power_mock.stubs(:reset).raises(Foreman::Exception)
            put :set_rescue, params: { :id => host.name, :host => { :rescue_mode => '1' } }, session: set_session_user
            assert_response :found
            assert_redirected_to hosts_path
            assert_equal "Enabled #{host} for rescue system on next boot.", flash[:notice]
          end
        end
      end
    end

    describe '#cancel_rescue' do
      setup do
        @request.env['HTTP_REFERER'] = hosts_path
      end

      teardown do
        @request.env['HTTP_REFERER'] = ''
      end

      context 'when host is saved' do
        setup do
          Host::Managed.any_instance.expects(:cancel_rescue).returns(true)
        end

        test 'the flash should inform it' do
          put :cancel_rescue, params: { :id => host.name }, session: set_session_user
          assert_response :found
          assert_redirected_to hosts_path
          assert_equal "Canceled booting into rescue system for #{host}.", flash[:notice]
        end
      end

      context 'when host is not saved' do
        setup do
          Host::Managed.any_instance.expects(:cancel_rescue).returns(false)
        end

        test 'the flash should inform it' do
          put :cancel_rescue, params: { :id => host.name }, session: set_session_user
          assert_response :found
          assert_redirected_to hosts_path
          assert_includes flash[:error], "Failed to cancel booting into rescue system for #{host}"
        end
      end
    end

    describe '#rescue' do
      test 'renders page' do
        get :rescue, params: { :id => host.name }, session: set_session_user
        assert_response :success
        assert_template 'foreman_rescue/hosts/rescue'
      end
    end
  end
end
