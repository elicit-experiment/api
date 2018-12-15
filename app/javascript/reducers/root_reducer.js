import _ from 'lodash';
import {
  LOGOUT_USER,
} from '../actions/tokens_actions';

//Import Dependencies
import {
  combineReducers,
} from 'redux';

import elicitApi from "../api/elicit-api";

//Import Individual Reducers
import TokensReducer from './tokens_reducer';

const reducers = _.extend({
  tokens: TokensReducer,
}, elicitApi.reducers);

//Combine Reducers
const appReducer = combineReducers(reducers);

const RootReducer = (state, action) => {
  if (action.type === LOGOUT_USER) {
    sessionStorage.removeItem("userToken");
    // save routing and clientToken, but nuke everything else
    const {
      tokens: {
        clientToken: clientToken,
      },
    } = state;
    state = {
      tokens: {
        clientToken: clientToken,
      },
    }
  }
  return appReducer(state, action)
};

export default RootReducer;