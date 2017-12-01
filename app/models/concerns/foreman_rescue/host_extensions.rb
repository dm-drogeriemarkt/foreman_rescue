module ForemanRescue
  module HostExtensions
    def self.prepended(base)
      base.class_eval do
        validate :build_and_rescue_mode
      end
    end

    def can_be_rescued?
      managed? && SETTINGS[:unattended] && pxe_build? && !build? && !rescue_mode?
    end

    def can_be_built?
      super && !rescue_mode?
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
