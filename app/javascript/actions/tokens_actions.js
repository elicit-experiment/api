import {
  fetchClientToken,
  fetchUserToken,
  fetchRefreshUserToken,
} from '../api/api.js'

export const REQUEST_CLIENT_TOKEN = "REQUEST_CLIENT_TOKEN";
export const RECEIVE_CLIENT_TOKEN = "RECEIVE_CLIENT_TOKEN";
export const LOGIN_USER = "USER_CREATE_SUCCESS";
export const RECEIVE_USER_TOKEN = "RECEIVE_USER_TOKEN";
export const RESET_USER_TOKEN = "RESET_USER_TOKEN";
export const LOGOUT_USER = "LOGOUT_USER";
export const CLIENT_TOKEN_IS_LOADING = 'CLIENT_TOKEN_IS_LOADING';
export const USER_TOKEN_STATE = 'USER_TOKEN_STATE';

export function clientTokenIsLoading(bool) {
  return {
    type: CLIENT_TOKEN_IS_LOADING,
    clientTokenIsLoading: bool,
  };
}

export function userTokenIsLoading(bool) {
  return {
    type: USER_TOKEN_STATE,
    userTokenState: {
      loading: bool,
      error: false,
      error_message: false,
    },
  };
}

export function userTokenState(state) {
  return {
    type: USER_TOKEN_STATE,
    userTokenState: state,
  };
}

export const requestClientToken = (asyncDoneCallback) => {
  return (dispatch) => {
    dispatch(clientTokenIsLoading(true));

    const processSuccess = (data) => {
      dispatch(receiveClientToken(data));
      dispatch(clientTokenIsLoading(false))
    };

    const error = (e) => {
      console.log("error in tokens middleware:", e)
    };

    fetchClientToken().then(processSuccess).then(asyncDoneCallback).catch(error);
  };
};

export const receiveClientToken = (clientToken) => ({
  type: RECEIVE_CLIENT_TOKEN,
  clientToken,
});

export const logInUser = (credentials, asyncDoneCallback) => {
  return (dispatch) => {
    dispatch(userTokenIsLoading(true));
    dispatch(userTokenState({
      loading: true,
      error: false,
      error_code: 0,
      error_message: "",
    }));

    const gotData = (data) => {
      dispatch(userTokenIsLoading(false));
      dispatch(userTokenState({
        loading: false,
        error: false,
        error_code: 0,
        error_message: "",
      }));
      dispatch(receiveUserToken(data))
    };

    const error = (e) => {
      console.dir(e);
      dispatch(userTokenState({
        loading: false,
        error: true,
        error_code: e.status,
        error_message: e.statusText,
      }))
    };

    fetchUserToken(credentials).then(gotData).then(asyncDoneCallback).catch(error);
  };
};

export const refreshUserToken = (access_token, refresh_token, asyncDoneCallback) => {
  return (dispatch) => {
    dispatch(userTokenIsLoading(true));

    const gotData = (data) => {
      dispatch(userTokenIsLoading(false));
      dispatch(receiveUserToken(data))
    };

    const error = (e) => {
      // TODO : maybe we retry?
      console.log(`Failed to refresh user token; treating as logout. Error ${e}`);
      dispatch(logoutUser())
    };

    fetchRefreshUserToken(access_token, refresh_token).then(gotData).then(asyncDoneCallback).catch(error);
  };
};

export const receiveUserToken = (userToken) => ({
  type: RECEIVE_USER_TOKEN,
  userToken,
});

export const resetUserToken = () => ({
  type: RESET_USER_TOKEN,
});


export const logoutUser = () => ({
  type: LOGOUT_USER,
});