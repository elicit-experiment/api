//Import Dependencies
import PropTypes from 'prop-types'
import React, { useState } from 'react';
import Modal from "react-bootstrap/Modal";
import {UserTokenStateType} from "../../types";

const LogInSignUp = ({ createUser, dismissable = false, logInUser, userTokenState }) => {
  const [isLoginForm, setIsLoginForm] = useState(true);
  const [email, setEmail] = useState("");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [passwordConfirmation, setPasswordConfirmation] = useState("");

  // Updates state to determine whether to render the login form or sign-up form
  const toggleLogIn = (e) => {
    e.preventDefault();
    setIsLoginForm(!isLoginForm);
  };

  // Dispatches the action to make the API call for signing up a user
  const handleSignUp = (e) => {
    e.preventDefault();
    const credentials = {
      email,
      username,
      password,
      password_confirmation: passwordConfirmation,
    };
    createUser({user: credentials}).then(() => logInUser(credentials));
  };

  // Dispatches the action to make the API call for logging in a user
  const handleLogin = (e) => {
    e.preventDefault();
    const credentials = {
      email,
      password,
    };
    logInUser(credentials);
  };

  const dismissButton = () => {
    return dismissable ? <button type="button" className="close" data-dismiss="modal">&times;</button> : <div></div>
  };

  // Generates the HTML for the login form
  const renderLoginForm = () => {
    let error = <div></div>;
    if (userTokenState?.error) {
      let error_text = "";
      switch (userTokenState.error_code) {
        case 401:
          error_text = "Invalid user and/or password.";
          break;
        default:
          error_text = "An unknown error occurred.  Please try later.";
          break;
      }
      error = <div className="login-error">{error_text}</div>
    }

    return(
      <Modal show={true}>
        <Modal.Header>
          <h4><span className="fas fa-lock"></span> Login</h4>
          {error}
        </Modal.Header>
        <Modal.Body>
          <form role="form" onSubmit={handleLogin}>
            <div className="form-group">
              <label htmlFor="usrname"><span className="fas fa-user fa-envelope"></span> Username or Email</label>
              <input type="text"
                     className="form-control"
                     id="email"
                     placeholder="Enter email"
                     autoComplete="username"
                     value={email}
                     onChange={(e) => setEmail(e.target.value)}/>
            </div>
            <div className="form-group">
              <label htmlFor="psw"><span className="fas fa-eye"></span> Password</label>
              <input type="password"
                     className="form-control"
                     id="psw"
                     placeholder="Enter password"
                     autoComplete="current-password"
                     value={password}
                     onChange={(e) => setPassword(e.target.value)}/>
            </div>
            <button type="submit" className="btn btn-success btn-block"><span className="fas fa-power-off"></span> Login</button>
          </form>
        </Modal.Body>
        <Modal.Footer>
          <p>Not a member? <a href="#" onClick={toggleLogIn}>Sign Up</a></p>
          <p>Forgot <a href="#">Password?</a></p>
        </Modal.Footer>
      </Modal>
    );
  }

  // Generates the HTML for the sign up form
  const renderSignUpForm = () => {
    return(
      <Modal show={true}>
           <Modal.Header>
              <h4><span className="fas fa-lock"></span> Sign Up</h4>
            </Modal.Header>
            <Modal.Body>
              <form role="form" onSubmit={handleSignUp}>
                <div className="form-group">
                  <label htmlFor="usrname"><span className="fas fa-user"></span> User Name</label>
                  <input type="text"
                         className="form-control"
                         id="usrname"
                         placeholder="Entername"
                         autoComplete="username"
                         value={username}
                         onChange={(e) => setUsername(e.target.value)}/>
                </div>
                <div className="form-group">
                  <label htmlFor="usremail"><span className="fas fa-envelope"></span> Email</label>
                  <input type="text"
                         className="form-control"
                         id="usremail"
                         placeholder="Enter email"
                         value={email}
                         onChange={(e) => setEmail(e.target.value)}/>
                </div>
                <div className="form-group">
                  <label htmlFor="psw"><span className="fas fa-eye"></span> Password</label>
                  <input type="password"
                         className="form-control"
                         id="psw"
                         placeholder="Enter password"
                         autoComplete="new-password"
                         value={password}
                         onChange={(e) => setPassword(e.target.value)}/>
                </div>
                <div className="form-group">
                  <label htmlFor="psw"><span className="fas fa-eye"></span> Confirm Password</label>
                  <input type="password"
                         className="form-control"
                         id="pswConf"
                         placeholder="Re-enter password"
                         autoComplete="new-password"
                         value={passwordConfirmation}
                         onChange={(e) => setPasswordConfirmation(e.target.value)}/>
                </div>
                <div className="checkbox">
                  <label><input type="checkbox" value="" className="mr-2"/>Remember me</label>
                </div>
                  <button type="submit" className="btn btn-success btn-block"><span className="fas fa-power-off"></span> Sign Up</button>
              </form>
            </Modal.Body>
            <Modal.Footer>
              <p>Already a Member? <a href="#" onClick={toggleLogIn}>Log In</a></p>
              <p>Forgot <a href="#">Password?</a></p>
            </Modal.Footer>
          </Modal>
    );
  }

  return isLoginForm ? renderLoginForm() : renderSignUpForm();
};

LogInSignUp.propTypes = {
  createUser: PropTypes.func.isRequired,
  dismissable: PropTypes.bool.isRequired,
  logInUser: PropTypes.func.isRequired,
  userTokenState: UserTokenStateType,
};

export default LogInSignUp;
