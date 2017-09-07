//Import Dependencies
import {
  applyMiddleware
} from 'redux';
import thunk from "redux-thunk";

import elicitApi from "../api/elicit-api";

//Import Individual Middlewares
import TokensMiddleware from './tokens_middleware';

const ReduxApiThunkMiddleware = ({
  dispatch,
  getState
}) => next => action => {
  if (typeof action === 'function') {
    return action(
      dispatch,
      getState
    );
  }
  return next(action);
};

//Create Master Middleware
const masterMiddleware = applyMiddleware(
  TokensMiddleware,
  ReduxApiThunkMiddleware
);

export default masterMiddleware;