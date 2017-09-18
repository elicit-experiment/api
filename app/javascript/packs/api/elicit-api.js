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


const api = reduxApi({
  studies: {
    url: `${api_root}/study_definitions`,
    // reimplement default `transformers.object`
    transformer: transformers.array,
    // base endpoint options `fetch(url, options)`
    options: {
      headers: _.extend({}, default_headers)
    }
  },

  new_study_definition: {
    reducerName: 'updateStudyDefinition',
    url: `${api_root}/study_definitions`,
    virtual: true,
    transformer: transformers.array,
    options: {
      method: 'post',
    },
    postfetch: [
      function({
        dispatch,
        actions
      }) {
        debugger;
        dispatch(actions.studies()); // update list of items after modify any item
      }
    ]
  },

  // simple endpoint description
  entry: `/api/v1/entry/:id`,
  // complex endpoint description
  regions: {
    url: `/api/v1/regions`,
    // reimplement default `transformers.object`
    transformer: transformers.array,
    // base endpoint options `fetch(url, options)`
    validation: (data, cb) => {
      console.dir(data)
        // check data format
      return true
    },
    options: {
      headers: {
        "Accept": "application/json"
      }
    }
  }
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
        Authorization: `Bearer ${userToken}`
      }
    };
  }
  return headers;
}).use("responseHandler",
  (err, data) => {
    console.dir(err)
    if (err && (err.error == 'invalid_token')) {
      store.dispatch(resetUserToken())
    }
    return data;
  }).use("fetch", adapterFetch(fetch));

export default api