import React, { Component } from 'react';
import FrontPagePreface from './FrontPagePreface.html';
var htmlDoc = {__html: FrontPagePreface};

export default class FrontPage extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
        <div id="wrap" className="admin-app-container container">
          <div className="row">
            <div className="col-offset-xs-1 col-xs-11" dangerouslySetInnerHTML={htmlDoc} />
          </div>
          <div className="row">
            <div className="col-offset-xs-1 col-xs-11">
              <h2>Studies you can take...</h2>
            </div>
          </div>
        </div>
    )
  }
}

//          <ParticipantProtocolList {...this.props} />
