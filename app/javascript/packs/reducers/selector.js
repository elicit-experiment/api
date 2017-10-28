export const clientToken = (state) => {
  console.dir(`clientToken ${state}`)
  const ct = state ? state.tokens.clientToken : undefined;
  return ct
};

export const userToken = (state) => {
  console.dir(state.tokens.userToken)
  const ct = state ? state.tokens.userToken : undefined;
  return ct
};

export const userTokenState = (state) => {
  if (!state.tokens) return undefined;
  console.dir(state.tokens.userTokenState)
  const ct = state ? state.tokens.userTokenState : undefined;
  return ct
};

export const currentUser = (state) => {
  console.dir(state.current_user)
  return state ? state.current_user : undefined;
};