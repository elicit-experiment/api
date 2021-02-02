import {transformers} from "redux-api";
import {refreshTokenIfExpired} from "./tokens";

import _ from 'lodash';

import { apiRoot, defaultHeaders } from "./config";


//
// Generic endpoint, with one action set for the whole collection (which will create a store for the collection)
// and another for the CRUD operations on the individual elements.
//
export const makeEntityApiDefinition = (apiRoot, defaultHeaders, singular, plural, endpoint) => {
  let def = {};
  def[plural] = {
    url: `${apiRoot}/${endpoint}`,
    // reimplement default `transformers.object`
    transformer: transformers.array,
    // base endpoint options `fetch(url, options)`
    options: {
      headers: _.extend({}, defaultHeaders),
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
        if (!action.id) console.warn('update requires id');
        if (!action.updates || action.updates.length === 0) return state;

        console.dir(state);
        if (state.data.findIndex((el) => (el.id === action.id)) === -1) {
          // append if it doesn't exist
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
    url: `${apiRoot}/${endpoint}/:id`,
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
                } ) {
        if (!request) {
          console.error('NO REQUEST');
          // debugger;
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
        if (request.params.method === "PATCH" && data) {
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
      headers: _.extend({}, defaultHeaders),
    },
  };
  return def
};
