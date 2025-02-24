import React from 'react';
import ParticipantProtocolList from '../components/participant_app/components/ParticipantProtocolList'
import HeaderContainer from "../components/nav/HeaderContainer";
import FooterContainer from "../components/nav/FooterContainer";
import ensureCurrentUser from "./ensureCurrentUser";
import { useCurrentUser } from '../contexts/CurrentUserContext';

const ParticipantAppContent = () => {
  const currentUser = useCurrentUser();

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

export const ParticipantApp = () => (
  ensureCurrentUser(() => <ParticipantAppContent />)()
);
