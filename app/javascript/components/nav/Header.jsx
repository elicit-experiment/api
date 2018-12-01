import React from 'react'
import {Link} from 'react-router-dom'
import PropTypes from 'prop-types';

class Header extends React.Component {
  render() {
    var admin = "";

    if (this.props.current_user_role == 'admin') {
      admin = <li><Link to='/admin'>Admin</Link></li>
    }

    var loginLogout = "";
    var userName = "";

    if (this.props.current_user_role === undefined) {
      loginLogout = <li><a href="/login">Login</a></li>
      userName = <li><a href="/login">none</a></li>
    } else {
      userName = <li><a href="/profile">{this.props.current_username || this.props.current_user_email}</a></li>

      loginLogout = <li>
        <button type="button" className="btn btn-link" onClick={(e) => {
          this.props.logoutUser()
        }}>Logout
        </button>
      </li>
    }

    return (
        <nav className="nav navbar navbar-default navbar-fixed-top">
          <div className="navbar-header">
            <button type="button" className="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
              <span className="icon-bar"></span>
              <span className="icon-bar"></span>
              <span className="icon-bar"></span>
            </button>
            <a className="navbar-brand" href="/">Elicit</a>
          </div>
          <div className="collapse navbar-collapse">
            <ul id="admin-nav" className="nav navbar-nav">
              {admin}
              <li><Link to='/participant'>Participant</Link></li>
              <li><Link to='/about'>About</Link></li>
            </ul>

            <ul className="nav navbar-nav navbar-right">
              {userName}
              {loginLogout}
              <li>&nbsp;</li>
            </ul>
          </div>
        </nav>
    )
  }
}

Header.propTypes = {
  current_user_role: PropTypes.string,
  current_user_email:PropTypes.string,
  logoutUser: PropTypes.func.isRequired
};

Header.defaultProps = {
  current_user_role: undefined,
  current_user_email: undefined,
  logoutUser: () => {
  }
};

export default Header
