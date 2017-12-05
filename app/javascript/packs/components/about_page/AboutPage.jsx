import React, { Component } from 'react';
import Page from './About.html';
var htmlDoc = {__html: Page};

export default class AboutPage extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (<div dangerouslySetInnerHTML={htmlDoc} />)
  }
}
