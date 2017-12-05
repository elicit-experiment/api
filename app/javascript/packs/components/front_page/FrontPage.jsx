// Import React and Dependencies
import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import {Link} from 'react-router-dom'

// Import components
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
            <div className="col-xs-offset-1 col-xs-11" dangerouslySetInnerHTML={htmlDoc} />
          </div>
          <div className="row">
            <div className="col-xs-offset-1 col-xs-11">
              <h2>Studies you can take...</h2>
              <p> In the future, you'll see a list here.  Until then <Link to="/participant">click here</Link> to see the studies you're eligeable for </p>
            </div>
          </div>
        </div>
    )
  }
}

//          <ParticipantProtocolList {...this.props} />
