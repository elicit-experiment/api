import _ from 'lodash'
import update from 'react-addons-update'

//Import Tokens Constants
import {
  RECEIVE_CLIENT_TOKEN,
  RECEIVE_USER_TOKEN,
  RESET_USER_TOKEN,
  REFRESH_USER_TOKEN
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
      sessionStorage.setItem("clientToken", JSON.stringify(action.clientToken, 2));
      console.dir(JSON.stringify(state, 2))
      newState = _.cloneDeep(state)
      newState.clientToken = action.clientToken;
      console.dir(JSON.stringify(newState, 2))
      return newState;
    case RECEIVE_USER_TOKEN:
      //Set userToken to sessionStorage to maintain token in event of page refresh
      sessionStorage.setItem("userToken", JSON.stringify(action.userToken, 2));
      newState = _.cloneDeep(state)
      newState.userToken = action.userToken
      return update(state, {
        'userToken': {
          $set: action.userToken
        }
      });
    case RESET_USER_TOKEN:
      sessionStorage.removeItem("userToken");
      newState = _.cloneDeep(state)
      newState.userToken = {
        access_token: undefined
      };
      return newState;
    default:
      return state;
  }
};

export default TokensReducer;