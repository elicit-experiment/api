# frozen_string_literal: true

json.array! @collection do |time_series|
  json.partial! partial: 'api/v1/shared/time_series', locals: { time_series: time_series }
end
