import React, {
  PropTypes
} from "react";
import {
  createStore,
  applyMiddleware,
  combineReducers
} from "redux";
import {
  Provider,
  connect
} from "react-redux";
import thunk from "redux-thunk";
import elicitApi from "../api/elicit-api";
import RootReducer from '../reducers/root_reducer';
import {
  logger
} from 'redux-logger'

export var store

export const configureStore = (preloadedState = {}) => {
  store = createStore(
    RootReducer,
    preloadedState,
    applyMiddleware(thunk, logger)
  )
  return store
};