import React from 'react';
import PropTypes from 'prop-types';
import {CurrentUserType, UserTokenType} from 'types';
import {Navigate, Route, Routes, NavLink, useResolvedPath, useMatch } from 'react-router-dom';
import StudyManagement from '../components/admin_app/pages/StudyManagement';
import {connect} from "react-redux";
import elicitApi from "../api/elicit-api.js";
import HeaderContainer from "../components/nav/HeaderContainer.jsx";
import FooterContainer from "../components/nav/FooterContainer.jsx";
import {tokenStatus} from '../reducers/selector';

import ProtocolPreviewContainer from "../components/admin_app/pages/ProtocolPreviewContainer"
import UserManagement from "../components/admin_app/pages/UserManagement";
import EditStudyContainer from "../components/admin_app/pages/EditStudyContainer";

import "../scss/react-router-tabs.scss";

const NavBarLink = (props) => {
  let resolved = useResolvedPath(props.to);
  let match = useMatch({ path: resolved.pathname, end: true });

  return (
    <li className={`nav-tab nav-item ${match ? 'active' : ''}`}>
      <NavLink to={props.to} className="nav-link">{props.title}</NavLink>
    </li>
  )
}

const AdminApp = (props) => {
  console.log('AdminApp')
  if (props.tokenStatus !== 'user') {
    return <Navigate to='/login'></Navigate>
  }

  if (!props.current_user.sync) {
    if (!props.current_user.loading) {
      if (!props.current_user.error) {
        console.log(`reloading current user`);
        window.setTimeout(props.loadCurrentUser, 50);
      } else {
        console.log(`No current user: ${JSON.stringify(props.current_user.error)}`);
        // TODO: all 400 errors?
        if (props.current_user.error.status === 401) {
          return <Navigate to='/logout'></Navigate>
        }
      }
    }
    return <div>Loading...</div>
  }

  if ((props.current_user.data.role !== 'admin') && (props.current_user.data.role !== 'investigator')) {
    console.error('user is not an admin');
    console.error(props.current_user);
    return <Navigate to='/participant'></Navigate>
  }

  return (
    <div className="page-wrapper d-flex flex-column">
      <HeaderContainer></HeaderContainer>
      <main id="wrap" className="admin-app-container app-container container flex-fill">
        <div>
          <nav className="navbar navbar-expand navbar-light">
            <div>
              <ul className="navbar-nav">
                <NavBarLink to="studies" title="Studies"></NavBarLink>
                <NavBarLink to="users" title="Users"></NavBarLink>
              </ul>
            </div>
          </nav>

          <Routes>
            <Route exact path="/" element={<Navigate to="./studies" />} />
            <Route exact path="/studies" element={<StudyManagement/>} />
            <Route path="/users" element={<UserManagement/>} />
            <Route path="/studies/:studyId/protocols/:protocolId"
                   element={<ProtocolPreviewContainer/>}/>
            <Route path="/studies/:studyId/edit"
                   element={<EditStudyContainer/>}/>
          </Routes>
        </div>
      </main>
      <FooterContainer></FooterContainer>
    </div>
  )
}

AdminApp.propTypes = {
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

const connectedAdminApp = connect(mapStateToProps, mapDispatchToProps)(AdminApp);

export default connectedAdminApp;
export {connectedAdminApp as AdminApp};
