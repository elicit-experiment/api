# frozen_string_literal: true

class MediaFile < ApplicationRecord
  mount_uploader :file, MediaUploader
end
