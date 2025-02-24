//Import React and Dependencies
import React from 'react'

// Import Components
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import ProfilePage from "./ProfilePage.jsx"

import {CurrentUserProvider, useCurrentUser} from "../../contexts/CurrentUserContext";

const ProfilePageContainerContent = () => (
      <div className="page-wrapper d-flex flex-column">
        <HeaderContainer current_user={useCurrentUser()}></HeaderContainer>
        <main id="wrap" className="app-container container flex-fill">
          <ProfilePage user={useCurrentUser()}/>
        </main>
        <FooterContainer></FooterContainer>
      </div>
    );

const ProfilePageContainer = () => (
  <CurrentUserProvider>
    <ProfilePageContainerContent />
  </CurrentUserProvider>
)

export default ProfilePageContainer;