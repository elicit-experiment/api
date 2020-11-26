//Import React and Dependencies
import React from 'react';
import { Route, Redirect, Switch, BrowserRouter, withRouter } from 'react-router-dom';
import history from './packs/history.js'
import { connect } from 'react-redux';
import { Provider } from 'react-redux';
import PropTypes from "prop-types";

// Import Components
import { AdminApp } from './apps/AdminApp';
import { ParticipantApp } from './apps/ParticipantApp';
import LoginSignUpContainer from './components/login_signup/LoginSignUpContainer.jsx';
import AboutPageContainer from './components/about_page/AboutPageContainer.jsx';
import LicensePageContainer from './components/license_page/LicensePageContainer.jsx';
import { FrontPageApp } from './apps/FrontPageApp.jsx';
import ProfilePageContainer from './components/profile_page/ProfilePageContainer.jsx';

// Import Actions
import { requestClientToken } from './actions/tokens_actions';

// Import Selectors
import {clientToken, currentUser, userToken} from './reducers/selector';

import { logoutUser } from "./actions/tokens_actions";
import elicitApi from "./api/elicit-api";

import "@fortawesome/fontawesome-free/css/all.css";

export const tokenStatus = (clientToken, userToken, requestClientToken) => {
  let token_status = 'none';

  if (!clientToken || !clientToken.access_token) {
    console.log("no client token");
    if (typeof requestClientToken === 'function') {
      requestClientToken()
    }
  } else {
    token_status = 'client'
  }

  if (!userToken || !userToken.access_token) {
    console.log("no user token");
    console.dir(userToken);
  } else {
    token_status = 'user'
  }
  return token_status
};

//Define Root Component and Router
const RawRootRoutes = (props) => {
  let token_status = tokenStatus(props.clientToken, props.userToken, props.requestClientToken);

  if (token_status === 'user' && !props.currentUser.sync && !props.currentUser.loading) {
    props.getCurrentUser();
  }

  console.dir(`ROOT RERENDERING ${token_status}`);
  if (token_status) {
    return (
      <Switch>
        <Route path="/admin" component={AdminApp}/>
        <Route exact path="/participant" component={ParticipantApp}/>
        <Route exact path="/login" component={LoginSignUpContainer}/>
        <Route exact path="/about" component={AboutPageContainer}/>
        <Route exact path="/license" component={LicensePageContainer}/>
        <Route exact path="/profile" component={ProfilePageContainer}/>
        <Route path="/" component={FrontPageApp}/>
        <Redirect from="*" to="/"/>
      </Switch>
    )
  } else {
    // TODO: have a timeout here
    return <div>Loading...</div>
  }
};


const mapStateToProps = (state) => ( {
  clientToken: clientToken(state),
  userToken: userToken(state),
  currentUser: currentUser(state),
});

const mapDispatchToProps = (dispatch) => ({
  requestClientToken: () => dispatch(requestClientToken( () => { } )),
  getCurrentUser: () => { dispatch(elicitApi.actions.current_user()) },
  logoutUser: () => dispatch(logoutUser()),
});

const RootRoutes = withRouter(connect(
    mapStateToProps,
    mapDispatchToProps
)(RawRootRoutes));

const Root = (props) => {
  return (
<Provider store={props.store}>
    <BrowserRouter history={history}>
      <RootRoutes history={history} {...props} />
    </BrowserRouter>
</Provider>
  );
};

Root.propTypes = {
  store: PropTypes.object,
};

export default Root
