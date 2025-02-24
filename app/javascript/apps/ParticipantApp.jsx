//Import React and Dependencies
import React from 'react';
import ParticipantProtocolList from '../components/participant_app/components/ParticipantProtocolList'

// Import Containers
import HeaderContainer from "../components/nav/HeaderContainer";
import FooterContainer from "../components/nav/FooterContainer";

import ensureCurrentUser from "./ensureCurrentUser";

export const ParticipantApp = () => (

  ensureCurrentUser((currentUser) => (
      <div className="page-wrapper d-flex flex-column">
        <HeaderContainer current_user={currentUser} />
        <main id="wrap" className="participant-app-container app-container container flex-fill">
          <ParticipantProtocolList current_user={currentUser} />
        </main>
        <FooterContainer />
      </div>
    )
  )
);
