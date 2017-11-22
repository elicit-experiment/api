import React from 'react'
import ReactDOM from 'react-dom'
import {Switch, Route, BrowserRouter} from 'react-router-dom'
import {Link} from 'react-router-dom'
import {withRouter} from 'react-router'
import pathToRegexp from 'path-to-regexp'
import {Provider, connect} from "react-redux";
import elicitApi from "../../api/elicit-api.js";

import PropTypes from 'prop-types';

class Header extends React.Component {
  render() {
    console.dir(this.props)
    var admin = ""
    if (this.current_user_role == 'admin') {
      admin = <li><Link to='/admin'>Admin</Link></li>
    }

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
              <li><a onClick={(e) => {
                this.props.logoutUser()
              }}>{this.props.current_user_email}</a></li>
              <li><a onClick={(e) => {
                this.props.logoutUser()
              }}>Logout</a></li>
              <li>&nbsp;</li>
            </ul>
          </div>
        </nav>
    )
  }
}

Header.propTypes = {
  current_user_role: React.PropTypes.string.isRequired,
  current_user_email: React.PropTypes.string.isRequired,
  logoutUser: React.PropTypes.func.isRequired
};

Header.defaultProps = {
  current_user_role: 'none',
  current_user_email: 'none',
  logoutUser: () => {
  }
};

export default Header