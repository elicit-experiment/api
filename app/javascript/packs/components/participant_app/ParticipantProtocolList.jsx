import React from 'react'
import ReactDOM from 'react-dom'
import { Provider, connect } from "react-redux";
import PropTypes from 'prop-types'
import { Fade } from '../effects/Fade'
import InlineEdit from 'react-edit-inline';
import update from 'react-addons-update'
import pathToRegexp from 'path-to-regexp'
import elicitApi from "../../api/elicit-api.js"; 
import ParticipantProtocol from "./ParticipantProtocol"


class ParticipantProtocolList extends React.Component {
  render() {
    if (!this.props.eligeable_protocols || !this.props.eligeable_protocols.data) {
      return (<div><h1>Loading...</h1></div>)
    }
    var protocols = this.props.eligeable_protocols.data.map( (protocol_user, i) => {
      return(
        <Fade key={protocol_user.protocol_definition.id} appear={true} >
        <div>
        <ParticipantProtocol protocol={protocol_user.protocol_definition} study={protocol_user.study_definition} users={this.props.users} experiment={protocol_user.experiment} key={protocol_user.protocol_definition.id}> </ParticipantProtocol>
        </div>
        </Fade>
      )
    })

    return(
    <div>
        <h1>You are eligeable to take {protocols.length} protocols.</h1>
        {protocols}
    </div>)
  }
}

export default ParticipantProtocolList;

