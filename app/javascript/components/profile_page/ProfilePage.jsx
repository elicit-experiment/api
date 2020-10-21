import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default class ProfilePage extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
        <div id="wrap" className="page-container container">
          <div className="row">
            <div className="offset-1 col-11">
              <h2>Profile for {this.props.current_user.email}</h2>

              <p>Role: <span><b>{this.props.current_user.role}</b></span></p>

              <h3>Account</h3>

              <div className='row'>
                <button className='btn btn-primary offset-1 col-3' disabled={true}>Reset Password</button>
                <button className='btn btn-danger offset-1 col-3' disabled={true}>Delete Account</button>
              </div>

              <h3>Study Participation</h3>

              <p>Under Construction...</p>

            </div>
          </div>
        </div>
    )
  }
}

ProfilePage.propTypes = {
  current_user: PropTypes.object.isRequired,
};

ProfilePage.defaultProps = {
};
