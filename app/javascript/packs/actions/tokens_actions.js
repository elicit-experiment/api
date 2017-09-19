import {
  fetchClientToken,
  fetchUserToken
} from '../api/api.js'

export const REQUEST_CLIENT_TOKEN = "REQUEST_CLIENT_TOKEN";
export const RECEIVE_CLIENT_TOKEN = "RECEIVE_CLIENT_TOKEN";
export const LOGIN_USER = "USER_CREATE_SUCCESS";
export const RECEIVE_USER_TOKEN = "RECEIVE_USER_TOKEN";
export const RESET_USER_TOKEN = "RESET_USER_TOKEN";

const error = (e) => {
  console.log("error in tokens middleware:", e)
  debugger
}

export const requestClientToken = (asyncDoneCallback) => {
  return (dispatch) => {
    //dispatch(itemsIsLoading(true));

    const gotData = (data) => {
      dispatch(receiveClientToken(data))
    }

    fetchClientToken().then(gotData).then(asyncDoneCallback).catch(error);
  };
}

export const receiveClientToken = (clientToken) => ({
  type: RECEIVE_CLIENT_TOKEN,
  clientToken
});

export const logInUser = (data) => {
  return (dispatch) => {
    //dispatch(itemsIsLoading(true));

    const gotData = (data) => {
      dispatch(receiveUserToken(data))
    }

    fetchUserToken(data).then(gotData).catch(error);
  };
}

export const refreshUserToken = (data) => {
  return (dispatch) => {
    //dispatch(itemsIsLoading(true));

    const gotData = (data) => {
      dispatch(receiveUserToken(data))
    }

    fetchUserToken(data).then(gotData).catch(error);
  };
}

export const receiveUserToken = (userToken) => ({
  type: RECEIVE_USER_TOKEN,
  userToken
});

export const resetUserToken = () => ({
  type: RESET_USER_TOKEN
});