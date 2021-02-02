import {logoutUser, refreshUserToken, resetUserToken} from "../../actions/tokens_actions";
import {store} from "../../store/store";

import { apiRoot, defaultHeaders } from "./config";

export const refreshTokenIfExpired = ({
                                 actions,
                                 dispatch,
                                 getState,
                               }, cb) => {
  const {
    tokens: {
      userToken: userToken,
      userTokenIsLoading: userTokenIsLoading,
    },
  } = getState();

  if (userToken && userToken.created_at && userToken.expires_in) {
    let expire_time = userToken.created_at + userToken.expires_in;
    console.dir(`userToken: ${JSON.stringify(userToken)}`);
    let time_to_live = expire_time * 1000 - (new Date()).getTime();
    console.log(`userToken time to live ${time_to_live} expires at ${((new Date(expire_time * 1000))).toString()}`);
    if (time_to_live < 0) {
      console.warn(`EXPIRED TOKEN! ${userTokenIsLoading ? 'load in progress' : 'load not in progress'}`);
      if (userTokenIsLoading) {
        console.log('Token load in progress, retrying in 3s');
        setTimeout(() => {
          refreshTokenIfExpired({
            actions: actions,
            dispatch: dispatch,
            getState: getState,
          }, cb)
        }, 3000);
        return;
      }
      dispatch(refreshUserToken(userToken.access_token, userToken.refresh_token, cb));
      return;
    }
    return cb()
  }
  console.warn('refreshTokenIfExpired: no token, not making call');
  // no token? don't make the call.
};


export const authErrorResponseHandler = (err, data) => {
  // console.log(`RESPONSE; err: ${JSON.stringify(err)} data: ${JSON.stringify(data)}`);

  if (err) {
    if (err.error === 'invalid_token') {
      store.dispatch(resetUserToken());
      return data;
    }

    if (err.status === 401) { // if we get a permission denied, then just logout
      store.dispatch(logoutUser());
      // this is necessary because just returning the (undefined) data
      // will still cause the postfetch hook to run.
      throw err;
    }
  }

  return data;
}

export const apiOptions = (_url, _params, getState) => {
  const {
    tokens: {
      clientToken,
      userToken,
    },
  } = getState();
  // Add token to header request
  if (userToken && userToken.access_token) {
    return {
      headers: {
        ...defaultHeaders,
        Authorization: `Bearer ${userToken.access_token}`,
      },
    }
  }
  if (clientToken && clientToken.access_token) {
    return {
      headers: {
        ...defaultHeaders,
        Authorization: `Bearer ${clientToken.access_token}`,
      },
    };
  }
  return defaultHeaders;
}
