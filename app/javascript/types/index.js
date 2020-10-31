import PropTypes from 'prop-types';

export const ApiReturnCollectionOf = (BaseType) => PropTypes.shape({
  data: PropTypes.arrayOf(BaseType).isRequired,
  error: PropTypes.any,
  loading: PropTypes.bool.isRequired,
  request: PropTypes.shape({}),
  sync: PropTypes.bool.isRequired,
  syncing: PropTypes.bool.isRequired,
});

export const ApiReturnValueOf = (BaseType) => PropTypes.shape({
  data: BaseType,
  error: PropTypes.any,
  loading: PropTypes.bool.isRequired,
  request: PropTypes.shape({}),
  sync: PropTypes.bool.isRequired,
  syncing: PropTypes.bool.isRequired,
});

export const RequestShapeType = PropTypes.shape({});

export const MatchType = PropTypes.shape({
    isExact: PropTypes.bool.isRequired,
    params: RequestShapeType.isRequired,
    path: PropTypes.string.isRequired,
    url: PropTypes.string.isRequired,
}).isRequired;

export const LocationType = PropTypes.shape({
    hash: PropTypes.string.isRequired,
    key: PropTypes.string.isRequired,
    pathname: PropTypes.string.isRequired,
    search: PropTypes.string.isRequired,
}).isRequired;

export const UserType = PropTypes.shape({
  anonymous: PropTypes.bool,
  created_at: PropTypes.string,
  email: PropTypes.string,
  id: PropTypes.number,
  role: PropTypes.string,
  updated_at: PropTypes.string,
  username: PropTypes.string,
});

export const CurrentUserType = ApiReturnValueOf(UserType);

export const UserTokenType = PropTypes.shape({
    access_token: PropTypes.string,
    created_at: PropTypes.number.isRequired,
    expires_in: PropTypes.number.isRequired,
    refresh_token: PropTypes.string.isRequired,
    scope: PropTypes.string.isRequired,
    token_type: PropTypes.string.isRequired,
});

export const ProtocolDefinitionType = PropTypes.shape({
    active: PropTypes.bool.isRequired,
    created_at: PropTypes.string.isRequired,
    definition_data: PropTypes.string.isRequired,
    description: PropTypes.string.isRequired,
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    study_definition_id: PropTypes.number.isRequired,
    summary: PropTypes.string.isRequired,
    updated_at: PropTypes.string.isRequired,
    version: PropTypes.any,
});

export const ExperimentType = PropTypes.shape({
    completed_at: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
    current_stage_id: PropTypes.any,
    id: PropTypes.number.isRequired,
    num_stages_completed: PropTypes.number.isRequired,
    num_stages_remaining: PropTypes.number.isRequired,
    protocol_user_id: PropTypes.number.isRequired,
    started_at: PropTypes.any,
    study_result_id: PropTypes.number.isRequired,
    updated_at: PropTypes.string.isRequired,
});

export const StudyDefinitionType = PropTypes.shape({
    AllowAnonymousUsers: PropTypes.any,
    MaxAnonymousUsers: PropTypes.any,
    ShowInStudyList: PropTypes.any,
    created_at: PropTypes.string.isRequired,
    data: PropTypes.string.isRequired,
    description: PropTypes.string.isRequired,
    enable_previous: PropTypes.number.isRequired,
    footer_label: PropTypes.string.isRequired,
    id: PropTypes.number.isRequired,
    lock_question: PropTypes.number.isRequired,
    no_of_trials: PropTypes.any,
    principal_investigator_user_id: PropTypes.number.isRequired,
    redirect_close_on_url: PropTypes.string.isRequired,
    title: PropTypes.string.isRequired,
    trials_completed: PropTypes.any,
    updated_at: PropTypes.string.isRequired,
    version: PropTypes.number.isRequired,
});

export const ProtocolUserType = PropTypes.shape({
    created_at: PropTypes.string.isRequired,
    experiment: ExperimentType.isRequired,
    group_name: PropTypes.any,
    id: PropTypes.number.isRequired,
    protocol_definition: ProtocolDefinitionType.isRequired,
    protocol_definition_id: PropTypes.number.isRequired,
    study_definition: StudyDefinitionType.isRequired,
    updated_at: PropTypes.string.isRequired,
    user_id: PropTypes.number.isRequired,
});

export const GenerateApiResultPropTypeFor = (obj) => PropTypes.shape({
  data: obj,
  error: PropTypes.any,
  loading: PropTypes.bool.isRequired,
  request: PropTypes.shape({}).isRequired,
  sync: PropTypes.bool.isRequired,
  syncing: PropTypes.bool.isRequired,
});

export const EligibleProtocolsType = PropTypes.shape({
    data: PropTypes.arrayOf(ProtocolUserType).isRequired,
    error: PropTypes.any,
    loading: PropTypes.bool.isRequired,
    request: PropTypes.shape({}).isRequired,
    sync: PropTypes.bool.isRequired,
    syncing: PropTypes.bool.isRequired,
});

export const AnonymousProtocolsType = ApiReturnCollectionOf(ProtocolDefinitionType);
