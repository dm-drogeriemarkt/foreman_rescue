module ForemanRescue
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      validate :build_and_rescue_mode
      alias_method_chain :can_be_built?, :rescue
    end

    def can_be_rescued?
      managed? && SETTINGS[:unattended] && pxe_build? && !build? && !rescue_mode?
    end

    def can_be_built_with_rescue?
      can_be_built_without_rescue? && !rescue_mode?
    end

    def set_rescue
      update(rescue_mode: true)
    end

    def cancel_rescue
      update(rescue_mode: false)
    end

    private

    def build_and_rescue_mode
      errors.add(:base, 'can either be in build mode or rescue mode, not both.') if build? && rescue_mode?
      true
    end
  end
end
