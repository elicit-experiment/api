//Import React and Dependencies
import PropTypes from 'prop-types'
import React, { useEffect } from 'react';
import {Navigate} from 'react-router-dom'
import ParticipantProtocolList from '../components/participant_app/components/ParticipantProtocolList'
import { connect } from "react-redux";
import { UserType } from "../types";

// Import Containers
import HeaderContainer from "../components/nav/HeaderContainer";
import FooterContainer from "../components/nav/FooterContainer";

// Import Selectors
import { tokenStatus } from '../reducers/selector';

// Import API
import elicitApi from "../api/elicit-api.js";

const ParticipantApp = ({ tokenStatus, current_user, loadCurrentUser, ...props }) => {
  useEffect(() => {
    if (!current_user.sync && !current_user.loading) {
      console.log("No current user!");
      window.setTimeout(loadCurrentUser, 50);
    }
  }, [current_user.sync, current_user.loading, loadCurrentUser]);

  if (tokenStatus !== 'user') {
    return <Navigate to='/login' />;
  }

  if (!current_user.sync) {
    return <div>Loading...</div>;
  }

  return (
    <div className="page-wrapper d-flex flex-column">
      <HeaderContainer />
      <main id="wrap" className="participant-app-container app-container container flex-fill">
        <ParticipantProtocolList {...props} current_user={current_user} />
      </main>
      <FooterContainer />
    </div>
  );
};

const mapStateToProps = (state) => ({
  current_user: state.current_user,
  userToken: state.tokens.userToken,
  tokenStatus: tokenStatus(state),
});

const mapDispatchToProps = (dispatch) => ({
  loadCurrentUser: () => dispatch(elicitApi.actions.current_user()),
});

const connectedParticipantApp = connect(mapStateToProps, mapDispatchToProps)(ParticipantApp);

export { connectedParticipantApp as ParticipantApp };

ParticipantApp.propTypes = {
  current_user: UserType.isRequired,
  loadCurrentUser: PropTypes.func,
  tokenStatus: PropTypes.string,
};
