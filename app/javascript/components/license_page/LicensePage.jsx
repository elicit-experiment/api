import React, { Component } from 'react';

export default class LicensePage extends Component {
  constructor(props) {
    super(props);
    const markdown = require("../../../../LICENSE.md");

    this.state = {
      markdown,
    };
  }
  componentDidMount() {
    /*
      fetch(markdown)
      .then(response => {
        return response.text()
      })
      .then(markdown => {
        this.setState({
          markdown,
        })
      })*/
  }
  render() {
    const { markdown } = this.state;
    const md = markdown ? <div dangerouslySetInnerHTML={{__html: markdown}}/> : <div></div>;

    return (
        <div id="wrap" className="page-container container">
          <div className="row">
            <div className="offset-xs-1 col-11">
              { md }
            </div>
          </div>
        </div>
  )
  }
}
