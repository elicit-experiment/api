import _ from 'lodash'

//Import Dependencies
import {
  combineReducers
} from 'redux';

import elicitApi from "../api/elicit-api";

//Import Individual Reducers
import TokensReducer from './tokens_reducer';

const reducers = _.extend({
  tokens: TokensReducer,
}, elicitApi.reducers)

//Combine Reducers
const RootReducer = combineReducers(reducers);

export default RootReducer;