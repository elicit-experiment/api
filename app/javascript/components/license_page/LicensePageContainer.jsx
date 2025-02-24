import React from 'react'
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import LicensePage from "./LicensePage"
import {CurrentUserProvider, useCurrentUser} from "../../contexts/CurrentUserContext";

const LicensePageContainerContent = () => (
  <div>
    <HeaderContainer current_user={useCurrentUser()}></HeaderContainer>
    <LicensePage/>
    <FooterContainer></FooterContainer>
  </div>
)

const LicensePageContainer = () => (
  <CurrentUserProvider>
    <LicensePageContainerContent/>
  </CurrentUserProvider>
)

export default LicensePageContainer;
