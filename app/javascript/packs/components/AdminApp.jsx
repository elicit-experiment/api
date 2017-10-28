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
import elicitApi from "../api/elicit-api.js"; 
import Header from "./nav/Header"

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
      if (this.props.token_status != 'user') {
        return <Redirect to='/login'></Redirect>
      }

      if (this.props.current_user.data.role != 'admin') {
        console.log('user is not an admin')
        return <Redirect to='/participant'></Redirect>
      }

      return(
    <div>
      <Header {...this.props} ></Header>
      <div id="wrap" className="admin-app-container container">
        <Switch>
          <Route exact path='/admin/studies' render={routeProps => <StudyManagement {...routeProps} studies={this.props.studies} /> } />
          <Route exact path='/admin' render={routeProps => <StudyManagement {...routeProps} {...this.props} /> } />
          <Route path='/admin/studies/:study_id' render={routeProps => <EditStudy {...routeProps} users={this.state.users} studies={this.state.studies} protocols={this.state.protocols} study_protocols={this.state.study_protocols} /> } />
          <Route path='/admin/users' component={UserManagement}/>
        </Switch>
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
    const {dispatch} = this.props;

    // don't dispatch these simultaneously; there will be problems if we try and refresh the token
    dispatch(elicitApi.actions.studies()).then(() => {dispatch(elicitApi.actions.current_user())} );
  }

  handleChangedEvent = (event) => {
    let s = {
      studies: StudyStore.getList().list, 
      users: UserStore.getList().list,
      protocols: ProtocolStore.getList().list,
      study_protocols: StudyProtocolStore.getList().list,
    }
    console.dir(s)
    this.setState(s)
  }
}

const mapStateToProps = (state) => ({
  studies: state.studies,
  current_user: state.current_user,
  study_definition: state.study_definition,
  userToken: state.tokens.userToken
});
const connectedAdminApp = connect(mapStateToProps)(AdminApp)

export { Header as Header, connectedAdminApp as AdminApp, AppRoutes };
