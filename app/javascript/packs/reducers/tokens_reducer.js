import _ from 'lodash'

//Import Tokens Constants
import {
  RECEIVE_CLIENT_TOKEN,
  RECEIVE_USER_TOKEN,
  RESET_USER_TOKEN
} from '../actions/tokens_actions';

//Define Tokens' Reducer & State
const TokensReducer = (state = {
  clientToken: undefined,
  userToken: undefined,
  currentUser: undefined
}, action) => {
  let newState;
  switch (action.type) {
    case RECEIVE_CLIENT_TOKEN:
      //Set clientToken to sessionStorage to maintain token in event of page refresh
      sessionStorage.setItem("clientToken", action.clientToken.access_token);
      console.dir(JSON.stringify(state, 2))
      newState = _.extend({}, state)
      newState.clientToken = action.clientToken.access_token;
      console.dir(JSON.stringify(newState, 2))
      return newState;
    case RECEIVE_USER_TOKEN:
      //Set userToken to sessionStorage to maintain token in event of page refresh
      sessionStorage.setItem("userToken", action.userToken.access_token);
      newState = _.extend({}, state);
      newState.userToken = action.userToken.access_token;
      return newState;
    case RESET_USER_TOKEN:
      sessionStorage.removeItem("userToken");
      newState = _.extend({}, state);
      newState.userToken = undefined;
      return newState;
    default:
      return state;
  }
};

export default TokensReducer;