import {
  createStore,
  applyMiddleware,
} from "redux";
import thunk from "redux-thunk";
import RootReducer from '../reducers/root_reducer';
import {
  logger,
} from 'redux-logger'

export var store;

export const configureStore = (preloadedState = {}) => {
  store = createStore(
    RootReducer,
    preloadedState,
    applyMiddleware(thunk, logger)
  );
  return store
};
