//Import React and Dependencies
import React from 'react';
import { Route, Redirect, Switch, BrowserRouter, withRouter } from 'react-router-dom';
import history from './packs/history.js'
import { connect } from 'react-redux';
import { Provider } from 'react-redux';

// Import Components
import { AdminApp } from './components/admin_app/AdminApp';
import { ParticipantApp } from './components/participant_app/ParticipantApp';
import LoginSignUpContainer from './components/login_signup/LoginSignUpContainer.jsx';
import AboutPageContainer from './components/about_page/AboutPageContainer.jsx';
import FrontPageContainer from './components/front_page/FrontPageContainer.jsx';
import ProfilePageContainer from './components/profile_page/ProfilePageContainer.jsx';

// Import Actions
import { requestClientToken } from './actions/tokens_actions';

// Import Selectors
import { clientToken, userToken } from './reducers/selector';

import { logoutUser } from "./actions/tokens_actions";

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
    console.log("no user token")
  } else {
    token_status = 'user'
  }
  return token_status
};

//Define Root Component and Router
const RawRootRoutes = (props) => {
  let token_status = tokenStatus(props.clientToken, props.userToken, props.requestClientToken);

  console.dir(`ROOT RERENDERING ${token_status}`);
  if (token_status) {
    return (
      <Switch>
        <Route exact path="/" component={FrontPageContainer}/>
        <Route path="/admin" component={AdminApp}/>
        <Route exact path="/participant" component={ParticipantApp}/>
        <Route exact path="/login" component={LoginSignUpContainer}/>
        <Route exact path="/about" component={AboutPageContainer}/>
        <Route exact path="/profile" component={ProfilePageContainer}/>
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
});

const mapDispatchToProps = (dispatch) => ({
  requestClientToken: () => dispatch(requestClientToken( () => { } )),
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

export default Root
