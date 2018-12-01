import PropTypes from 'prop-types';

export const RequestShapeType = PropTypes.shape({});

export const MatchType = PropTypes.shape({
    isExact: PropTypes.bool.isRequired,
    params: RequestShapeType.isRequired,
    path: PropTypes.string.isRequired,
    url: PropTypes.string.isRequired
}).isRequired;

export const CurrentUserType = PropTypes.shape({
    data: PropTypes.shape({
        anonymous: PropTypes.bool.isRequired,
        created_at: PropTypes.string.isRequired,
        email: PropTypes.string.isRequired,
        id: PropTypes.number.isRequired,
        role: PropTypes.string.isRequired,
        updated_at: PropTypes.string.isRequired,
        username: PropTypes.string.isRequired
    }).isRequired,
    error: PropTypes.any,
    loading: PropTypes.bool.isRequired,
    request: RequestShapeType.isRequired,
    sync: PropTypes.bool.isRequired,
    syncing: PropTypes.bool.isRequired
}).isRequired;

export const UserTokenType = PropTypes.shape({
    access_token: PropTypes.string.isRequired,
    created_at: PropTypes.number.isRequired,
    expires_in: PropTypes.number.isRequired,
    refresh_token: PropTypes.string.isRequired,
    scope: PropTypes.string.isRequired,
    token_type: PropTypes.string.isRequired
}).isRequired;

