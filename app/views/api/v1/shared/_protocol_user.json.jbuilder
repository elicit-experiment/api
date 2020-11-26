json.extract! protocol_user, :id, :user_id, :group_name, :protocol_definition_id

json.protocol_definition do
  json.partial! 'api/v1/shared/protocol_definition', protocol_definition: protocol_user.protocol_definition
end

json.extract! protocol_user, :experiment
json.extract! protocol_user, :study_definition

