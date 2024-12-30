# frozen_string_literal: true

class FinalizeTimeseriesCommand < ApplicationCommand
  attr_reader :time_series_relation

  def initialize(time_series_relation:)
    super()

    @time_series_relation = time_series_relation
  end

  def execute
    updated_time_series = time_series_relation.find_each.filter_map do |time_series|
      time_series if time_series.finalize
    end

    { updated_time_series: updated_time_series }
  end
end
