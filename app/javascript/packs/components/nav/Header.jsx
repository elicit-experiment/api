import React from 'react'
import ReactDOM from 'react-dom'
import { Switch, Route, BrowserRouter } from 'react-router-dom'
import { Link } from 'react-router-dom'
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
    var admin = ""
    if (this.props.current_user.data.role == 'admin') {
      admin = <li><Link to='/admin'>Admin</Link></li>
    }
    let username = (this.props.current_user.data.email) ? this.props.current_user.data.email : "none"
    return (
  <nav className="nav navbar navbar-default navbar-fixed-top">
      <div className="navbar-header">
        <button type="button" className="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
          <span className="icon-bar"></span>
          <span className="icon-bar"></span>
          <span className="icon-bar"></span>
        </button>
        <a className="navbar-brand" href="#">Elicit</a>
      </div>
      <div className="collapse navbar-collapse">
        <ul id="admin-nav" className="nav navbar-nav">
          {admin}
          <li><Link to='/participant'>Participant</Link></li>
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

export default Header