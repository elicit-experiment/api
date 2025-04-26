import React from 'react'
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import {CurrentUserProvider, useCurrentUser} from "../../contexts/CurrentUserContext";
import {ContactForm} from './ContactForm';

const ContactPageContent = (props) => {
  const currentUser = useCurrentUser();

  return (
    <div className="page-wrapper d-flex flex-column">
      <HeaderContainer current_user={currentUser}></HeaderContainer>
      <main id="wrap" className="app-container container flex-fill">
        <div className="row justify-content-center my-5">
          <div className="col-lg-8">
            <ContactForm {...props} />
          </div>
        </div>
      </main>
      <FooterContainer></FooterContainer>
    </div>
  );
};

const ContactPageContainer = (props) => (
  <CurrentUserProvider>
    <ContactPageContent {...props} />
  </CurrentUserProvider>
);

export default ContactPageContainer;
