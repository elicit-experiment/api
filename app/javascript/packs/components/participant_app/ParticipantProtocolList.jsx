import React from 'react'
import ReactDOM from 'react-dom'
import { Provider, connect } from "react-redux";
import PropTypes from 'prop-types'
import { Fade } from '../effects/Fade'
import InlineEdit from 'react-edit-inline';
import update from 'react-addons-update'
import Dropdown from '../DropDown'
import Study from './ParticipantStudy'
import { Link } from 'react-router-dom'
import pathToRegexp from 'path-to-regexp'
import elicitApi from "../../api/elicit-api.js"; 
import ParticipantProtocol from "./ParticipantProtocol"


class ParticipantProtocolList extends React.Component {
  render() {
    var protocols = this.props.study.protocol_definitions.map( (protocol, i) => {
      return(
        <Fade key={protocol.id} appear={true} >
        <div>
        <ParticipantProtocol protocol={protocol} study={this.props.study} users={this.props.users} key={protocol.id}> </ParticipantProtocol>
        </div>
        </Fade>
      )
    })

    return(
    <div>
        {protocols}
    </div>)
  }
}

export default ParticipantProtocolList;

