import React from 'react';
import { CurrentUserProvider } from '../contexts/CurrentUserContext';

export default function ensureCurrentUser(callback) {
  return function WrappedComponent(props) {
    return (
      <CurrentUserProvider>
        {callback(props)}
      </CurrentUserProvider>
    );
  };
}
