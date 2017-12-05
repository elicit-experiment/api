import React, { Component } from 'react';

export default class ProfilePage extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
        <div id="wrap" className="page-container container">
          <div className="row">
            <div className="col-offset-xs-1 col-xs-11">
              <h2>Profile for {this.props.current_user.email}</h2>
            </div>
          </div>
        </div>
    )
  }
}

ProfilePage.propTypes = {
  current_user: React.PropTypes.object.isRequired,
};

ProfilePage.defaultProps = {
};
