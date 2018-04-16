module ForemanRescue
  module Orchestration
    module TFTP
      extend ActiveSupport::Concern

      included do
        after_validation :queue_tftp_rescue
        delegate :rescue_mode, :rescue_mode?, :to => :host
        alias_method_chain :queue_tftp_create, :rescue
        alias_method_chain :default_pxe_render, :rescue
      end

      def queue_tftp_rescue
        return unless tftp? || tftp6?
        return if new_record?
        queue_tftp_update_rescue
      end

      # Overwritten because we do not want to
      # queue the tasks multiple times
      def queue_tftp_create_with_rescue
        queue_tftp_create_without_rescue unless tftp_queued?
      end

      def queue_tftp_update_rescue
        queue_tftp_create if old.host.rescue_mode? != host.rescue_mode?
      end

      private

      # We have to overwrite default_pxe_render to hook
      # in the rescue tftp template rendering
      def default_pxe_render_with_rescue(kind)
        return rescue_mode_pxe_render(kind) if rescue_mode?
        default_pxe_render_without_rescue(kind)
      end

      def rescue_mode_pxe_render(kind)
        template_name = Setting["rescue_#{kind.downcase}_tftp_template"]
        template = ::ProvisioningTemplate.find_by(name: template_name)
        return if template.blank?
        unattended_render template
      rescue StandardError => e
        failure _("Unable to render %{kind} rescue template '%{name}' for TFTP: %{e}") % { :kind => kind, :name => template.try(:name), :e => e }, e
      end

      def tftp_queued?
        queue.all.select { |task| task.action[1] == :setTFTP }.present?
      end
    end
  end
end
