import React from 'react'
import PropTypes from 'prop-types';
import {Navbar, Nav, NavDropdown, Container} from "react-bootstrap";
import {useDispatch} from "react-redux";
import elicitApi from "../../api/elicit-api";
import {logoutUser} from "../../actions/tokens_actions";

export const Header = (props) => {
  let admin = <div></div>;

  const dispatch = useDispatch();

  if ((props.current_user_role == 'admin') || ((props.current_user_role == 'investigator'))) {
    admin = <Nav.Link href='/admin'>Admin</Nav.Link>
  }

  const profile = (props.current_user_role === undefined) ? <Nav.Link href="/login">Login</Nav.Link> :
    <NavDropdown title={props.current_username || props.current_user_email} id="basic-nav-dropdown">
      <NavDropdown.Item href="/profile">Profile</NavDropdown.Item>
      <NavDropdown.Divider />
      <NavDropdown.Item href="#" onClick={(_e) => {
        dispatch(logoutUser());
      }}>Logout</NavDropdown.Item>
    </NavDropdown>
  return (
    <Navbar bg="light" expand="lg">
      <Container>
        <Navbar.Brand href="/"><span className="navbar-brand">Elicit</span></Navbar.Brand>
        <Navbar.Toggle aria-controls="basic-navbar-nav" />
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="me-auto">
            { admin }
            <Nav.Link href='/participant'>Participant</Nav.Link>
            <Nav.Link href='/about'>About</Nav.Link>
          </Nav>
          <Nav>
          { profile }
          </Nav>
        </Navbar.Collapse>
      </Container>
    </Navbar>
  )
}

Header.propTypes = {
  current_user_email: PropTypes.string,
  current_user_role: PropTypes.string,
  current_username: PropTypes.string,
}

export default Header;