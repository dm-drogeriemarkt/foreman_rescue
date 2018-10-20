module ForemanRescue
  module Orchestration
    module TFTP
      def self.prepended(base)
        base.class_eval do
          after_validation :queue_tftp_rescue
          delegate :rescue_mode, :rescue_mode?, :to => :host
        end
      end

      def queue_tftp_rescue
        return unless tftp? || tftp6?
        return if new_record?
        queue_tftp_update_rescue unless new_record?
      end

      # Overwritten because we do not want to
      # queue the tasks multiple times
      def queue_tftp_create
        super unless tftp_queued?
      end

      def queue_tftp_update_rescue
        queue_tftp_create if old.host.rescue_mode? != host.rescue_mode?
      end

      private

      # We have to overwrite default_pxe_render to hook
      # in the rescue tftp template rendering
      def default_pxe_render(kind)
        return rescue_mode_pxe_render(kind) if rescue_mode?
        super
      end

      def rescue_mode_pxe_render(kind)
        template_name = Setting["rescue_#{kind.downcase}_tftp_template"]
        template = ::ProvisioningTemplate.find_by(name: template_name)
        return if template.blank?
        host.render_template(template: template)
      rescue StandardError => e
        failure _("Unable to render %{kind} rescue template '%{name}' for TFTP: %{e}") % { :kind => kind, :name => template.try(:name), :e => e }, e
      end

      def tftp_queued?
        queue.all.select { |task| task.action[1] == :setTFTP }.present?
      end
    end
  end
end
