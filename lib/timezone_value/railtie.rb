# frozen_string_literal: true

require "rails_values"

module TimezoneValue
  class Railtie < ::Rails::Railtie
    initializer "rails_values_railtie.configure_rails_initialization" do
      require_relative "job_serializer"
      Rails.application.config.active_job.custom_serializers << JobSerializer

      require "rails_values/simple_string_converter"
      ActiveRecord::Type.register(:rv_timezone_value) do
        RailsValues::SimpleStringConverter.new(TimezoneValue)
      end
    end
  end
end
