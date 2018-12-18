import "isomorphic-fetch";
import reduxApi, {transformers} from "redux-api";
import adapterFetch from "redux-api/lib/adapters/fetch";
import _ from 'lodash'

import {logInUser, logoutUser, refreshUserToken, resetUserToken} from "../actions/tokens_actions"
import {store} from '../store/store';

const api_root = '/api/v1';
//const public_client_id = 'admin_public';
//const public_client_secret = 'czZCaGRSa3F0MzpnWDFmQmF0M2JW';
const default_headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
};

const refreshTokenIfExpired = ({
                                   actions,
                                   dispatch,
                                   getState,
                               }, cb) => {
    const {
        tokens: {
            userToken: userToken,
            userTokenIsLoading: userTokenIsLoading,
        },
    } = getState();

    if (userToken && userToken.created_at && userToken.expires_in) {
        let expire_time = userToken.created_at + userToken.expires_in;
        console.dir(`userToken: ${JSON.stringify(userToken)}`);
        let time_to_live = expire_time * 1000 - (new Date()).getTime();
        console.log(`userToken time to live ${time_to_live} expires at ${((new Date(expire_time * 1000))).toString()}`);
        if (time_to_live < 0) {
            console.warn(`EXPIRED TOKEN! ${userTokenIsLoading ? 'load in progress' : 'load not in progress'}`);
            if (userTokenIsLoading) {
                console.log('Token load in progress, retrying in 3s');
                setTimeout(() => {
                    refreshTokenIfExpired({
                        actions: actions,
                        dispatch: dispatch,
                        getState: getState,
                    }, cb)
                }, 3000);
                return;
            }
            dispatch(refreshUserToken(userToken.access_token, userToken.refresh_token, cb));
            return;
        }
        return cb()
    }
    console.warn('refreshTokenIfExpired: no token, not making call');
    // no token? don't make the call.
};

//
// Generic endpoint, with one action set for the whole collection (which will create a store for the collection)
// and another for the CRUD operations on the individual elements.
//
const make_entity_def = (singular, plural, endpoint) => {
    let def = {};
    def[plural] = {
        url: `${api_root}/${endpoint}`,
        // reimplement default `transformers.object`
        transformer: transformers.array,
        // base endpoint options `fetch(url, options)`
        options: {
            headers: _.extend({}, default_headers),
        },
        prefetch: [
            refreshTokenIfExpired,
        ],
        // per https://github.com/lexich/redux-api/issues/114
        reducer(state, action) {
            if (action.type === `@@redux-api@${plural}_append_${singular}`) {
                return {
                    ...state,
                    data: state.data.concat(action.data),
                };
            }
            if (action.type === `@@redux-api@${plural}_delete_${singular}`) {
                return {
                    ...state,
                    data: state.data.filter((item, _index) => item.id !== action.id),
                };
            }
            if (action.type === `@@redux-api@${plural}_update_${singular}`) {
                if (state.data.findIndex((el) => (el.id === action.id)) == -1) {
                    // append if it doesn't exist
                    console.dir(action);
                    return {
                        ...state,
                        data: state.data.concat(action.updates[0]),
                    };
                }
                let newData = state.data.map((item) => {
                    if (item.id === action.id) {
                        return action.updates[0]
                    } else {
                        return item
                    }
                });
                return {
                    ...state,
                    data: newData,
                };
            }
            return state;
        },
    };
    def[singular] = {
        url: `${api_root}/${endpoint}/:id`,
        transformer: transformers.array,
        crud: true,
        prefetch: [
            refreshTokenIfExpired,
        ],
        postfetch: [
            function ({
                          data,
                          _actions,
                          dispatch,
                          _getState,
                          request,
                          _response,
                      }) {
                if (!request) {
                    debugger;
                }
                if (!request.params) {
                    //console.warn(`no request params for ${plural} ${singular}; OK if this was a GET`);
                    return
                }
                if (request.params.method === "POST") {
                    dispatch({
                        type: `@@redux-api@${plural}_append_${singular}`,
                        data,
                    });
                }
                if (request.params.method === "DELETE") {
                    dispatch({
                        type: `@@redux-api@${plural}_delete_${singular}`,
                        id: request.pathvars.id,
                    });
                }
                if (request.params.method === "PATCH") {
                    dispatch({
                        type: `@@redux-api@${plural}_update_${singular}`,
                        id: request.pathvars.id,
                        updates: data,
                    });
                }
                //        dispatch(actions.studies()); // update list of items after modify any item
            },
        ],
        options: {
            headers: _.extend({}, default_headers),
        },
    };
    return def
};

