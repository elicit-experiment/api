//Import Dependencies
import React from 'react';

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
                          password: this.state.password,
                          password_confirmation: this.state.passwordConfirmation };
      this.props.createUser({user: credentials});
      $("#signUpModal").modal('hide');
    };
  }

  // Dispatches the action to make the API call for logging in a user and removes the login form modal
  logInUser() {
    return (e) => {
      e.preventDefault();
      let credentials = { email: this.state.email,
                          password: this.state.password };
      this.props.logInUser(credentials);
      $("#logInModal").modal('hide');
      $("#myNavbar").collapse("hide"); // Hides the collapsible dropdown navbar while on mobile devices
    };
  }

  dismissButton() {
    return this.state.dismissable ? <button type="button" className="close" data-dismiss="modal">&times;</button> : <div></div>
  }

  // Generates the HTML for the login form
  logInForm() {
    return(
      <div className="modal fade" id="logInModal" role="dialog">
        <div className="modal-dialog">

          <div className="modal-content">
            <div className="modal-header" style={{padding:"35px 50px"}}>
              {this.dismissButton()}
              <h4><span className="glyphicon glyphicon-lock"></span> Login</h4>
            </div>
            <div className="modal-body" style={{padding:"40px 50px"}}>
              <form role="form" onSubmit={this.logInUser()}>
                <div className="form-group">
                  <label htmlFor="usrname"><span className="glyphicon glyphicon-user"></span> Email</label>
                  <input type="text"
                         className="form-control"
                         id="email"
                         placeholder="Enter email"
                         onChange={this.updateState('email')}/>
                </div>
                <div className="form-group">
                  <label htmlFor="psw"><span className="glyphicon glyphicon-eye-open"></span> Password</label>
                  <input type="password"
                         className="form-control"
                         id="psw"
                         placeholder="Enter password"
                         onChange={this.updateState('password')}/>
                </div>
                <div className="checkbox">
                  <label><input type="checkbox" value=""/>Remember me</label>
                </div>
                <button type="submit" className="btn btn-success btn-block"><span className="glyphicon glyphicon-off"></span> Login</button>
              </form>
            </div>
            <div className="modal-footer">
              <button type="submit" className="btn btn-danger btn-default pull-left" data-dismiss="modal"><span className="glyphicon glyphicon-remove"></span> Cancel</button>
              <p>Not a member? <a href="#" onClick={this.toggleLogIn}>Sign Up</a></p>
              <p>Forgot <a href="#">Password?</a></p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Generates the HTML for the sign up form
  signUpForm() {
    return(
      <div className="modal fade" id="signUpModal" role="dialog">
        <div className="modal-dialog">

          <div className="modal-content">
            <div className="modal-header" style={{padding:"35px 50px"}}>
              {this.dismissButton()}
              <h4><span className="glyphicon glyphicon-lock"></span> Sign Up</h4>
            </div>
            <div className="modal-body" style={{padding:"40px 50px"}}>
              <form role="form" onSubmit={this.signUpUser()}>
                <div className="form-group">
                  <label htmlFor="usrname"><span className="glyphicon glyphicon-user"></span> Email</label>
                  <input type="text"
                         className="form-control"
                         id="usrname"
                         placeholder="Enter email"
                         onChange={this.updateState('email')}/>
                </div>
                <div className="form-group">
                  <label htmlFor="psw"><span className="glyphicon glyphicon-eye-open"></span> Password</label>
                  <input type="password"
                         className="form-control"
                         id="psw"
                         placeholder="Enter password"
                         onChange={this.updateState('password')}/>
                </div>
                <div className="form-group">
                  <label htmlFor="psw"><span className="glyphicon glyphicon-eye-open"></span> Confirm Password</label>
                  <input type="password"
                         className="form-control"
                         id="psw"
                         placeholder="Re-enter password"
                         onChange={this.updateState('passwordConfirmation')}/>
                </div>
                <div className="checkbox">
                  <label><input type="checkbox" value=""/>Remember me</label>
                </div>
                  <button type="submit" className="btn btn-success btn-block"><span className="glyphicon glyphicon-off"></span> Sign Up</button>
              </form>
            </div>
            <div className="modal-footer">
              <button type="submit" className="btn btn-danger btn-default pull-left" data-dismiss="modal"><span className="glyphicon glyphicon-remove"></span> Cancel</button>
              <p>Already a Member? <a href="#" onClick={this.toggleLogIn}>Log In</a></p>
              <p>Forgot <a href="#">Password?</a></p>
            </div>
          </div>
        </div>
      </div>
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
