module ForemanRescue
  module HostsHelperExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :host_title_actions, :rescue
    end

    def host_title_actions_with_rescue(host)
      title_actions(
        button_group(
          if host.rescue_mode?
            link_to_if_authorized(_('Cancel rescue'), hash_for_cancel_rescue_host_path(:id => host).merge(:auth_object => host, :permission => 'rescue_hosts'),
                                  :disabled => host.can_be_rescued?,
                                  :title    => _('Cancel rescue system for this host.'),
                                  :class => 'btn btn-default',
                                  :method => :put)
          else
            link_to_if_authorized(_('Rescue'), hash_for_rescue_host_path(:id => host).merge(:auth_object => host, :permission => 'rescue_hosts'),
                                  :disabled => !host.can_be_rescued?,
                                  :title    => _('Activate rescue mode for this host.'),
                                  :class    => 'btn btn-default')
          end
        )
      )
      host_title_actions_without_rescue(host)
    end
  end
end
