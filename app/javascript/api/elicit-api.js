import "isomorphic-fetch";
import reduxApi, { transformers } from "redux-api";
import adapterFetch from "redux-api/lib/adapters/fetch";
import _ from 'lodash';
import { logInUser } from "../actions/tokens_actions"

import { refreshTokenIfExpired, authErrorResponseHandler, apiOptions } from "./elicit/tokens";

import { makeEntityApiDefinition } from "./elicit/rest";

import { makePaginatedApi } from "./elicit/paginatedRestApi";

import { apiRoot, defaultHeaders } from "./elicit/config";

const currentUserApiDefinition = {
    current_user: {
        url: `${apiRoot}/users/current`,
        options: {
            headers: _.extend({}, defaultHeaders),
        },
        prefetch: [
            refreshTokenIfExpired,
        ],
    },
};

const takeProtocolApiDefinition = {
    take_protocol: {
        url: `${apiRoot}/study_definitions/:study_definition_id/protocol_definitions/:protocol_definition_id/take`,
        options: {
            headers: _.extend({}, defaultHeaders),
        },
        prefetch: [
          // Because of anonymous protocols, we don't need to be logged in for this
          // refreshTokenIfExpired,
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
                if ('url' in data) {
                  window.location.href = data.url
                } else {
                 dispatch({type: `@@redux-api@anonymous_protocols_update_anonymous_protocol`,
                   id: request.pathvars.protocol_definition_id,
                   data: {
                     has_remaining_anonymous_slots: false,
                   }})
                }
            },
        ],
    },
};

const eligeableProtocolApiDefinition = {
    eligeable_protocols: {
        url: `${apiRoot}/participant/eligeable_protocols`,
        transformer: transformers.array,
        options: {
            headers: _.extend({}, defaultHeaders),
        },
        prefetch: [
            refreshTokenIfExpired,
        ],
    },
};

const anonymousProtocolsApiDefinition = {
    anonymous_protocols: {
        url: `${apiRoot}/participant/anonymous_protocols`,
        transformer: transformers.array,
        options: {
            headers: _.extend({}, defaultHeaders),
        },
        prefetch: [
        ],
      reducer(state, action) {
        if (action.type === '@@redux-api@anonymous_protocols_update_anonymous_protocol') {
          const entryIndex = state.data.findIndex((el) => el.id === action.id);
          return {
            ...state,
            data: [
              ...state.data.slice(0, entryIndex), // everything before current post
              {
                ...state.data[entryIndex],
                ...action.data,
              },
              ...state.data.slice(entryIndex + 1), // everything after current post
            ],
          }
        }
        return state;
      },
    },
};

const anonymousProtocolApiDefinition = {
  anonymous_protocol: {
    url: `${apiRoot}/participant/anonymous_protocols/:id`,
    transformer: transformers.array,
    options: {
      headers: _.extend({}, defaultHeaders),
    },
    prefetch: [
    ],
    reducer(state, action) {
      if (action.type === '@@redux-api@anonymous_protocols_update_anonymous_protocol') {
        const entryIndex = state.data.findIndex((el) => el.id === action.id);
        return {
          ...state,
          data: [
            ...state.data.slice(0, entryIndex), // everything before current post
            {
              ...state.data[entryIndex],
              ...action.data,
            },
            ...state.data.slice(entryIndex + 1), // everything after current post
          ],
        }
      }
      return state;
    },
  },
};

let userApiDefinition = makeEntityApiDefinition(apiRoot, defaultHeaders, 'user', 'users', 'users');

// for users, make sure when we post (sign up) we chain the login action)
userApiDefinition.user.postfetch.push(function ({
                                              _data,
                                              _actions,
                                              dispatch,
                                              getState,
                                              request,
                                          }) {
    if (!request || !request.params) {
      return
    }
    const {
      tokens: {
        userToken: userToken,
        userTokenIsLoading: userTokenIsLoading,
      },
    } = getState();

    // if we're just signing up, go ahead and sign in
    if (request.params.method === "POST") {
      if (!userToken && !userTokenIsLoading) {
        const creds = JSON.parse(request.params.body).user;
        dispatch(logInUser(creds));
      }
    }
  });

// no token required to POST a sign-up, but pass it if there is one (i.e. admin create scenario)
userApiDefinition.user.prefetch[0] = function(args, cb) {
  if (args.request.params.method === "POST") {
    const {
      tokens: {
        userToken: userToken,
        userTokenIsLoading: userTokenIsLoading,
      },
    } = args.getState();

    if (!userToken || !userTokenIsLoading) {
      cb();
      return;
    }
  }
  refreshTokenIfExpired(args, cb);
}


const api = reduxApi(_.extend({},
    currentUserApiDefinition,
    takeProtocolApiDefinition,
    eligeableProtocolApiDefinition,
    anonymousProtocolsApiDefinition,
    anonymousProtocolApiDefinition,
    makeEntityApiDefinition(apiRoot, defaultHeaders, 'protocol_definition', 'protocol_definitions', '/study_definitions/:study_definition_id/protocol_definitions'),
    makeEntityApiDefinition(apiRoot, defaultHeaders, 'protocol_user', 'protocol_users', '/study_definitions/:study_definition_id/protocol_definitions/:protocol_definition_id/users'),
    makeEntityApiDefinition(apiRoot, defaultHeaders, 'phase_definitions', 'phase_definitions', '/study_definitions/:study_definition_id/protocol_definitions/:protocol_definition_id/phase_definitions'),
    )).use("options", apiOptions).use("responseHandler",authErrorResponseHandler).use("fetch", adapterFetch(fetch));

const studiesApi = makePaginatedApi(makeEntityApiDefinition(apiRoot, defaultHeaders, 'study_definition', 'studies', 'study_definitions', '/study_definitions'), 'study_definition', 'studies');

const usersApi = makePaginatedApi(userApiDefinition, 'user');

const combinedApi = {
  events: [api, usersApi, studiesApi].reduce((all, element) => ({...all, ...element.events}), {}),
  reducers: [api, usersApi, studiesApi].reduce((all, element) => ({...all, ...element.reducers}), {}),
  actions: [api, usersApi, studiesApi].reduce((all, element) => ({...all, ...element.actions}), {}),
}

export default combinedApi;
