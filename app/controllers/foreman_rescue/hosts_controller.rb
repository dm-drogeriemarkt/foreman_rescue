module ForemanRescue
  class HostsController < ::HostsController
    before_action :find_resource, :only => [:rescue, :set_rescue, :cancel_rescue]
    define_action_permission ['rescue', 'set_rescue', 'cancel_rescue'], :rescue

    def rescue; end

    def set_rescue
      forward_url_options
      if @host.set_rescue
        if params[:host] && params[:host][:rescue_mode] == '1'
          begin
            message = if @host.power.reset
                        _('Enabled %s for reboot into rescue system.')
                      else
                        _('Enabled %s for boot into rescue system on next boot, but failed to power cycle the host.')
                      end
            process_success :success_msg => message % @host, :success_redirect => :back
          rescue StandardError => error
            message = _('Failed to reboot %s.') % @host
            warning(message)
            Foreman::Logging.exception(message, error)
            process_success :success_msg => _('Enabled %s for rescue system on next boot.') % @host, :success_redirect => :back
          end
        else
          process_success :success_msg => _('Enabled %s for rescue system on next boot.') % @host, :success_redirect => :back
        end
      else
        process_error :redirect => :back, :error_msg => _('Failed to enable %{host} for rescue system: %{errors}') % { :host => @host, :errors => @host.errors.full_messages.to_sentence }
      end
    end

    def cancel_rescue
      if @host.cancel_rescue
        process_success :success_msg => _('Canceled booting into rescue system for %s.') % @host.name, :success_redirect => :back
      else
        process_error :redirect => :back,
                      :error_msg => _('Failed to cancel booting into rescue system for %{hostname} with the following errors: %{errors}') %
                                    { :hostname => @host.name, :errors => @host.errors.full_messages.to_sentence }
      end
    end
  end
end
