import { apiOptions, authErrorResponseHandler } from './tokens';
import reduxApi, { transformers } from 'redux-api';
import { combineReducers } from 'redux';

const paginatedResponseHandler = (err, data) => {
  data = authErrorResponseHandler(err, data);

  return data;
};

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

const paginatingAdapterFetch = (fetch) => {
  return function (url, opts) {
    return fetch(url, opts).then(function (resp) {
      if (resp.status >= 400) {
        return Promise.reject({ status: resp.status, statusText: resp.statusText });
      } else {
        return toJSON(resp).then(function (data) {
          if (resp.status >= 200 && resp.status < 300) {
            if (resp.headers.get('PageSize') || resp.headers.get('Total')) {
              return {
                totalItems: parseInt(resp.headers.get('Total'), 10) || 0,
                pageSize: parseInt(resp.headers.get('PageSize'), 10) || 0,
                totalPages: parseInt(resp.headers.get('TotalPages'), 10) || 0,
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
  if (!entityPluralName) {
    entityPluralName = `${entityName}s`;
  }

  delete restApiDefinition[entityPluralName].reducer;

  const storeName = `${entityPluralName}_paginated`;

  const api = reduxApi({
    ...restApiDefinition,
    ...{ [entityPluralName]: { ...restApiDefinition[entityPluralName], transformer: transformers.object } },
  })
    .use('options', apiOptions)
    .use('responseHandler', paginatedResponseHandler)
    .use('fetch', paginatingAdapterFetch(fetch));

  const makePaginationDefaultState = () => ({
    currentPage: 1,
    totalPages: 0,
    totalItems: 0,
    pageSize: 20,
    sync: false,
    syncing: false,
    loading: false,
    data: [],
    searchQuery: '',
    sortColumn: 'created_at',
    sortDirection: 'desc',
    roleFilter: null,
    appendNextPage: false,
  });

  const initialState = makePaginationDefaultState();

  function makePagingReducerFor(api, entityPluralName) {
    return function pagingReducer(state = initialState, action) {
      let updatedItem;
      switch (action.type) {
        case api.events[storeName].reset:
          return makePaginationDefaultState();

        case api.events[storeName].setPageAsLoading:
          return { ...state, loading: true, syncing: true, sync: false };

        case api.events[storeName].setAppendNextPage:
          return { ...state, appendNextPage: true };

        case api.events[storeName].setSearchParams:
          return {
            ...state,
            searchQuery: action.searchQuery ?? state.searchQuery,
            sortColumn: action.sortColumn ?? state.sortColumn,
            sortDirection: action.sortDirection ?? state.sortDirection,
            roleFilter: action.roleFilter ?? state.roleFilter,
            appendNextPage: action.appendNextPage ?? false,
          };

        case api.events[storeName].reloadWithParams:
          return {
            ...state,
            searchQuery: action.searchQuery ?? state.searchQuery,
            sortColumn: action.sortColumn ?? state.sortColumn,
            sortDirection: action.sortDirection ?? state.sortDirection,
            roleFilter: action.roleFilter ?? state.roleFilter,
            currentPage: action.currentPage ?? 1,
            loading: true,
            syncing: true,
            appendNextPage: false,
          };

        case api.events[entityPluralName].actionSuccess:
          return {
            ...state,
            data: state.appendNextPage
              ? state.data.concat(action.data.data)
              : action.data.data,
            currentPage: action.request.pathvars?.page ?? state.currentPage,
            totalItems: action.data.totalItems,
            totalPages: action.data.totalPages ?? state.totalPages,
            pageSize: action.data.pageSize,
            loading: false,
            syncing: false,
            sync: true,
            appendNextPage: false,
          };

        case `@@redux-api@${entityPluralName}_append_${entityName}`:
          return {
            ...state,
            totalItems: state.totalItems + 1,
            data: state.data.concat(action.data),
          };

        case `@@redux-api@${entityPluralName}_delete_${entityName}`:
          return {
            ...state,
            totalItems: state.totalItems - 1,
            data: state.data.filter((item, _index) => item.id !== action.id),
          };

        case `@@redux-api@${entityPluralName}_update_${entityName}`:
          if (!action.id) console.warn('update requires id');
          if (!action.updates || action.updates.length === 0) return state;

          if (state.data.findIndex((el) => el.id === action.id) === -1) {
            return {
              ...state,
              data: state.data.concat(action.updates[0].data),
            };
          }

          updatedItem = action.updates[0];

          return {
            ...state,
            data: state.data.map((item) => {
              if (item.id === action.id) {
                return updatedItem;
              } else {
                return item;
              }
            }),
          };

        default:
          return state;
      }
    };
  }

  function makePaginatingEventsFor(entityPluralName) {
    return {
      reset: `@redux-api@paginated@${entityPluralName}@reset`,
      setPageAsLoading: `@redux-api@paginated@${entityPluralName}@setPageAsLoading`,
      setSearchParams: `@redux-api@paginated@${entityPluralName}@setSearchParams`,
      reloadWithParams: `@redux-api@paginated@${entityPluralName}@reloadWithParams`,
      setAppendNextPage: `@redux-api@paginated@${entityPluralName}@setAppendNextPage`,
    };
  }

  function buildQueryParams(state) {
    const params = { page: state.currentPage };
    if (state.searchQuery) params.q = state.searchQuery;
    if (state.sortColumn) params.sort_column = state.sortColumn;
    if (state.sortDirection) params.sort_direction = state.sortDirection;
    if (state.roleFilter) params.role = state.roleFilter;
    return params;
  }

  function makePagingActionsFor(api, entityPluralName) {
    return {
      reset: () => ({
        type: api.events[storeName].reset,
      }),

      setSearchParams: (params) => ({
        type: api.events[storeName].setSearchParams,
        ...params,
      }),

      setPageAsLoading: () => ({
        type: api.events[storeName].setPageAsLoading,
      }),

      reloadWithParams: (params) => ({
        type: api.events[storeName].reloadWithParams,
        ...params,
      }),

      goToPage: (page) => {
        return function (dispatch, getState) {
          const state = getState();
          const paginatedState = state[storeName];
          if (paginatedState.loading) return;
          if (page < 1 || page > paginatedState.totalPages) return;
          dispatch(api.actions[storeName].setSearchParams({ appendNextPage: false }));
          dispatch(api.actions[storeName].setPageAsLoading());
          dispatch(
            api.actions[entityPluralName].force({ ...buildQueryParams({ ...paginatedState, currentPage: page }) }),
          );
        };
      },

      loadNextPage: () => {
        return function (dispatch, getState) {
          const state = getState();
          const paginatedState = state[storeName];
          const nextPage = paginatedState.data.length === 0 ? 1 : paginatedState.currentPage + 1;
          if (paginatedState.loading) return;
          if (paginatedState.totalPages > 0 && nextPage > paginatedState.totalPages) return;
          dispatch(api.actions[storeName].setPageAsLoading());
          dispatch({ type: api.events[storeName].setAppendNextPage });
          dispatch(
            api.actions[entityPluralName].force({ ...buildQueryParams({ ...paginatedState, currentPage: nextPage }) }),
          );
        };
      },

      resetAndLoad: (params = {}) => {
        return function (dispatch, getState) {
          const state = getState();
          const paginatedState = state[storeName];
          if (paginatedState.loading) return;
          dispatch(api.actions[storeName].reset());
          const newState = {
            ...makePaginationDefaultState(),
            searchQuery: params.q ?? '',
            sortColumn: params.sort_column ?? 'created_at',
            sortDirection: params.sort_direction ?? 'desc',
            roleFilter: params.role ?? null,
          };
          dispatch(
            api.actions[storeName].setSearchParams({
              searchQuery: newState.searchQuery,
              sortColumn: newState.sortColumn,
              sortDirection: newState.sortDirection,
              roleFilter: newState.roleFilter,
            }),
          );
          dispatch(api.actions[storeName].setPageAsLoading());
          dispatch(api.actions[entityPluralName].force(buildQueryParams(newState)));
        };
      },

      reloadWithNewParams: (params = {}) => {
        return function (dispatch, getState) {
          const state = getState();
          const paginatedState = state[storeName];
          if (paginatedState.loading) return;
          const searchQuery = params.q ?? paginatedState.searchQuery;
          const sortColumn = params.sort_column ?? paginatedState.sortColumn;
          const sortDirection = params.sort_direction ?? paginatedState.sortDirection;
          const roleFilter = params.role ?? paginatedState.roleFilter;
          dispatch(
            api.actions[storeName].reloadWithParams({
              searchQuery,
              sortColumn,
              sortDirection,
              roleFilter,
              currentPage: 1,
            }),
          );
          dispatch(
            api.actions[entityPluralName].force({
              page: 1,
              ...(searchQuery ? { q: searchQuery } : {}),
              ...(sortColumn ? { sort_column: sortColumn } : {}),
              ...(sortDirection ? { sort_direction: sortDirection } : {}),
              ...(roleFilter ? { role: roleFilter } : {}),
            }),
          );
        };
      },
    };
  }

  api.events[storeName] = makePaginatingEventsFor(entityPluralName);
  api.reducers[storeName] = makePagingReducerFor(api, entityPluralName);
  api.actions[storeName] = makePagingActionsFor(api, entityPluralName);

  return api;
}
