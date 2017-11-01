// Import Dependencies
import { connect } from 'react-redux';
import React from 'react';
import $ from 'jquery'

// Import Component
import LoginSignUp from './LoginSignUp';

// Import Actions
import { logInUser } from '../../actions/tokens_actions';

import { clientToken, userToken, userTokenState, currentUser } from '../../reducers/selector';

import elicitApi from '../../api/elicit-api.js';

import ReactDOM from 'react-dom'
import { Switch, Route, BrowserRouter, Redirect } from 'react-router-dom'


//Map State to Props
const mapStateToProps = (state) => ({
  clientToken: clientToken(state),
  userToken: userToken(state),
  userTokenState: userTokenState(state),
  currentUser: currentUser(state),
});

// Map Dispatch to Props
const mapDispatchToProps = (dispatch) => ({
  createUser: (new_user_def) => dispatch(elicitApi.actions.user.post({}, { body: JSON.stringify(new_user_def) } )),
  logInUser: (data) => dispatch(logInUser(data, () => {dispatch(elicitApi.actions.current_user()) }) )
});

class LoginSignUpContainer extends React.Component {
  componentDidMount() {
    $('#logInModal').modal()
    $('#pleaseWaitDialog').modal()
  }
  componentDidUpdate() {
    if (this.props.userTokenState && this.props.userTokenState.isLoading) {
      $('#pleaseWaitDialog').modal('show')
      $('#logInModal').modal('hide')
    } else {
      $('#pleaseWaitDialog').modal('hide')      
      $('#logInModal').modal('show')
    }
  }
  render() {
    if (this.props.token_status == 'user' && this.props.currentUser && this.props.currentUser.sync) {
      $('#pleaseWaitDialog').modal('hide')
      console.log('Loaded current user!')
      $('.modal-backdrop').remove()
      console.dir(this.props.currentUser)
      if (this.props.currentUser.data.role == 'admin') {
        return <Redirect to="/admin"/>
      } else {
        return <Redirect to="/participant"/>
      }
    }

    var dialog;

//    if (this.props.userToken && this.props.currentUser) {
    if (this.props.userTokenState && this.props.userTokenState.isLoading) {
      dialog = <div><div className="modal" id="pleaseWaitDialog" tabIndex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="false">
  <div className="modal-dialog">
    <div className="modal-content">
      <div className="modal-header">
          <h1>Logging in...</h1>
      </div>
      <div className="modal-body">
        <div className="progress">
          <div className="progress-bar progress-bar-success progress-bar-striped" role="progressbar" aria-valuenow="80" aria-valuemin="0" aria-valuemax="100" style={ {width: "40%" } }>
            <span className="sr-only">80% Complete (success)</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</div></div>
    } else {
      dialog = <LoginSignUp {...this.props} dismissable={false}></LoginSignUp>
    }

    return <div>
              <h1 className="elicit-title">Elicit</h1>
              <h3 className="elicit-subtitle">dtu</h3>
              {dialog}
           </div>

  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(LoginSignUpContainer);
