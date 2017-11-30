import React from 'react'
import ReactDOM from 'react-dom'
import { Switch, Route, BrowserRouter, Redirect } from 'react-router-dom'
import { Link } from 'react-router-dom'
import StudyManagement from './StudyManagement'
import UserManagement from './UserManagement'
import EditStudy from './EditStudy'
import {withRouter} from 'react-router'
import pathToRegexp from 'path-to-regexp'
import { Provider, connect } from "react-redux";
import elicitApi from "../../api/elicit-api.js"; 
import HeaderContainer from "../nav/HeaderContainer"
import { tokenStatus } from '../../reducers/selector';

import ProtocolPreviewContainer from "./ProtocolPreviewContainer"

const AppRoutes = {
  edit_study: {
    route: '/admin/studies/:study_id',
    //toPath: pathToRegexp.compile('/admin/studies/:study_id')
  }
}

class AdminApp extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
      if (this.props.tokenStatus !== 'user') {
        return <Redirect to='/login'></Redirect>
      }

      if (!this.props.current_user.sync) {
        if (!this.props.current_user.loading) {
          this.props.loadCurrentUser()
        }
        return <div>Loading...</div>
      }

      if (this.props.current_user.data.role !== 'admin') {
        console.log('user is not an admin')
        console.log(this.props.current_user)
        return <Redirect to='/participant'></Redirect>
      }

      console.log(`${this.props.match.url}/studies/:study_id/protocols/:protocol_id`)
      return(
    <div>
      <HeaderContainer></HeaderContainer>
      <div id="wrap" className="admin-app-container container">
        <Route path={`${this.props.match.url}/studies/:study_id/protocols/:protocol_id`} component={ProtocolPreviewContainer}/>
        <Route exact path={`${this.props.match.url}`} component={StudyManagement}/>
      </div>
      <footer id="footer" className="navbar navbar-fixed-bottom admin-footer">
        <div className="container">
          <p className="text-muted credit">DTU</p>
        </div>
      </footer>
    </div>
  )
  }

  componentDidMount() {
    console.log("AdminApp MOUNT")
  }
}

const mapStateToProps = (state) => ({
  current_user: state.current_user,
  userToken: state.tokens.userToken,
  tokenStatus: tokenStatus(state),
});

const mapDispatchToProps = (dispatch) => ({
  loadStudies: () => dispatch(elicitApi.actions.studies()),
  loadCurrentUser: () => dispatch(elicitApi.actions.current_user())
});

const connectedAdminApp = connect( mapStateToProps, mapDispatchToProps )(AdminApp)

export { connectedAdminApp as AdminApp, AppRoutes };
