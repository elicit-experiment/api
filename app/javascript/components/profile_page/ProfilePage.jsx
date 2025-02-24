import React, { Component } from 'react';
import PropTypes from 'prop-types';

const publicClientId = process.env.PUBLIC_CLIENT_ID;
const publicClientSecret = process.env.PUBLIC_CLIENT_SECRET;

export default class ProfilePage extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    const apiSection = (this.props.current_user.role === 'investigator' || this.props.current_user.role === 'admin') ?
      <section className="card p-2 mb-2">
        <h3>API</h3>
        <p>Client ID: <span><pre>{publicClientId}</pre></span></p>
        <p>Client SECRET: <span><pre>{publicClientSecret}</pre></span></p>
      </section>
      : '';

    return (
        <div id="wrap" className="page-container container">
          <div className="row">
            <div className="offset-1 col-11">
              <h2 className="mt-3">Profile for {this.props.current_user.email}</h2>

              <section className="card p-2 mb-2">
                <p>Role: <span><b>{this.props.current_user.role}</b></span></p>
              </section>

              <section className="card p-2 mb-2">
                <h3>Account</h3>

                <div className='row'>
                  <button className='btn btn-primary offset-3 col-3' disabled={true}>Reset Password</button>
                  <button className='btn btn-danger ml-1 col-3' disabled={true}>Delete Account</button>
                </div>
                <p></p>
              </section>

              {apiSection}

              <section className="card p-2 mb-2">
                <h3>Study Participation</h3>
                <p>Under Construction...</p>
              </section>

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
