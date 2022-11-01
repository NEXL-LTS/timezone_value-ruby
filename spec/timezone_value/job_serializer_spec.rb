# frozen_string_literal: true

require "active_job"
require "active_job/arguments"
require "timezone_value/job_serializer"

module TimezoneValue
  RSpec.describe JobSerializer do
    subject { described_class.instance }

    it "can cast and serialize regular value" do
      value = TimezoneValue.cast("UTC")
      value_serialized = subject.serialize(value)
      value_casted = subject.deserialize(value_serialized)

      expect(value_serialized).to be_a(Hash)
      expect(value_casted).to eq(value)
    end

    it "can cast and serialize blank value" do
      value = TimezoneValue.cast("")
      value_serialized = subject.serialize(value)
      value_casted = subject.deserialize(value_serialized)

      expect(value_serialized).to be_a(Hash)
      expect(value_casted).to eq(value)
    end

    it "can cast and serialize nil value" do
      value = TimezoneValue.cast(nil)
      value_serialized = subject.serialize(value)
      value_casted = subject.deserialize(value_serialized)

      expect(value_serialized).to be_a(Hash)
      expect(value_casted).to eq(value)
    end

    it "can cast and serialize exceptional value" do
      value = TimezoneValue.cast("{exceptional}")
      value_serialized = subject.serialize(value)
      value_casted = subject.deserialize(value_serialized)

      expect(value_serialized).to be_a(Hash)
      expect(value_casted).to eq(value)
    end
  end
end
