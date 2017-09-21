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

const api = reduxApi({
  studies: {
    url: `${api_root}/study_definitions`,
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
      if (action.type === "@@redux-api@studies_append_study_definition") {
        return {...state,
          data: state.data.concat(action.data)
        };
      }
      if (action.type === "@@redux-api@studies_delete_study_definition") {
        //        debugger;
        return {...state,
          data: state.data.filter((item, index) => item.id !== action.id)
        };
      }
      return state;
    }

  },

  study_definition: {
    url: `${api_root}/study_definitions/:id`,
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
        if (request.params.method === "POST") {
          dispatch({
            type: "@@redux-api@studies_append_study_definition",
            data
          });
        }
        if (request.params.method === "DELETE") {
          dispatch({
            type: "@@redux-api@studies_delete_study_definition",
            id: request.pathvars.id
          });
        }
        //        dispatch(actions.studies()); // update list of items after modify any item
      }
    ],
    options: {
      headers: _.extend({}, default_headers)
    }
  },
}).use("options", (url, params, getState) => {
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