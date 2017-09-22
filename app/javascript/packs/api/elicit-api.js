import "isomorphic-fetch";
import reduxApi, {
  transformers
} from "redux-api";
import adapterFetch from "redux-api/lib/adapters/fetch";

import $ from 'jquery'
import _ from 'lodash'

import {
  resetUserToken
} from "../actions/tokens_actions"

const api_root = '/api/v1'
const public_client_id = 'admin_public'
const public_client_secret = 'czZCaGRSa3F0MzpnWDFmQmF0M2JW'
const default_headers = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
}

import {
  store
} from '../store/store';

import {
  refreshUserToken
} from '../actions/tokens_actions'

import update from 'react-addons-update'

const refreshTokenIfExpired = ({
  actions,
  dispatch,
  getState
}, cb) => {
  const {
    tokens: {
      userToken: userToken
    }
  } = getState();
  let expire_time = userToken.created_at + userToken.expires_in
  console.log(expire_time)
  if (expire_time < (new Date()).getTime()) {
    console.log('EXPIRED TOKEN')
    dispatch(refreshUserToken(userToken.access_token, userToken.refresh_token, cb))
    return
  }
  return cb()
}

//
// Generic endpoint, with one action set for the whole collection (which will create a store for the collection)
// and another for the CRUD operations on the individual elements.
//
const make_entity_def = (singular, plural, endpoint) => {
  var def = {}
  def[plural] = {
    url: `${api_root}/${endpoint}`,
    // reimplement default `transformers.object`
    transformer: transformers.array,
    // base endpoint options `fetch(url, options)`
    options: {
      headers: _.extend({}, default_headers)
    },
    prefetch: [
      refreshTokenIfExpired
    ],
    // per https://github.com/lexich/redux-api/issues/114
    reducer(state, action) {
      if (action.type === `@@redux-api@${plural}_append_${singular}`) {
        return {...state,
          data: state.data.concat(action.data)
        };
      }
      if (action.type === `@@redux-api@${plural}_delete_${singular}`) {
        return {...state,
          data: state.data.filter((item, index) => item.id !== action.id)
        };
      }
      if (action.type === `@@redux-api@${plural}_update_${singular}`) {
        return {...state,
          data: state.data.map((item) => {
            if (item.id === action.id) {
              return action.updates[0]
            } else {
              return item
            }
          })
        };
      }
      return state;
    }
  }
  def[singular] = {
    url: `${api_root}/${endpoint}/:id`,
    transformer: transformers.array,
    crud: true,
    prefetch: [
      refreshTokenIfExpired
    ],
    postfetch: [
      function({
        data,
        actions,
        dispatch,
        getState,
        request,
        response
      }) {
        if (!request || !request.params) {
          debugger;
        }
        if (request.params.method === "POST") {
          dispatch({
            type: `@@redux-api@${plural}_append_${singular}`,
            data
          });
        }
        if (request.params.method === "DELETE") {
          dispatch({
            type: `@@redux-api@${plural}_delete_${singular}`,
            id: request.pathvars.id
          });
        }
        if (request.params.method === "PATCH") {
          dispatch({
            type: `@@redux-api@${plural}_update_${singular}`,
            id: request.pathvars.id,
            updates: data
          });
        }
        //        dispatch(actions.studies()); // update list of items after modify any item
      }
    ],
    options: {
      headers: _.extend({}, default_headers)
    }
  }
  return def
}

const current_user = {
  current_user: {
    url: `${api_root}/users/current`,
    options: {
      headers: _.extend({}, default_headers)
    },
    prefetch: [
      refreshTokenIfExpired
    ]
  }
}

const api = reduxApi(_.extend({},
  current_user,
  make_entity_def('study_definition', 'studies', 'study_definitions'),
  make_entity_def('user', 'user', 'users'))).use("options", (url, params, getState) => {
  const {
    tokens: {
      clientToken,
      userToken
    }
  } = getState();
  // Add token to header request
  if (userToken) {
    return {
      headers: {...default_headers,
        Authorization: `Bearer ${userToken.access_token}`
      }
    };
  }
  return headers;
}).use("responseHandler",
  (err, data) => {
    if (data !== undefined) {
      return data
    }
    if (err && (err.error == 'invalid_token')) {
      store.dispatch(resetUserToken())
      return data
    }
    if (err) {
      // this is necessary because just returning the (undefiend) data 
      // will still cause the postfetch hook to run.
      throw "bad";
    }
    return data;
  }).use("fetch", adapterFetch(fetch));

export default api