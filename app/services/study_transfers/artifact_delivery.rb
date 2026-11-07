# frozen_string_literal: true

require 'active_storage/service/disk_service'
require 'active_storage/service/s3_service'

module StudyTransfers
  class ArtifactDelivery
    def self.local?(blob)
      blob.service.is_a?(ActiveStorage::Service::DiskService)
    end

    def self.signed_url(blob)
      service = blob.service
      if service.is_a?(ActiveStorage::Service::S3Service)
        # Existing Spaces delivery avoids response-header overrides, which have
        # caused Bad Gateway responses. Reuse the configured service's bucket,
        # endpoint and credentials, with a bounded capability lifetime.
        service.bucket.object(blob.key).presigned_url(:get, expires_in: 5.minutes.to_i)
      else
        blob.url(expires_in: 5.minutes, disposition: 'attachment')
      end
    end
  end
end
