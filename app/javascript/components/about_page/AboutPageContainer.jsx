import React from 'react'
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import AboutPage from "./AboutPage"
import ensureCurrentUser from "../../apps/ensureCurrentUser";

const AboutPageContainer = () => ensureCurrentUser((currentUser) => (
  <div className="page-wrapper d-flex flex-column">
    <HeaderContainer current_user={currentUser}></HeaderContainer>
    <main id="wrap" className="app-container container flex-fill">
      <AboutPage/>
    </main>
    <FooterContainer></FooterContainer>
  </div>
));

export default AboutPageContainer;
