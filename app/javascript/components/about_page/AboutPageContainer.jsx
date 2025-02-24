import React from 'react'
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import AboutPage from "./AboutPage"
import {CurrentUserProvider, useCurrentUser} from "../../contexts/CurrentUserContext";

const AboutPageContent = () => (
  <div className="page-wrapper d-flex flex-column">
    <HeaderContainer current_user={useCurrentUser()}></HeaderContainer>
    <main id="wrap" className="app-container container flex-fill">
      <AboutPage/>
    </main>
    <FooterContainer></FooterContainer>
  </div>
)

const AboutPageContainer = () => (
  <CurrentUserProvider>
    <AboutPageContent/>
  </CurrentUserProvider>
);

export default AboutPageContainer;
