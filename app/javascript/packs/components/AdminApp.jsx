import React from 'react'
import ReactDOM from 'react-dom'
import { Switch, Route, BrowserRouter } from 'react-router-dom'
import { Link } from 'react-router-dom'
import StudyManagement from './StudyManagement'
import UserManagement from './UserManagement'
import EditStudy from './EditStudy'
import {withRouter} from 'react-router'
import pathToRegexp from 'path-to-regexp'
import { Provider, connect } from "react-redux";
import elicitApi from "../api/elicit-api.js"; 

import {
  resetUserToken
} from "../actions/tokens_actions"

class Header extends React.Component {
  render() {
    console.dir(this.props.current_user)
    let username = (this.props.current_user.data.email) ? this.props.current_user.data.email : "none"
    return (
  <nav className="nav navbar navbar-default navbar-fixed-top">
      <div className="navbar-header">
        <button type="button" className="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
          <span className="icon-bar"></span>
          <span className="icon-bar"></span>
          <span className="icon-bar"></span>
        </button>
        <a className="navbar-brand" href="#">CogSci</a>
      </div>
      <div className="collapse navbar-collapse">
        <ul id="admin-nav" className="nav navbar-nav">
          <li><Link to='/'>Home</Link></li>
          <li><Link to='/admin'>Admin</Link></li>
          <li><Link to='/admin/studies'>Study Management</Link></li>
          <li><Link to='/admin/users'>User Management</Link></li>
        </ul>

        <ul className="nav navbar-nav navbar-right">
          <li><a onClick={ (e) => { this.props.dispatch(resetUserToken()) } }>{username}</a></li>
          <li><a onClick={ (e) => { this.props.dispatch(resetUserToken()) } }>Logout</a></li>
          <li>&nbsp;</li>
        </ul>
      </div>
  </nav>
)
  }
}


const AppRoutes = {
  edit_study: {
    route: '/admin/studies/:study_id',
    //toPath: pathToRegexp.compile('/admin/studies/:study_id')
  }
}

const Foo = () => (
  <h1>h1</h1>
)

class AdminApp extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
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

    dispatch(elicitApi.actions.studies());
    dispatch(elicitApi.actions.current_user());
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
