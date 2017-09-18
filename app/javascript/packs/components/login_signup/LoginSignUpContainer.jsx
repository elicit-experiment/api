// Import Dependencies
import { connect } from 'react-redux';
import React from 'react';
import $ from 'jquery'

// Import Component
import LoginSignUp from './LoginSignUp';

// Import Actions
import { logInUser } from '../../actions/tokens_actions';
//import { createUser } from '../../actions/users_actions';

//Map State to Props
const mapStateToProps = (state) => ({

});

// Map Dispatch to Props
const mapDispatchToProps = (dispatch) => ({
//  createUser: (data) => dispatch(createUser(data)),
  logInUser: (data) => dispatch(logInUser(data))
});

class LoginSignUpContainer extends React.Component {
  componentDidMount() {
    $('#logInModal').modal()
  }
  render() {
    return <div>
              <h1 className="elicit-title">Elicit</h1>
              <h3 className="elicit-subtitle">dtu</h3>
              <LoginSignUp {...this.props}></LoginSignUp>
           </div>

  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(LoginSignUpContainer);
