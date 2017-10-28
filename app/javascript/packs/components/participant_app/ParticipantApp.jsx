import React from 'react'
import ReactDOM from 'react-dom'
import { Switch, Route, BrowserRouter, Redirect } from 'react-router-dom'
import { Link } from 'react-router-dom'
import ParticipantProtocolList from './ParticipantProtocolList'
import { withRouter } from 'react-router'
import pathToRegexp from 'path-to-regexp'
import { Provider, connect } from "react-redux";
import elicitApi from "../../api/elicit-api.js"; 
import Header from "../nav/Header"

import {
  logoutUser
} from "../../actions/tokens_actions"



const AppRoutes = {
  take_study: {
    route: '/participant/studies/:study_id',
    //toPath: pathToRegexp.compile('/admin/studies/:study_id')
  }
}


class ParticipantApp extends React.Component {
  constructor(props){
    console.log("ParticipantApp CONSTRUCT")
    super(props);
  }

  render() {
      if (this.props.token_status != 'user') {
        return <Redirect to='/login'></Redirect>
      }

      return(
    <div>
      <Header {...this.props} ></Header>
      <div id="wrap" className="admin-app-container container">
        <Switch>
          <Route exact path='/' name="participant_overview" render={routeProps => <ParticipantProtocolList {...routeProps} {...this.props} /> } />
          <Route exact path='/participant' name="participant_overview" render={routeProps => <ParticipantProtocolList {...routeProps} {...this.props} /> } />
          <Route path='/participant/studies/:study_id' name="protocol_detail" render={routeProps => <TakeStudy {...routeProps} {...this.props}  /> } />
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

    // don't dispatch these simultaneously; there will be problems if we try and refresh the token
    dispatch(elicitApi.actions.eligeable_protocols()).then(() => {dispatch(elicitApi.actions.current_user())} );
  }
}

const mapStateToProps = (state) => ({
  current_user: state.current_user,
  eligeable_protocols: state.eligeable_protocols,
  userToken: state.tokens.userToken
});
const connectedParticipantApp = connect(mapStateToProps)(ParticipantApp)

export { Header as Header, connectedParticipantApp as ParticipantApp, AppRoutes };
