export const clientToken = (state) => {
  console.dir(`clientToken ${state}`)
  const ct = state ? state.tokens.clientToken : undefined;
  console.dir(ct)
  return ct
};

export const userToken = (state) => {
  console.dir(`userToken ${state}`)
  const ct = state ? state.tokens.clientToken : undefined;
  console.dir(ct)
  return ct
};

export const currentUser = (state) => {
  return state ? state.users.currentUser : undefined;
};