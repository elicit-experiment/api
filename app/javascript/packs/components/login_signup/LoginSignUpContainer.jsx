// Import Dependencies
import {connect} from 'react-redux';
import React from 'react';
import $ from 'jquery'

// Import Component
import LoginSignUp from './LoginSignUp';

// Import Actions
import {logInUser} from '../../actions/tokens_actions';

import {clientToken, userToken, userTokenState, currentUser, tokenStatus} from '../../reducers/selector';

import elicitApi from '../../api/elicit-api.js';

import ReactDOM from 'react-dom'
import {Switch, Route, BrowserRouter, Redirect} from 'react-router-dom'

class LoginSignUpContainer extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      pleaseWait: 'hidden',
      loginSignup: 'hidden'
    }
  }

  componentDidMount() {
    $('#logInModal')
        .on('hidden.bs.modal', () => {
          this.setState({loginSignup: 'hidden'})
        })
        .on('shown.bs.modal', () => {
          this.setState({loginSignup: 'shown'})
        });
    $('#pleaseWaitDialog')
        .on('hidden.bs.modal', () => {
          this.setState({pleaseWait: 'hidden'})
        })
        .on('shown.bs.modal', () => {
          this.setState({pleaseWait: 'shown'})
        });
    this.setModalState()
  }

  componentWillUnmount() {
    this.unbindAll()
  }

  componentDidUpdate() {
    this.setModalState()
  }

  unbindAll() {
    $('#pleaseWaitDialog').off()
    $('#logInModal').off()
  }

  setModalState() {
    if (this.showPleaseWait() && (this.state.pleaseWait === 'hidden')) {
      $('#pleaseWaitDialog').modal('show');
    } else if (!this.showPleaseWait() && (this.state.pleaseWait.startsWith('show'))) {
      $('#pleaseWaitDialog').modal('hide');
    }

    if (this.showLoginSignup() && (this.state.loginSignup === 'hidden')) {
      $('#logInModal').modal('show')
    } else if (!this.showLoginSignup() && (this.state.loginSignup === 'shown')) {
      $('#logInModal').modal('hide')
    }

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
      debugger;
    }
    if (this.props.tokenStatus === 'user') {
      if (this.props.currentUser && this.props.currentUser.sync) {
        if ((this.state.pleaseWait === 'hidden') && (this.state.loginSignup === 'hidden')) {
          this.unbindAll()

          // Hack for previous issues with timing of navigation vs. modal dismissal animation
          //$('.modal-backdrop').remove()

          console.log('Loaded current user!');
          console.dir(this.props.currentUser);

          if (this.props.currentUser.data.role === 'admin') {
            return <Redirect to="/admin"/>
          } else {
            return <Redirect to="/participant"/>
          }
        }
      }
    }

    return <div>
      <h1 className="elicit-title">Elicit</h1>
      <h3 className="elicit-subtitle">dtu</h3>
      <LoginSignUp {...this.props} dismissable={false} hidden={!this.showLoginSignup()}></LoginSignUp>
      <div>
        <div className="modal" id="pleaseWaitDialog" tabIndex="-1" role="dialog" aria-labelledby="myModalLabel"
             aria-hidden={String(!this.showPleaseWait())}>
          <div className="modal-dialog">
            <div className="modal-content">
              <div className="modal-header">
                <h1>Logging in...</h1>
              </div>
              <div className="modal-body">
                <div className="progress">
                  <div className="progress-bar progress-bar-success progress-bar-striped" role="progressbar"
                       aria-valuenow="80" aria-valuemin="0" aria-valuemax="100" style={{width: "40%"}}>
                    <span className="sr-only">80% Complete (success)</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

  }
}

//Map State to Props
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
  logInUser: (data) => dispatch(logInUser(data, () => { }))
});


export default connect(
    mapStateToProps,
    mapDispatchToProps
)(LoginSignUpContainer);
