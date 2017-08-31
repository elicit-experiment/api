export const REQUEST_CLIENT_TOKEN = "REQUEST_CLIENT_TOKEN";
export const RECEIVE_CLIENT_TOKEN = "RECEIVE_CLIENT_TOKEN";
export const LOGIN_USER = "USER_CREATE_SUCCESS";
export const RECEIVE_USER_TOKEN = "RECEIVE_USER_TOKEN";
export const RESET_USER_TOKEN = "RESET_USER_TOKEN";

export const requestClientToken = (asyncDoneCallback) => ({
  type: REQUEST_CLIENT_TOKEN,
  asyncDoneCallback
});

export const receiveClientToken = (clientToken) => ({
  type: RECEIVE_CLIENT_TOKEN,
  clientToken
});

export const logInUser = (data) => ({
  type: LOGIN_USER,
  data
});

export const receiveUserToken = (userToken) => ({
  type: RECEIVE_USER_TOKEN,
  userToken
});

export const resetUserToken = () => ({
  type: RESET_USER_TOKEN
});