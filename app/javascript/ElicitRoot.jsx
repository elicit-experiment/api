//Import React and Dependencies
import React, {Suspense, useEffect} from 'react';
import { Route, Routes, BrowserRouter } from 'react-router-dom';
import {connect, useDispatch, useSelector} from 'react-redux';
import { Provider } from 'react-redux';
import PropTypes from "prop-types";

// Import Components
//import { AdminApp } from './apps/AdminApp';
const AdminApp = React.lazy(() => import('./apps/AdminApp'));
import { ParticipantApp } from './apps/ParticipantApp';
import LoginSignUpContainer from './components/login_signup/LoginSignUpContainer.jsx';
import AboutPageContainer from './components/about_page/AboutPageContainer.jsx';
import ContactPageContainer from './components/contact_page/ContactPageContainer.jsx';
import LicensePageContainer from './components/license_page/LicensePageContainer.jsx';
import FrontPageApp from './apps/FrontPageApp.jsx';
import ProfilePageContainer from './components/profile_page/ProfilePageContainer.jsx';

// Import Actions
import { requestClientToken } from './actions/tokens_actions';

// Import Selectors
import {clientToken, currentUser, userToken} from './reducers/selector';

import { logoutUser } from "./actions/tokens_actions";
import elicitApi from "./api/elicit-api";

import "@fortawesome/fontawesome-free/css/fontawesome.min.css";
import "@fortawesome/fontawesome-free/css/solid.min.css";

export const tokenStatus = (clientToken, userToken, requestClientToken) => {
  let token_status = 'none';

  if (!clientToken || !clientToken.access_token) {
    console.warn("no client token");
    if (typeof requestClientToken === 'function') {
      if (requestClientToken) requestClientToken()
    }
  } else {
    token_status = 'client'
  }

  if (!userToken || !userToken.access_token) {
    console.warn("no user token");
    if (userToken) {
      console.dir(userToken);
    }
  } else {
    token_status = 'user'
  }
  return token_status
};

const AdminAppWrapper = (props) => {
  return <Suspense fallback={<div>Loading...</div>}>
    <AdminApp {...props} />
  </Suspense>
}

const RequestPageContainer = () => <ContactPageContainer action="request"/>

//Define Root Component and Router
const RawRootRoutes = () => {
  //const currentUser = useSelector(state => state.currentUser);
  const clientToken = useSelector(state => state.tokens.clientToken);
  const userToken = useSelector(state => state.tokens.userToken);
  const dispatch = useDispatch();

  useEffect(() => {tokenStatus(clientToken, userToken, () => dispatch(requestClientToken( () => { } )))}, [dispatch, clientToken, userToken])

  let token_status = tokenStatus(clientToken, userToken, null);

  // if (token_status === 'user' && !currentUser?.sync && !currentUser?.loading) {
  //   props.getCurrentUser();
  // }

  console.dir(`ROOT RE-RENDERING ${token_status}`);
  if (token_status) {
    return (
      <Routes>
        <Route exact path="/login" element={<LoginSignUpContainer/>}/>
        <Route exact path="/profile" element={<ProfilePageContainer/>}/>
        <Route exact path="/participant" element={<ParticipantApp/>}/>
        <Route exact path="/about" element={<AboutPageContainer/>}/>
        <Route exact path="/contact" element={<ContactPageContainer/>}/>
        <Route exact path="/request" element={<RequestPageContainer/>}/>
        <Route exact path="/license" element={<LicensePageContainer/>}/>
        <Route path="/admin/*" element={<AdminAppWrapper/>}/>
        <Route path="/*" element={<FrontPageApp/>}/>
      </Routes>
    )

    //       <Navigate from="*" to="/"/>
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

const RootRoutes = connect(
    mapStateToProps,
    mapDispatchToProps
)(RawRootRoutes);
//const RootRoutes = RawRootRoutes;

const Root = (props) => {
  return (
<Provider store={props.store}>
    <BrowserRouter>
      <RootRoutes {...props} />
    </BrowserRouter>
</Provider>
  );
};

Root.propTypes = {
  store: PropTypes.object,
};

export default Root
