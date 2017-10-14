import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import InlineEdit from 'react-edit-inline'
import update from 'react-addons-update'
import Dropdown from '../DropDown'
import { Link } from 'react-router-dom'
import pathToRegexp from 'path-to-regexp'
import elicitApi from '../../api/elicit-api.js'
import { connect } from "react-redux";
import elicitConfig from '../../ElicitConfig.js'

const TakeProtocolLink = (props) => {
  return (
      <button onClick={ (e) => {
        props.take_protocol({study_definition_id: props.study_id, protocol_definition_id: props.protocol_id }) } } className="active btn btn-xs ">
          Take Protocol
      </button>
  )
}


class ParticipantProtocol extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
    var study_class = 'well show study-summary'
    return (
      <div className='protocols-wrapper col-xs-10' key={this.props.protocol.id}>
            <b className="col-xs-2">Protocol:</b>
            <div className='col-xs-5'>
              {this.props.protocol.id} — {this.props.protocol.title}
            </div>
          <div className="col-xs-5">
            <TakeProtocolLink study_id={this.props.study.id} protocol_id={this.props.protocol.id} take_protocol={this.props.take_protocol}/>
          </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => ({
});
const mapDispatchToProps = (dispatch) => ({
    take_protocol: (s) => { dispatch(elicitApi.actions.take_protocol(s)) }
});

export default connect(mapStateToProps, mapDispatchToProps)(ParticipantProtocol);

