# frozen_string_literal: true

module Api
  module V2
    class StudyTransfersController < ApplicationController
      include Authenticatable
      before_action -> { doorkeeper_authorize! :public }
      before_action :require_investigator!

      rescue_from CanCan::AccessDenied do
        head :forbidden
      end
      rescue_from StudyTransfers::Conflict do |error|
        render json: { error: error.message }, status: :conflict
      end
      rescue_from ArgumentError, JSON::ParserError do |error|
        render json: { error: error.message }, status: :unprocessable_entity
      end

      def import_definition
        study = authorized_study if request.path_parameters[:study_id]
        options = {}
        if study
          expected = request.query_parameters['expected_revision_id']
          raise ArgumentError, 'expected_revision_id is required' unless expected&.match?(/\A[0-9a-f]{64}\z/)

          options['expected_revision_id'] = expected
        end
        submit('import_definition', study: study, options: options)
      end

      def import_results
        study = authorized_study
        revision = authorized_revision(study)
        submit('import_results', study: study, revision: revision)
      end

      def export_results
        study = authorized_study
        revision = authorized_revision(study)
        options = JSON.parse(request.raw_post.presence || '{}')
        raise ArgumentError, 'Only participant_ids may be supplied' unless options.is_a?(Hash) && (options.keys - ['participant_ids']).empty?

        if options.key?('participant_ids')
          ids = options['participant_ids']
          unless ids.is_a?(Array) && ids.size.between?(1, 10_000) && ids.all? { |id| id.is_a?(String) && id.size.between?(1, 200) }
            raise ArgumentError, 'participant_ids must contain 1 to 10000 nonempty string IDs'
          end

          options['participant_ids'] = ids.uniq.sort
        end
        submit('export_results', study: study, revision: revision, options: options)
      end

      def show
        operation = authorized_operation
        render json: operation_document(operation)
      end

      def retry_operation
        operation = authorized_operation
        operation.with_lock do
          raise StudyTransfers::Conflict, 'Only failed operations may be retried' unless operation.status == 'failed'

          operation.update!(status: 'queued', phase: 'queued', diagnostics: [], claim_token: nil, lease_expires_at: nil)
        end
        ::StudyTransfers::Submission.enqueue(operation)
        response.set_header('Location', api_v2_study_operation_url(operation))
        render json: operation_document(operation), status: :accepted
      end

      def definition
        study = authorized_study
        revision = authorized_revision(study)
        render json: revision.compiled_contract.fetch('definition')
      end

      def result_schema
        study = authorized_study
        render json: authorized_revision(study).compiled_contract
      end

      def download
        operation = authorized_operation
        unless operation.status == 'succeeded'
          head :conflict
          return
        end
        attachment = operation.artifacts_attachments.find(request.path_parameters[:artifact_id])
        blob = attachment.blob
        if StudyTransfers::ArtifactDelivery.local?(blob)
          send_file blob.service.path_for(blob.key), filename: blob.filename.to_s, type: blob.content_type, disposition: 'attachment'
        else
          redirect_to StudyTransfers::ArtifactDelivery.signed_url(blob), allow_other_host: true
        end
      end

      private

      def require_investigator!
        head :forbidden unless [User::ROLES[:admin], User::ROLES[:investigator]].include?(current_user&.role)
      end

      def authorized_study
        study = StudyDefinition.find(request.path_parameters[:study_id])
        raise CanCan::AccessDenied unless current_user.is_admin? || study.principal_investigator_user_id == current_user.id

        study
      end

      def authorized_revision(study)
        CanonicalStudyRevision.find_by!(study_definition: study, definition_digest: request.path_parameters[:revision_id])
      end

      def authorized_operation
        operation = StudyTransferOperation.find(request.path_parameters[:id])
        raise CanCan::AccessDenied unless operation.requester_id == current_user.id || current_user.is_admin?
        if operation.study_definition && !current_user.is_admin? && operation.study_definition.principal_investigator_user_id != current_user.id
          raise CanCan::AccessDenied
        end

        operation
      end

      def submit(kind, study: nil, revision: nil, options: {})
        request.body.rewind
        operation = StudyTransfers::Submission.create!(
          requester: current_user, kind: kind, key: request.headers['Idempotency-Key'],
          source: request.body, study: study, revision: revision, options: options
        )
        response.set_header('Location', api_v2_study_operation_url(operation))
        render json: operation_document(operation), status: :accepted
      end

      def operation_document(operation)
        artifacts = operation.artifacts_attachments.includes(:blob).map do |attachment|
          blob = attachment.blob
          link = download_api_v2_study_operation_url(operation, artifact_id: attachment.id)
          { id: attachment.id, filename: blob.filename.to_s, bytes: blob.byte_size, url: link,
            download_url: StudyTransfers::ArtifactDelivery.local?(blob) ? link : StudyTransfers::ArtifactDelivery.signed_url(blob),
            expires_at: StudyTransfers::ArtifactDelivery.local?(blob) ? nil : 5.minutes.from_now.iso8601 }
        end
        { id: operation.id, kind: operation.kind, status: operation.status, phase: operation.phase,
          study_id: operation.study_definition_id, revision_id: operation.canonical_study_revision&.definition_digest,
          diagnostics: operation.diagnostics, result: operation.result, artifacts: artifacts,
          links: { self: api_v2_study_operation_url(operation) } }
      end
    end
  end
end
