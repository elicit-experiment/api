// Import Dependencies
import PropTypes from 'prop-types'
import {connect} from 'react-redux';
import React from 'react';

// Import Component
import LoginSignUp from './LoginSignUp';
import Modal from "react-bootstrap/Modal";

// Import Actions
import {logInUser} from '../../actions/tokens_actions';

import {clientToken, userToken, userTokenState, currentUser, tokenStatus} from '../../reducers/selector';

import elicitApi from '../../api/elicit-api.js';

import {Navigate} from 'react-router-dom'
import {CurrentUserType} from "../../types";

class LoginSignUpContainer extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      pleaseWait: 'hidden',
      loginSignup: 'hidden',
    }
  }

  componentWillUnmount() {
  }

  componentDidUpdate() {
    this.setModalState()
  }

  setModalState() {
    if (this.props.tokenStatus === 'user') {
      if (this.props.currentUser && !this.props.currentUser.sync && !this.props.currentUser.loading) {
        this.props.getCurrentUser()
      }
    }
  }

  showPleaseWait() {
    return (this.props.userTokenState && this.props.userTokenState.loading) ||
        (this.props.currentUser && this.props.currentUser.loading);
  }

  showLoginSignup() {
    return (this.props.tokenStatus !== 'user') && (!this.props.userTokenState || this.props.userTokenState.error)
  }

  render() {
    if (this.showLoginSignup() && this.showPleaseWait()) {
      // debugger;
      console.error('invalid state');
    }
    if (this.props.tokenStatus === 'user') {
      if (this.props.currentUser && this.props.currentUser.sync) {
        if ((this.state.pleaseWait === 'hidden') && (this.state.loginSignup === 'hidden')) {
          console.log('Loaded current user!');
          console.dir(this.props.currentUser);

          if (this.props.currentUser.data.role === 'admin') {
            return <Navigate to="/admin"/>
          } else {
            return <Navigate to="/participant"/>
          }
        }
      }
    }

    return <div className="single-page">
      <h1 className="elicit-bg-title">Elicit</h1>
      <h3 className="elicit-subtitle"/>
      <LoginSignUp {...this.props} showLoginSignup={this.showLoginSignup()} dismissable={false}/>
      <Modal show={this.showPleaseWait()}>
        <Modal.Header><h1>Logging in...</h1></Modal.Header>
        <Modal.Body>
          <div className="progress">
            <div className="progress-bar progress-bar-success progress-bar-striped" role="progressbar"
                 aria-valuenow="80" aria-valuemin="0" aria-valuemax="100" style={{width: "40%"}}>
              <span className="sr-only">80% Complete (success)</span>
            </div>
          </div>
        </Modal.Body>
      </Modal>
    </div>

  }
}

// Map State to Props
const mapStateToProps = (state) => ({
  clientToken: clientToken(state),
  userToken: userToken(state),
  userTokenState: userTokenState(state),
  currentUser: currentUser(state),
  tokenStatus: tokenStatus(state),
});

// Map Dispatch to Props
const mapDispatchToProps = (dispatch) => ({
  createUser: (new_user_def) => dispatch(elicitApi.actions.user.post({}, {body: JSON.stringify(new_user_def)})),
  getCurrentUser: () => { dispatch(elicitApi.actions.current_user()) },
  logInUser: (data) => dispatch(logInUser(data, () => { })),
});

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(LoginSignUpContainer);

LoginSignUpContainer.propTypes = {
  currentUser: CurrentUserType,
  getCurrentUser: PropTypes.func.isRequired,
  tokenStatus: PropTypes.string.isRequired,
  userTokenState: PropTypes.string,
}
