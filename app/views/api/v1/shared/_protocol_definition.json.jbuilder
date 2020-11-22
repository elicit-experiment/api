json.extract! protocol_definition, :id, :name, :version, :summary, :active, :description, :study_definition_id, :type, :definition_data, :created_at, :updated_at

json.study_definition do
  json.partial! 'api/v1/shared/study_definition', study_definition: protocol_definition.study_definition
end
