import React from 'react'
import ReactDOM from 'react-dom'
import { Switch, Route, BrowserRouter } from 'react-router-dom'
import { Link } from 'react-router-dom'
import ParticipantStudyList from './ParticipantStudyList'
import TakeStudy from './TakeStudy'
import {withRouter} from 'react-router'
import pathToRegexp from 'path-to-regexp'
import { Provider, connect } from "react-redux";
import elicitApi from "../../api/elicit-api.js"; 

import {
  logoutUser
} from "../../actions/tokens_actions"

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
          <li><Link to='/Participant'>Participant</Link></li>
        </ul>

        <ul className="nav navbar-nav navbar-right">
          <li><a onClick={ (e) => { this.props.dispatch(logoutUser()) } }>{username}</a></li>
          <li><a onClick={ (e) => { this.props.dispatch(logoutUser()) } }>Logout</a></li>
          <li>&nbsp;</li>
        </ul>
      </div>
  </nav>
)
  }
}


const AppRoutes = {
  take_study: {
    route: '/participant/studies/:study_id',
    //toPath: pathToRegexp.compile('/admin/studies/:study_id')
  }
}


class ParticipantApp extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
      return(
    <div>
      <Header {...this.props} ></Header>
      <div id="wrap" className="admin-app-container container">
        <Switch>
          <Route exact path='/participant' render={routeProps => <ParticipantStudyList {...routeProps} {...this.props} /> } />
          <Route path='/participant/studies/:study_id' render={routeProps => <TakeStudy {...routeProps} {...this.props}  /> } />
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
    console.log("ParticipantApp MOUNT")
    const {dispatch} = this.props;

    dispatch(elicitApi.actions.studies());  // TODO: should be "my studies"
    dispatch(elicitApi.actions.current_user());
  }
}

const mapStateToProps = (state) => ({
  studies: state.studies,
  current_user: state.current_user,
  study_definition: state.study_definition,
  userToken: state.tokens.userToken
});
const connectedParticipantApp = connect(mapStateToProps)(ParticipantApp)

export { Header as Header, connectedParticipantApp as ParticipantApp, AppRoutes };
