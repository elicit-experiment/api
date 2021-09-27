# frozen_string_literal: true

# Helper module for denilize
module Denilize
  # https://stackoverflow.com/questions/23903055/how-to-replace-all-nil-value-with-in-a-ruby-hash-recursively
  def self.denilize(hash)
    hash.transform_values do |value|
      value.is_a?(Hash) ? denilize(value) : value || ''
    end
  end
end
