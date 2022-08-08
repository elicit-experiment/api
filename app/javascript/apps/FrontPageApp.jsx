import React from 'react';
import PropTypes from 'prop-types';
import { MatchType, UserTokenType, CurrentUserType } from 'types';
import {connect} from "react-redux";
import elicitApi from "../api/elicit-api.js";
import {tokenStatus} from '../reducers/selector';
import HeaderContainer from "../components/nav/HeaderContainer.jsx";
import FooterContainer from "../components/nav/FooterContainer.jsx";
import AnonymousProtocolLandingPageContainer from "../components/front_page/AnonymousProtocolLandingPageContainer";
import FrontPageContainer from "../components/front_page/FrontPageContainer";
import ParticipatePage from "../components/front_page/ParticipatePage";
import {Route, Routes, useLocation} from "react-router-dom";

const FrontPageApp = (props) => {
  const { pathname } = useLocation();
    const landingPageUrl = `${pathname}studies/:study_id/protocols/:protocol_id`;
    const participatePageUrl = `${pathname}participate`;
    return (
        <div className="page-wrapper d-flex flex-column">
          <HeaderContainer></HeaderContainer>
          <main id="wrap" className="home-page-app-container app-container container flex-fill">
            <Routes>
              <Route element={landingPageUrl}
                     component={<AnonymousProtocolLandingPageContainer/>}/>
              <Route element={participatePageUrl}
                     component={<ParticipatePage/>}/>
              <Route exact path="/" element={<FrontPageContainer/>}/>
            </Routes>
          </main>
          <FooterContainer></FooterContainer>
        </div>
    )
}

FrontPageApp.propTypes = {
  current_user: CurrentUserType,
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

export default connect(mapStateToProps, mapDispatchToProps)(FrontPageApp);
