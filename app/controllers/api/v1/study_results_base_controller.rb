# frozen_string_literal: true

module Api
  module V1
    class StudyResultsBaseController < ApiController
      include StudyResultConcern
    end
  end
end
