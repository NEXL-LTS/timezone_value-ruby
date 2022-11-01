# frozen_string_literal: true

module TimezoneValue
  class JobSerializer < ActiveJob::Serializers::ObjectSerializer
    def serialize?(argument)
      argument.is_a?(TimezoneValue::Base)
    end

    def serialize(value)
      super("value" => value.to_s)
    end

    def deserialize(hash)
      TimezoneValue.cast(hash["value"])
    end
  end
end