const current_user = {
    current_user: {
        url: `${api_root}/users/current`,
        options: {
            headers: _.extend({}, default_headers),
        },
        prefetch: [
            refreshTokenIfExpired,
        ],
    },
};

const take_protocol = {
    take_protocol: {
        url: `${api_root}/study_definitions/:study_definition_id/protocol_definitions/:protocol_definition_id/take`,
        options: {
            headers: _.extend({}, default_headers),
        },
        prefetch: [
// Because of anonymous protocols, we don't need to be logged in for this
            //            refreshTokenIfExpired,
        ],
        postfetch: [
            function ({
                          data,
                          _actions,
                          _dispatch,
                          _getState,
                          _request,
                          _response,
                      }) {
                window.location.href = data.url
            },
        ],
    },
};

const eligeable_protocol = {
    eligeable_protocols: {
        url: `${api_root}/participant/eligeable_protocols`,
        transformer: transformers.array,
        options: {
            headers: _.extend({}, default_headers),
        },
        prefetch: [
            refreshTokenIfExpired,
        ],
    },
};

const anonymous_protocols = {
    anonymous_protocols: {
        url: `${api_root}/participant/anonymous_protocols`,
        transformer: transformers.array,
        options: {
            headers: _.extend({}, default_headers),
        },
        prefetch: [
        ],
    },
};

let user_entity = make_entity_def('user', 'user', 'users');

// for users, make sure when we post (sign up) we chain the login action)
user_entity.user.postfetch.push(function ({
                                              _data,
                                              _actions,
                                              dispatch,
                                              _getState,
                                              request,
                                              _response,
                                          }) {
    if (!request || !request.params) {
        return
    }
    if (request.params.method === "POST") {
        const creds = JSON.parse(request.params.body).user;
        dispatch(logInUser(creds));
    }
});

const api = reduxApi(_.extend({},
    current_user,
    take_protocol,
    eligeable_protocol,
    anonymous_protocols,
    make_entity_def('study_definition', 'studies', 'study_definitions'),
    make_entity_def('protocol_definition', 'protocol_definitions', '/study_definitions/:study_definition_id/protocol_definitions'),
    make_entity_def('phase_definitions', 'phase_definitions', '/study_definitions/:study_definition_id/protocol_definitions/:protocol_definition_id/phase_definitions'),
    user_entity)).use("options", (_url, _params, getState) => {
    const {
        tokens: {
            clientToken,
            userToken,
        },
    } = getState();
    // Add token to header request
    if (userToken && userToken.access_token) {
        return {
            headers: {
                ...default_headers,
                Authorization: `Bearer ${userToken.access_token}`,
            },
        }
    }
    if (clientToken && clientToken.access_token) {
        return {
            headers: {
                ...default_headers,
                Authorization: `Bearer ${clientToken.access_token}`,
            },
        };
    }
    return default_headers;
}).use("responseHandler",
    (err, data) => {
        //console.log(`RESPONSE; err: ${JSON.stringify(err)} data: ${JSON.stringify(data)}`);

        if (err) {
            if (err.error === 'invalid_token') {
                store.dispatch(resetUserToken());
                return data;
            }

            if (err.status === 401) { // if we get a permission denied, then just logout
                store.dispatch(logoutUser());
            }

            // this is necessary because just returning the (undefined) data
            // will still cause the postfetch hook to run.
            throw err;
        }

        if (data !== undefined) {
            return data
        }

        return data;
    }).use("fetch", adapterFetch(fetch));

export default api
