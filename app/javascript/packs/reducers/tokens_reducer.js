import _ from 'lodash'
import update from 'react-addons-update'

//Import Tokens Constants
import {
  RECEIVE_CLIENT_TOKEN,
  RECEIVE_USER_TOKEN,
  RESET_USER_TOKEN,
  REFRESH_USER_TOKEN,
  CLIENT_TOKEN_IS_LOADING,
  USER_TOKEN_STATE
} from '../actions/tokens_actions';

//Define Tokens' Reducer & State
const TokensReducer = (state = {
  clientToken: undefined,
  userToken: undefined,
  currentUser: undefined,
  clientTokenIsLoading: false,
  userTokenState: {
    loading: false,
    error: false,
    error_code: 0,
    error_message: false
  }
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
      return undefined;
    case CLIENT_TOKEN_IS_LOADING:
      return update(state, {
        'clientTokenIsLoading': {
          $set: action.clientTokenIsLoading
        }
      });
    case USER_TOKEN_STATE:
      return update(state, {
        'userTokenState': {
          $set: action.userTokenState
        }
      });
    default:
      return state;
  }
};

export default TokensReducer;