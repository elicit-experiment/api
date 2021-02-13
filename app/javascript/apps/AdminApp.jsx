import React from 'react';
import PropTypes from 'prop-types';
import {CurrentUserType, MatchType, UserTokenType} from 'types';
import {Redirect, Route, Switch} from 'react-router-dom';
import StudyManagement from '../components/admin_app/pages/StudyManagement';
import {connect} from "react-redux";
import elicitApi from "../api/elicit-api.js";
import HeaderContainer from "../components/nav/HeaderContainer.jsx";
import FooterContainer from "../components/nav/FooterContainer.jsx";
import {tokenStatus} from '../reducers/selector';

import ProtocolPreviewContainer from "../components/admin_app/pages/ProtocolPreviewContainer"
import UserManagement from "../components/admin_app/pages/UserManagement";
import EditStudyContainer from "../components/admin_app/pages/EditStudyContainer";

import { NavTab } from "react-router-tabs";
import "react-router-tabs/styles/react-router-tabs.css";

function AdminApp(props) {
  if (props.tokenStatus !== 'user') {
    return <Redirect to='/login'></Redirect>
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
          return <Redirect to='/logout'></Redirect>
        }
      }
    }
    return <div>Loading...</div>
  }

  if ((props.current_user.data.role !== 'admin') && (props.current_user.data.role !== 'investigator')) {
    console.log('user is not an admin');
    console.log(props.current_user);
    return <Redirect to='/participant'></Redirect>
  }

  return (
    <div className="page-wrapper d-flex flex-column">
      <HeaderContainer></HeaderContainer>
      <main id="wrap" className="admin-app-container app-container container flex-fill">
        <div>
          <NavTab allowClickOnActive={true} to="/admin/studies">Studies</NavTab>
          <NavTab to="/admin/users">Users</NavTab>

          <Switch>
            <Route
              exact
              path={`${props.match.path}`}
              render={() => <Redirect replace to={`${props.match.path}/studies`} />}
            />
            <Route exact path={`${props.match.path}/studies`} component={StudyManagement} />
            <Route path={`${props.match.path}/users`} component={UserManagement} />
            <Route path={`${props.match.url}/studies/:study_id/protocols/:protocol_id`}
                   component={ProtocolPreviewContainer}/>
            <Route path={`${props.match.url}/studies/:study_id/edit`}
                   component={EditStudyContainer}/>
          </Switch>
        </div>
      </main>
      <FooterContainer></FooterContainer>
    </div>
  )
}

AdminApp.propTypes = {
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

const connectedAdminApp = connect(mapStateToProps, mapDispatchToProps)(AdminApp);

export {connectedAdminApp as AdminApp};
