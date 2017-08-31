// Import Client Actions and Constants
import {
  REQUEST_CLIENT_TOKEN,
  CREATE_USER,
  LOGIN_USER,
  createUser,
  logInUser,
  receiveClientToken,
  receiveUserToken
} from '../actions/tokens_actions';

/*
import {
  requestCurrentUser
} from '../actions/users_actions';
*/

// Import API Utils
import {
  fetchClientToken,
  fetchUserToken,
  submitUserCreation
} from '../api/api';

// Define and export Middeware
export default ({
  geState,
  dispatch
}) => next => action => {
  const requestClientTokenSuccess = (data) => {
    dispatch(receiveClientToken(data));
  }
  const logInSuccess = (data) => {
    dispatch(receiveUserToken(data));
  };
  const error = (e) => console.log("error in tokens middleware:", e);

  switch (action.type) {
    case REQUEST_CLIENT_TOKEN:
      fetchClientToken().then(requestClientTokenSuccess).then(action.asyncDoneCallback).catch(error);
      break;
    case LOGIN_USER:
      fetchClientToken(action.data).then(logInSuccess).catch(error);
      break;
    default:
      return next(action);
  }
};