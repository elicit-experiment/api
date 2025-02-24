import React, { createContext, useContext, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Navigate } from 'react-router-dom';
import elicitApi from '../api/elicit-api';
import { tokenStatus } from '../reducers/selector';

const CurrentUserContext = createContext(null);

export function CurrentUserProvider({ children }) {
  const currentUser = useSelector(state => state.current_user);
  const dispatch = useDispatch();
  const currentTokenStatus = useSelector(state => tokenStatus(state));

  useEffect(() => {
    if (currentTokenStatus !== 'user') return;
    if (!currentUser) return;
    if (currentUser.sync) return;
    if (!currentUser?.loading) {
      dispatch(elicitApi.actions.current_user());
    }
  }, [currentTokenStatus, currentUser, dispatch]);

  if (currentTokenStatus === 'user') {
    if (currentUser?.error) {
      console.log(`No current user: ${JSON.stringify(currentUser.error)}`);
      if (currentUser.error.status === 401) {
        return <Navigate to='/logout' />;
      }
    }

    if (!currentUser?.sync) {
      return <div>Loading...</div>;
    }
  }

  console.log(`Current user: ${JSON.stringify(currentUser)}`);
  return (
    <CurrentUserContext.Provider value={currentUser}>
      {children}
    </CurrentUserContext.Provider>
  );
}

export function useCurrentUser() {
  const context = useContext(CurrentUserContext);
  if (context === undefined) {
    throw new Error('useCurrentUser must be used within a CurrentUserProvider');
  }
  return context;
}
