//Import React and Dependencies
import React from 'react';
import { Redirect } from 'react-router-dom'
import ParticipantProtocolList from './ParticipantProtocolList'
import { connect } from "react-redux";

// Import Containers
import HeaderContainer from "../nav/HeaderContainer";
import FooterContainer from "../nav/FooterContainer";

// Import Selectors
import { tokenStatus } from '../../reducers/selector';

// Import API
import elicitApi from "../../api/elicit-api.js";

class ParticipantApp extends React.Component {
  render() {
    if (this.props.tokenStatus != 'user') {
      return <Redirect to='/login'></Redirect>
    }

    if (!this.props.current_user.sync) {
      if (!this.props.current_user.loading) {
        console.log("No current user!");
        window.setTimeout(this.props.loadCurrentUser, 50)
      }
      return <div>Loading...</div>
    }

    return(
    <div>
      <HeaderContainer></HeaderContainer>
      <div id="wrap" className="participant-app-container app-container container">
        <ParticipantProtocolList {...this.props} />
      </div>
      <FooterContainer></FooterContainer>
    </div>
  )
  }
}

const mapStateToProps = (state) => ({
  current_user: state.current_user,
  eligeable_protocols: state.eligeable_protocols,
  userToken: state.tokens.userToken,
  tokenStatus: tokenStatus(state),
});

const mapDispatchToProps = (dispatch) => ({
  loadEligeableProtocols: () => dispatch(elicitApi.actions.eligeable_protocols()),
  loadCurrentUser: () => dispatch(elicitApi.actions.current_user()),
});

const connectedParticipantApp = connect(mapStateToProps, mapDispatchToProps)(ParticipantApp);

export { connectedParticipantApp as ParticipantApp };
