# frozen_string_literal: true

class Setting
  class Rescue < ::Setting
    BLANK_ATTRS.concat ['rescue_pxegrub_tftp_template', 'rescue_pxegrub2_tftp_template']

    def self.default_settings
      [
        set('rescue_pxelinux_tftp_template',
          N_('PXELinux template used when booting rescue system'),
          'Kickstart rescue PXELinux', N_('PXELinux rescue template'), nil,
          :collection => proc { Setting::Rescue.templates('PXELinux') }),
        set('rescue_pxegrub_tftp_template',
          N_('PXEGrub template used when booting rescue system'),
          '', N_('PXEGrub rescue template'), nil,
          :collection => proc { Setting::Rescue.templates('PXEGrub') }),
        set('rescue_pxegrub2_tftp_template',
          N_('PXEGrub2 template used when booting rescue system'),
          '', N_('PXEGrub2 rescue template'), nil,
          :collection => proc { Setting::Rescue.templates('PXEGrub2') }),
      ]
    end

    def self.load_defaults
      # Check the table exists
      return unless super

      transaction do
        default_settings.each { |s| create! s.update(:category => 'Setting::Rescue') }
      end

      true
    end

    def self.templates(kind)
      template_kind = TemplateKind.find_by(name: kind)
      templates = ProvisioningTemplate.where(:template_kind => template_kind)
      templates.each_with_object({}) do |template, hsh|
        hsh[template.name] = template.name
      end
    end

    def self.humanized_category
      N_('Rescue System')
    end
  end
end
