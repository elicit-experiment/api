import React from 'react';
const dateFormat = require('dateformat');

export default class ParticipantProtocol extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
    const date = Date.parse(this.props.date);
    const dateText = dateFormat(date, "dddd, mmmm dS, yyyy, h:MM:ss TT");
    return (<span>{dateText}</span>)
  }
}
