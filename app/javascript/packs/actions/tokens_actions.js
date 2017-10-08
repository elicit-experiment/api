import {
  fetchClientToken,
  fetchUserToken,
  fetchRefreshUserToken
} from '../api/api.js'

export const REQUEST_CLIENT_TOKEN = "REQUEST_CLIENT_TOKEN";
export const RECEIVE_CLIENT_TOKEN = "RECEIVE_CLIENT_TOKEN";
export const LOGIN_USER = "USER_CREATE_SUCCESS";
export const RECEIVE_USER_TOKEN = "RECEIVE_USER_TOKEN";
export const RESET_USER_TOKEN = "RESET_USER_TOKEN";
export const LOGOUT_USER = "LOGOUT_USER";


export const requestClientToken = (asyncDoneCallback) => {
  return (dispatch) => {
    //dispatch(itemsIsLoading(true));

    const processSuccess = (data) => {
      dispatch(receiveClientToken(data))
    }

    const error = (e) => {
      console.log("error in tokens middleware:", e)
    }

    fetchClientToken().then(processSuccess).then(asyncDoneCallback).catch(error);
  };
}

export const receiveClientToken = (clientToken) => ({
  type: RECEIVE_CLIENT_TOKEN,
  clientToken
});

export const logInUser = (credentials) => {
  return (dispatch) => {
    //dispatch(itemsIsLoading(true));

    const gotData = (data) => {
      dispatch(receiveUserToken(data))
    }

    const error = (e) => {
      console.log("error in tokens middleware:", e)
    }

    fetchUserToken(credentials).then(gotData).catch(error);
  };
}

export const refreshUserToken = (access_token, refresh_token, asyncDoneCallback) => {
  return (dispatch) => {
    //dispatch(itemsIsLoading(true));

    const gotData = (data) => {
      dispatch(receiveUserToken(data))
    }

    const error = (e) => {
      // TODO : maybe we retry?
      console.log(`Failed to refresh user token; treating as logout. Error ${e}`)
      dispatch(logoutUser())
    }

    fetchRefreshUserToken(access_token, refresh_token).then(gotData).then(asyncDoneCallback).catch(error);
  };
}

export const receiveUserToken = (userToken) => ({
  type: RECEIVE_USER_TOKEN,
  userToken
});

export const resetUserToken = () => ({
  type: RESET_USER_TOKEN
});


export const logoutUser = () => ({
  type: LOGOUT_USER
});