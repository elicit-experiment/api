import {apiOptions, authErrorResponseHandler} from "./tokens";
import reduxApi, {transformers} from "redux-api";

const paginatedResponseHandler = (err, data) => {
  data = authErrorResponseHandler(err, data);

  return data;
}

function processData(data) {
  try {
    return JSON.parse(data);
  } catch (err) {
    return data;
  }
}

function toJSON(resp) {
  if (resp.text) {
    return resp.text().then(processData);
  } else if (resp instanceof Promise) {
    return resp.then(processData);
  } else {
    return Promise.resolve(resp).then(processData);
  }
}

// custom version to handler pagination links
const paginatingAdapterFetch = (fetch) => {
  return function (url, opts) {
    return fetch(url, opts).then(function (resp) {
      // Normalize IE9's response to HTTP 204 when Win error 1223.
      const status = resp.status === 1223 ? 204 : resp.status;
      const statusText = resp.status === 1223 ? "No Content" : resp.statusText;

      if (status >= 400) {
        return Promise.reject({ status: status, statusText: statusText });
      } else {
        return toJSON(resp).then(function (data) {
          if (status >= 200 && status < 300) {
            if (resp.headers.get('PageSize') || resp.headers.get('Total')) {
              return {
                totalItems: parseInt(resp.headers.get('Total'), 10),
                pageSize: parseInt(resp.headers.get('PageSize'), 10),
                data,
              };
            }
            return data;
          } else {
            return Promise.reject(data);
          }
        });
      }
    });
  };
};

export function makePaginatedApi(restApiDefinition, entityName, entityPluralName = undefined) {
  if (!entityPluralName) { entityPluralName = `${entityName}s`; }

  // since the paginated is a "top level" api, we have to delete its reducer which expects the state to be the individual-entity
  // level within a larger composite api
  delete restApiDefinition[entityPluralName].reducer;
  
  const storeName = `${entityPluralName}_paginated`;
  
  const api = reduxApi({...restApiDefinition, ...{[entityPluralName]: {...restApiDefinition[entityPluralName], transformer: transformers.object}}})
    .use("options", apiOptions)
    .use("responseHandler", paginatedResponseHandler)
    .use("fetch",  paginatingAdapterFetch(fetch));

  const makePaginationDefaultState = () => ({ currentPage: 0, totalItems: 0, pageSize: 0, sort: null, filter: null, sync: false, syncing: false, loading: false, data: [] })

  const initialState = makePaginationDefaultState();

  function makePagingReducerFor(api, entityPluralName) {
    return function pagingReducer(state = initialState, action) {
      let updatedItem;
      const newState = Object.assign(state);
      switch(action.type) {
        case api.events[storeName].reset:
          return makePaginationDefaultState()
        case api.events[storeName].setCurrentPage:
          return makePaginationDefaultState()
        case api.events[storeName].setNextPageAsLoading:
          return { ...state, loading: true, syncing: true, sync: false }
        case api.events[storeName].setQueryArgs:
          // eslint-disable-next-line no-case-declarations
          const { sort, filter } = action.data;
          return { ...makePaginationDefaultState(), sort, filter };
        case api.events[entityPluralName].actionSuccess:
          newState.data = newState.data.concat(action.data.data);
          if ('page' in action.request.pathvars) {
            newState.currentPage = action.request.pathvars.page;
          }
          newState.totalItems = action.data.totalItems;
          newState.pageSize = action.data.pageSize;
          newState.loading = false;
          newState.syncing = false;
          newState.sync = true;
          return Object.assign({}, state, newState)
          // TODO: consolidate with rest.js version here
        case `@@redux-api@${entityPluralName}_append_${entityName}`:
            return {
              ...state,
              totalItems: state.totalItems + 1,
              data: state.data.concat(action.data),
            };
        case`@@redux-api@${entityPluralName}_delete_${entityName}`:
            return {
              ...state,
              data: state.data.filter((item, _index) => item.id !== action.id),
            };
         case `@@redux-api@${entityPluralName}_update_${entityName}`:
            if (!action.id) console.warn('update requires id');
            if (!action.updates || action.updates.length === 0) return state;

            if (state.data.findIndex((el) => (el.id === action.id)) === -1) {
              // append if it doesn't exist
              return {
                ...state,
                data: state.data.concat(action.updates[0].data),
              };
            }

            updatedItem = action.updates[0];

            if ('data' in updatedItem) {
//              debugger;
            }

            // merge if it does
            return {
              ...state,
              data: state.data.map((item) => {
                if (item.id === action.id) {
                  return updatedItem
                } else {
                  return item
                }
              }),
            };
        default:
          return state;
      }
    }
  }

  function makePaginatingEventsFor(entityPluralName) {
    return {
      reset: `@redux-api@paginated@${entityPluralName}@reset`,
      setNextPageAsLoading: `@redux-api@paginated@${entityPluralName}@setNextPageAsLoading`,
      setQueryArgs: `@redux-api@paginated@${entityPluralName}@setQueryArgs`,
      setCurrentPage: `@redux-api@paginated@${entityPluralName}@setCurrentPage`,
    }
  }

  function makePagingActionsFor(api, entityPluralName) {
    return {
      reset: () => ({
        type: api.events[storeName].reset,
      }),
      setQueryArgs: (queryArgs) => ({
        type: api.events[storeName].setQueryArgs,
        data: queryArgs,
      }),
      setNextPageAsLoading: () => ({type: api.events[storeName].setNextPageAsLoading}),
      ensureQueryArgs: (queryArgs) => {
        return function (dispatch, getState) {
          const state = getState();
          const sort = queryArgs.sort === 'up' ? 'up' : null;
          const filter = queryArgs.filter.length > 0 ? queryArgs.filter : null;
          console.dir(queryArgs)
          if (state[storeName].sort !== sort || state[storeName].filter !== filter) {
            dispatch(api.actions[storeName].setQueryArgs({sort, filter}));
          }
        }
      },
      loadNextPage: () => {
        return function (dispatch, getState) {
          const state = getState();
          const { sort, filter, currentPage } = state[storeName];
          const nextPage = currentPage + 1;

          console.log(`page: ${currentPage} ${nextPage}`)
          if (state[storeName].loading) { return }

          dispatch(api.actions[storeName].setNextPageAsLoading())
          const queryParams = Object.fromEntries(Object.entries({ page: nextPage, sort, filter  })
            .filter(([_, v]) => v != null));
          dispatch(api.actions[entityPluralName].force(queryParams));
        }
      },
    }
  }

  api.events[storeName] = makePaginatingEventsFor(entityPluralName);
  api.reducers[storeName] =  makePagingReducerFor(api, entityPluralName);
  api.actions[storeName] = makePagingActionsFor(api, entityPluralName);

  return api;
}
