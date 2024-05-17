# frozen_string_literal: true

module ForemanRescue
  module ProvisioningTemplateExtensions
    module ClassMethods
      def templates_by_kind(kind)
        template_kind = TemplateKind.find_by(name: kind)
        ProvisioningTemplate.where(:template_kind => template_kind).pluck(:name, :name).to_h
      end
    end
  end
end
