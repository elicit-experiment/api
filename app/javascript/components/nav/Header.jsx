import React from 'react'
import PropTypes from 'prop-types';
import { Navbar, Nav, NavDropdown } from "react-bootstrap";

class Header extends React.Component {
  render() {
    let admin = <div></div>;

    if ((this.props.current_user_role == 'admin') || ((this.props.current_user_role == 'investigator'))) {
      admin = <Nav.Link href='/admin'>Admin</Nav.Link>
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
    )
  }
}

Header.propTypes = {
  current_user_email: PropTypes.string,
  current_user_role: PropTypes.string,
  current_username: PropTypes.string,
  logoutUser: PropTypes.func.isRequired,
}

Header.defaultProps = {
  current_user_role: undefined,
  current_user_email: undefined,
  logoutUser: () => {
  },
};

export default Header;
