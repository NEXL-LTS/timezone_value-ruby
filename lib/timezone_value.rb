# frozen_string_literal: true

require "active_support"
require "active_model"
require "rails_values/whole_value_concern"
require "rails_values/exceptional_value"

module TimezoneValue
  class Error < StandardError; end

  module Base
    include RailsValues::WholeValueConcern
    include Comparable

    def initialize(val)
      @raw_value = val
    end

    def <=>(other)
      return to_str <=> other.to_s if other.nil?

      identifier <=> TimezoneValue.cast(other).identifier
    end

    def eql?(other)
      identifier == TimezoneValue.cast(other).identifier
    end

    def code
      identifier.gsub("GMT-", "GMT_M").gsub(%r{[/\-+]}, "_").upcase
    end

    def name
      tz_info.to_s
    end

    def to_s
      identifier
    end

    def hash
      identifier.hash
    end
  end

  class AsBlank
    include Base

    def blank?
      true
    end

    def identifier
      ""
    end

    def tz_info
      TZInfo::Timezone.get("UTC")
    end
  end

  class Exceptional
    include Base

    attr_reader :reason

    def initialize(raw_value, reason = "has a invalid value of #{raw_value}")
      @raw_value = raw_value
      @reason = reason
    end

    def exceptional?
      true
    end

    def regular?
      false
    end

    def exceptional_errors(errors, attribute, _options = nil)
      errors.add(attribute, @reason)
    end

    def to_s
      @raw_value.to_s
    end

    def identifier
      @raw_value
    end

    def tz_info
      nil
    end
  end

  class Regular
    include Base

    attr_reader :identifier, :tz_info

    def initialize(tz_info)
      @identifier = tz_info.identifier
      @tz_info = ActiveSupport::TimeZone.new(@identifier)
      freeze
    end
  end

  def self.is?(val)
    cast(val).regular?
  end

  def self.all
    @all ||= TZInfo::Timezone.all_data_zones.sort_by(&:name)
                             .map { |tz| cast(tz) }.sort_by(&:name).freeze
  end

  # @return [Timezone]
  def self.cast(content)
    return content if content.is_a? TimezoneValue
    return Regular.new(content) if content.is_a? TZInfo::Timezone

    return AsBlank.new(content) if content.blank?

    Regular.new(TZInfo::Timezone.get(content))
  rescue TZInfo::InvalidTimezoneIdentifier
    all.find { |t| t.code == content } ||
      Exceptional.new(content, "has a invalid value of #{content}")
  end
end

require_relative "timezone_value/railtie" if defined?(Rails) && defined?(Rails::Railtie)
