//Import Dependencies
import {
  applyMiddleware
} from 'redux';

//Import Individual Middlewares
import TokensMiddleware from './tokens_middleware';

//Create Master Middleware
const masterMiddleware = applyMiddleware(
  TokensMiddleware,
);

export default masterMiddleware;