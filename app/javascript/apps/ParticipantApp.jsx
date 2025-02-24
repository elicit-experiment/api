//Import React and Dependencies
import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {Navigate} from 'react-router-dom'
import ParticipantProtocolList from '../components/participant_app/components/ParticipantProtocolList'

// Import Containers
import HeaderContainer from "../components/nav/HeaderContainer";
import FooterContainer from "../components/nav/FooterContainer";

// Import Selectors
import { tokenStatus } from '../reducers/selector';

// Import API
import elicitApi from "../api/elicit-api.js";

export const ParticipantApp = () => {
  const currentUser = useSelector(state => state.current_user);
  const dispatch = useDispatch();

  let currentTokenStatus = useSelector(state => tokenStatus(state));

  useEffect(() => {
    if (currentTokenStatus !== 'user') { return }

    if (!currentUser) { return }

    if (!currentUser?.sync && !currentUser?.loading) {
      console.log("No current user!");
      dispatch(elicitApi.actions.current_user());
    }
  }, [currentTokenStatus, currentUser, currentUser?.sync, currentUser?.loading]);

  if (currentTokenStatus !== 'user') {
    return <Navigate to='/login' />;
  }

  if (!currentUser.sync) {
    return <div>Loading...</div>;
  }

  return (
    <div className="page-wrapper d-flex flex-column">
      <HeaderContainer current_user={currentUser} />
      <main id="wrap" className="participant-app-container app-container container flex-fill">
        <ParticipantProtocolList current_user={currentUser} />
      </main>
      <FooterContainer />
    </div>
  );
};
