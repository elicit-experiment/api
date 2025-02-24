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
import ensureCurrentUser from "./ensureCurrentUser";

const NavBarLink = (props) => {
  let resolved = useResolvedPath(props.to);
  let match = useMatch({ path: resolved.pathname, end: true });

  return (
    <li className={`nav-tab nav-item ${match ? 'active' : ''}`}>
      <NavLink to={props.to} className="nav-link">{props.title}</NavLink>
    </li>
  )
}

const AdminApp = () => {
  console.log('AdminApp')

  return ensureCurrentUser((currentUser) => {
    if ((currentUser.data.role !== 'admin') && (currentUser.data.role !== 'investigator')) {
      console.error('user is not an admin');
      console.error(currentUser);
      return <Navigate to='/participant'></Navigate>
    }

    return (
      <div className="page-wrapper d-flex flex-column">
        <HeaderContainer current_user={currentUser}></HeaderContainer>
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
  });
}
export default AdminApp;
