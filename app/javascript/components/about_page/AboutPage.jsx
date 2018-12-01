import React, { Component } from 'react';
import Page from './About.html';
var htmlDoc = {__html: Page};

export default class AboutPage extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
        <div id="wrap" className="page-container container">
          <div className="row">
            <div className="col-offset-xs-1 col-xs-11">
              <div dangerouslySetInnerHTML={htmlDoc}/>
            </div>
          </div>
        </div>
  )
  }
}
