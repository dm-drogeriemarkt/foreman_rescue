User.as_anonymous_admin do
  templates = [
    { :name => 'Kickstart rescue PXELinux', :source => 'PXELinux/kickstart_rescue_pxelinux.erb', :template_kind => TemplateKind.find_by(:name => 'PXELinux') }
  ]

  templates.each do |template|
    template[:contents] = File.read(File.join(ForemanRescue::Engine.root, 'app/views/foreman/unattended/provisioning_templates', template[:source]))
    ProvisioningTemplate.where(:name => template[:name]).first_or_create do |pt|
      pt.vendor = 'ForemanRescue'
      pt.default = true
      pt.locked = true
      pt.name = template[:name]
      pt.template = template[:contents]
      pt.template_kind = template[:template_kind] if template[:template_kind]
      pt.snippet = template[:snippet] if template[:snippet]
    end
  end
end
