//Import Dependencies
import {
  combineReducers
} from 'redux';

//Import Individual Reducers
import TokensReducer from './tokens_reducer';

//Combine Reducers
const RootReducer = combineReducers({
  tokens: TokensReducer,
});

export default RootReducer;