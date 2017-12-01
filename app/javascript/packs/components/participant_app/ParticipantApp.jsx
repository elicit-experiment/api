import React from 'react'
import ReactDOM from 'react-dom'
import { Switch, Route, BrowserRouter, Redirect } from 'react-router-dom'
import { Link } from 'react-router-dom'
import ParticipantProtocolList from './ParticipantProtocolList'
import { withRouter } from 'react-router'
import pathToRegexp from 'path-to-regexp'
import { Provider, connect } from "react-redux";
import elicitApi from "../../api/elicit-api.js"; 
import HeaderContainer from "../nav/HeaderContainer"
import { tokenStatus } from '../../reducers/selector';

class ParticipantApp extends React.Component {
  render() {
    if (this.props.tokenStatus != 'user') {
      return <Redirect to='/login'></Redirect>
    }

    if (!this.props.current_user.sync) {
      if (!this.props.current_user.loading) {
        console.log("No current user!")
        window.setTimeout(this.props.loadCurrentUser, 50)
      }
      return <div>Loading...</div>
    }

    return(
    <div>
      <HeaderContainer></HeaderContainer>
      <div id="wrap" className="admin-app-container container">
        <ParticipantProtocolList {...this.props} />
      </div>
      <footer id="footer" className="navbar navbar-fixed-bottom admin-footer">
        <div className="container">
          <p className="text-muted credit">DTU</p>
        </div>
      </footer>
    </div>
  )
  }
}

const mapStateToProps = (state) => ({
  current_user: state.current_user,
  eligeable_protocols: state.eligeable_protocols,
  userToken: state.tokens.userToken,
  tokenStatus: tokenStatus(state),
});

const mapDispatchToProps = (dispatch) => ({
  loadEligeableProtocols: () => dispatch(elicitApi.actions.eligeable_protocols()),
  loadCurrentUser: () => dispatch(elicitApi.actions.current_user())
});

const connectedParticipantApp = connect(mapStateToProps, mapDispatchToProps)(ParticipantApp)

export { connectedParticipantApp as ParticipantApp };
