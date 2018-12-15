export const clientToken = (state) => {
  const ct = state ? state.tokens.clientToken : undefined;
  return ct
};

export const userToken = (state) => {
  const ct = state ? state.tokens.userToken : undefined;
  return ct
};

export const userTokenState = (state) => {
  if (!state.tokens) return undefined;
  const ct = state ? state.tokens.userTokenState : undefined;
  return ct
};

export const currentUser = (state) => {
  return state ? state.current_user : undefined;
};

export const tokenStatus = (state) => {
  var token_status = 'none';

  if (state.tokens.clientToken && state.tokens.clientToken.access_token) {
    token_status = 'client'
  }

  if (state.tokens.userToken && state.tokens.userToken.access_token) {
    token_status = 'user'
  }

  return token_status
};