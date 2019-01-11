import React from 'react';
import PropTypes from 'prop-types';
import { MatchType, UserTokenType, CurrentUserType } from 'types';
import {Redirect, Route} from 'react-router-dom';
import {connect} from "react-redux";
import elicitApi from "../../api/elicit-api.js";
import {tokenStatus} from '../../reducers/selector';
import HeaderContainer from "../nav/HeaderContainer.jsx";
import FooterContainer from "../nav/FooterContainer.jsx";
import AnonymousProtocolLandingPageContainer from "./AnonymousProtocolLandingPageContainer";
import FrontPageContainer from "./FrontPageContainer";

class FrontPageApp extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const landingPageUrl = `${this.props.match.url}studies/:study_id/protocols/:protocol_id`;
    console.log(landingPageUrl);
    return (
        <div>
          <HeaderContainer></HeaderContainer>
          <div id="wrap" className="home-page-app-container container">
            <Route path={landingPageUrl}
                   component={AnonymousProtocolLandingPageContainer}/>
            <Route exact path={`${this.props.match.url}`} component={FrontPageContainer}/>
          </div>
          <FooterContainer></FooterContainer>
        </div>
    )
  }
}

FrontPageApp.propTypes = {
  current_user: CurrentUserType,
  match: MatchType,
  tokenStatus: PropTypes.string.isRequired,
  userToken: UserTokenType,
  loadStudies: PropTypes.func.isRequired,
  loadCurrentUser: PropTypes.func.isRequired,
};

const mapStateToProps = (state) => ({
  current_user: state.current_user,
  userToken: state.tokens.userToken,
  tokenStatus: tokenStatus(state),
});

const mapDispatchToProps = (dispatch) => ({
  loadStudies: () => dispatch(elicitApi.actions.studies()),
  loadCurrentUser: () => dispatch(elicitApi.actions.current_user()),
});

const connectedAdminApp = connect(mapStateToProps, mapDispatchToProps)(FrontPageApp);

export {connectedAdminApp as FrontPageApp};
