import React from 'react';
import PropTypes from 'prop-types';
import { MatchType, UserTokenType, CurrentUserType } from 'types';
import {Redirect, Route} from 'react-router-dom';
import StudyManagement from './StudyManagement';
import {connect} from "react-redux";
import elicitApi from "../../api/elicit-api.js";
import HeaderContainer from "../nav/HeaderContainer.jsx";
import FooterContainer from "../nav/FooterContainer.jsx";
import {tokenStatus} from '../../reducers/selector';

import ProtocolPreviewContainer from "./ProtocolPreviewContainer"

class AdminApp extends React.Component {
	constructor(props) {
		console.log(JSON.stringify(props, null, 2));
		super(props);
	}

	render() {
		if (this.props.tokenStatus !== 'user') {
			return <Redirect to='/login'></Redirect>
		}

		if (!this.props.current_user.sync) {
      if (!this.props.current_user.loading) {
        if (!this.props.current_user.error) {
          console.log(`reloading current user`);
          window.setTimeout(this.props.loadCurrentUser, 50);
        } else {
          console.log(`No current user: ${JSON.stringify(this.props.current_user.error)}`);
          // TODO: all 400 errors?
          if (this.props.current_user.error.status === 401) {
            return <Redirect to='/logout'></Redirect>
					}
				}
			}
			return <div>Loading...</div>
		}

		if (this.props.current_user.data.role !== 'admin') {
			console.log('user is not an admin');
			console.log(this.props.current_user);
			return <Redirect to='/participant'></Redirect>
		}

		return (
      <div className="page-wrapper d-flex flex-column">
        <HeaderContainer></HeaderContainer>
        <main id="wrap" className="admin-app-container app-container container flex-fill">
          <Route path={`${this.props.match.url}/studies/:study_id/protocols/:protocol_id`}
                 component={ProtocolPreviewContainer}/>
          <Route exact path={`${this.props.match.url}`} component={StudyManagement}/>
        </main>
        <FooterContainer></FooterContainer>
      </div>
		)
	}
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
