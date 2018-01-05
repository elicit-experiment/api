class MediaFile < ApplicationRecord
  mount_uploader :file, MediaUploader
end
