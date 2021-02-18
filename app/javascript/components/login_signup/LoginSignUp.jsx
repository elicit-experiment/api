//Import Dependencies
import PropTypes from 'prop-types'
import React from 'react';
import Modal from "react-bootstrap/Modal";

class LogInSignUp extends React.Component {
  constructor(props) {
    super(props);
    this.logInForm = this.logInForm.bind(this);
    this.signUpForm = this.signUpForm.bind(this);
    this.toggleLogIn = this.toggleLogIn.bind(this);
    this.state = {
      logInForm: true,
      dismissable: props.dismissable || false,
      email: "",
      username: "",
      password: "",
      passwordConfirmation: "",
    };
  }

  // Callback function to update the state of the component
  updateState(key) {
    return e => this.setState({[key]: e.target.value});
  }

  // Updates state to determine whether to render the login form or sign-up form
  toggleLogIn(e) {
    e.preventDefault();
    if (this.state.logInForm === true) {
      this.setState({logInForm: false});
    }
    else {
      this.setState({logInForm: true});
    }
  }

  // Dispatches the action to make the API call for signing up a user and removes the sign up form modal
  signUpUser() {
    return (e) => {
      e.preventDefault();
      let credentials = { email: this.state.email,
                          username: this.state.username,
                          password: this.state.password,
                          password_confirmation: this.state.passwordConfirmation };
      this.props.createUser({user: credentials}).then(()=>{this.props.logInUser(credentials)});
    };
  }

  // Dispatches the action to make the API call for logging in a user and removes the login form modal
  logInUser() {
    return (e) => {
      e.preventDefault();
      let credentials = { email: this.state.email,
                          password: this.state.password };
      this.props.logInUser(credentials);
    };
  }

  dismissButton() {
    return this.state.dismissable ? <button type="button" className="close" data-dismiss="modal">&times;</button> : <div></div>
  }

  // Generates the HTML for the login form
  logInForm() {
    var error = <div></div>;
    if (this.props.userTokenState && this.props.userTokenState.error) {
      var error_text="";
      switch (this.props.userTokenState.error_code) {
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
          <form role="form" onSubmit={this.logInUser()}>
            <div className="form-group">
              <label htmlFor="usrname"><span className="fas fa-user fa-envelope"></span> Username or Email</label>
              <input type="text"
                     className="form-control"
                     id="email"
                     placeholder="Enter email"
                     autoComplete="username"
                     onChange={this.updateState('email')}/>
            </div>
            <div className="form-group">
              <label htmlFor="psw"><span className="fas fa-eye"></span> Password</label>
              <input type="password"
                     className="form-control"
                     id="psw"
                     placeholder="Enter password"
                     autoComplete="current-password"
                     onChange={this.updateState('password')}/>
            </div>
            <button type="submit" className="btn btn-success btn-block"><span className="fas fa-power-off"></span> Login</button>
          </form>
        </Modal.Body>
        <Modal.Footer>
          <p>Not a member? <a href="#" onClick={this.toggleLogIn}>Sign Up</a></p>
          <p>Forgot <a href="#">Password?</a></p>
        </Modal.Footer>
      </Modal>
    );
  }

  // Generates the HTML for the sign up form
  signUpForm() {
    return(
      <Modal show={true}>
           <Modal.Header>
              <h4><span className="fas fa-lock"></span> Sign Up</h4>
            </Modal.Header>
            <Modal.Body>
              <form role="form" onSubmit={this.signUpUser()}>
                <div className="form-group">
                  <label htmlFor="usrname"><span className="fas fa-user"></span> User Name</label>
                  <input type="text"
                         className="form-control"
                         id="usrname"
                         placeholder="Entername"
                         autoComplete="username"
                         onChange={this.updateState('username')}/>
                </div>
                <div className="form-group">
                  <label htmlFor="usremail"><span className="fas fa-envelope"></span> Email</label>
                  <input type="text"
                         className="form-control"
                         id="usremail"
                         placeholder="Enter email"
                         onChange={this.updateState('email')}/>
                </div>
                <div className="form-group">
                  <label htmlFor="psw"><span className="fas fa-eye"></span> Password</label>
                  <input type="password"
                         className="form-control"
                         id="psw"
                         placeholder="Enter password"
                         autoComplete="new-password"
                         onChange={this.updateState('password')}/>
                </div>
                <div className="form-group">
                  <label htmlFor="psw"><span className="fas fa-eye"></span> Confirm Password</label>
                  <input type="password"
                         className="form-control"
                         id="pswConf"
                         placeholder="Re-enter password"
                         autoComplete="new-password"
                         onChange={this.updateState('passwordConfirmation')}/>
                </div>
                <div className="checkbox">
                  <label><input type="checkbox" value=""/>Remember me</label>
                </div>
                  <button type="submit" className="btn btn-success btn-block"><span className="fas fa-power-off"></span> Sign Up</button>
              </form>
            </Modal.Body>
            <Modal.Footer>
              <p>Already a Member? <a href="#" onClick={this.toggleLogIn}>Log In</a></p>
              <p>Forgot <a href="#">Password?</a></p>
            </Modal.Footer>
          </Modal>
    );
  }

  render() {
    if (this.state.logInForm) {
      return(
        this.logInForm()
      );
    }
    else {
      return(
        this.signUpForm()
      );
    }
  }
}

export default LogInSignUp;

LogInSignUp.propTypes = {
  createUser: PropTypes.func.isRequired,
  dismissable: PropTypes.bool.isRequired,
  logInUser: PropTypes.func.isRequired,
  userTokenState: PropTypes.string,
}
