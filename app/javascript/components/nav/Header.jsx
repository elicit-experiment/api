import React from 'react'
import {Link} from 'react-router-dom'
import PropTypes from 'prop-types';
import { Navbar, Nav, NavDropdown } from "react-bootstrap";

class Header extends React.Component {
  render() {
    var admin = <div></div>;

    if (this.props.current_user_role == 'admin') {
      admin = <Nav.Link href='/admin'>Admin</Nav.Link>
    }

    var loginLogout = "";
    var userName = "";

    if (this.props.current_user_role === undefined) {
      loginLogout = <Nav.Link href="/login">Login</Nav.Link>;
      userName = <li className="nav-item"></li>
    } else {
      userName = <Nav.Link href="/profile">{this.props.current_username || this.props.current_user_email}</Nav.Link>;

      loginLogout = <Nav.Link onClick={(_e) => {
          this.props.logoutUser()
        }}>Logout
        </Nav.Link>
    }

    const profile = (this.props.current_user_role === undefined) ? <Nav.Link href="/login">Login</Nav.Link> :
      <NavDropdown title={this.props.current_username || this.props.current_user_email} id="basic-nav-dropdown">
      <NavDropdown.Item href="/profile">Profile</NavDropdown.Item>
      <NavDropdown.Divider />
      <NavDropdown.Item href="#" onClick={(_e) => {
        this.props.logoutUser()
      }}>Logout</NavDropdown.Item>
    </NavDropdown>
    return (
      <Navbar bg="light" expand="lg">
        <Navbar.Brand href="/"><span className="navbar-brand">Elicit</span></Navbar.Brand>
        <Navbar.Toggle aria-controls="basic-navbar-nav" />
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="ml-auto">
            { admin }
            <Nav.Link href='/participant'>Participant</Nav.Link>
            <Nav.Link href='/about'>About</Nav.Link>
            {profile}
          </Nav>
        </Navbar.Collapse>
      </Navbar>
/*
        <nav className="nav navbar navbar-expand-lg navbar-light bg-light sticky-top">
            <a className="navbar-brand" href="/">Elicit</a>
            <button type="button" className="navbar-toggler" data-toggle="collapse" data-target="#navbarSupportedContent">
              <span className="navbar-toggler-icon"></span>
            </button>
          <div className="collapse navbar-collapse" id="navbarSupportedContent">
            <ul id="admin-nav" className="nav navbar-nav ml-auto mt-2 mt-lg-0">
              {admin}
              <li className="nav-item"><Link className="nav-link" to='/participant'>Participant</Link></li>
              <li className="nav-item"><Link className="nav-link" to='/about'>About</Link></li>
              {loginLogout}
              {userName}
            </ul>
          </div>
        </nav>

 */
    )
  }
}

Header.propTypes = {
  current_user_role: PropTypes.string,
  current_user_email:PropTypes.string,
  logoutUser: PropTypes.func.isRequired,
};

Header.defaultProps = {
  current_user_role: undefined,
  current_user_email: undefined,
  logoutUser: () => {
  },
};

export default Header
