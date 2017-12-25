class MediaFiles < ApplicationRecord
  mount_uploader :file, MediaUploader
end
