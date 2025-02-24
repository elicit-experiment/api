// Import Dependencies
import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';

// Import Component
import LoginSignUp from './LoginSignUp';
import Modal from "react-bootstrap/Modal";

// Import Actions
import { logInUser } from '../../actions/tokens_actions';
import { userTokenState, currentUser, tokenStatus } from '../../reducers/selector';
import elicitApi from '../../api/elicit-api.js';

import { Navigate } from 'react-router-dom'

const LoginSignUpContainer = () => {
  const dispatch = useDispatch();
  
  // Replace mapStateToProps with useSelector
  const tokenStatusState = useSelector(tokenStatus);
  const userTokenStateData = useSelector(userTokenState);
  const currentUserData = useSelector(currentUser);

  // Replace componentDidUpdate with useEffect
  useEffect(() => {
    if (tokenStatusState === 'user') {
      if (currentUserData && !currentUserData.sync && !currentUserData.loading) {
        dispatch(elicitApi.actions.current_user());
      }
    }
  }, [tokenStatusState, currentUserData, dispatch]);

  const pleaseWait = (userTokenStateData && userTokenStateData.loading) || (currentUserData && currentUserData.loading);
  const loginSignup = ((tokenStatusState !== 'user') && (!userTokenStateData || userTokenStateData.error));

  if (loginSignup && pleaseWait) {
    console.warn('invalid state');
    return <></>;
  }

  if (tokenStatusState === 'user') {
    if (currentUserData && currentUserData.sync) {
      if ((pleaseWait === false) && (loginSignup === false)) {
        console.log('Loaded current user!');
        console.dir(currentUserData);

        if (currentUserData.data.role === 'admin') {
          return <Navigate to="/admin"/>
        } else {
          return <Navigate to="/participant"/>
        }
      }
    }
  }

  // Create handlers for actions
  const handleCreateUser = (new_user_def) => {
    return dispatch(elicitApi.actions.user.post({}, {body: JSON.stringify(new_user_def)}));
  };

  const handleLogin = (data) => {
    dispatch(logInUser(data, () => {}));
  };

  return (
    <div className="single-page">
      <h1 className="elicit-bg-title">Elicit</h1>
      <h3 className="elicit-subtitle"/>
      <LoginSignUp 
        createUser={handleCreateUser}
        logInUser={handleLogin}
        showLoginSignup={loginSignup}
        dismissable={false}
        userTokenState={userTokenStateData}
      />
      <Modal show={pleaseWait}>
        <Modal.Header><h1>Logging in...</h1></Modal.Header>
        <Modal.Body>
          <div className="progress">
            <div className="progress-bar progress-bar-success progress-bar-striped" role="progressbar"
                 aria-valuenow="80" aria-valuemin="0" aria-valuemax="100" style={{width: "40%"}}>
              <span className="sr-only">80% Complete (success)</span>
            </div>
          </div>
        </Modal.Body>
      </Modal>
    </div>
  );
};

export default LoginSignUpContainer;
