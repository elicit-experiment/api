import PropTypes from 'prop-types'
import React from 'react'
import {ApiReturnCollectionOf, MatchType, ProtocolDefinitionType, StudyDefinitionType} from "../../../types";
import { EditableProtocolCard } from "./ProtocolDetailCard";
// import { Tooltip } from "react-bootstrap";

/*
import update from 'react-addons-update'
  titleChanged(data) {
      const newData = update(this.props.study, {
        title: {$set: data.title},
      });
      this.props.updateStudyDefinition(this.props.study.id, newData);
      this.setState({...data});
  }

  validateTitle(text) {
    return (text.length > 0 && text.length < 64);
  }

  deleteItem(_item) {
  this.props.deleteStudyById(this.state.study.id);
}
*/

const completionStatus = (experiment) => {
  if (!experiment) return 'Not started';
  if (experiment.completed_at) return 'Completed';
  return `Started: completed ${experiment.num_stages_completed} stages, ${experiment.num_stages_remaining} remaining`;
}

export function ExperimentStatus(props) {
  if (!props.experiment) {
    return <svg viewBox="0 0 32 32" width="1.5rem" height="1.5rem">
      <circle r="14" cx="16" cy="16" stroke="black" strokeWidth="2" fill="#aaa"></circle>
    </svg>
  } else {
    const strokeWidth = 11;
    const fullRadius = Math.PI * 2 * strokeWidth;
    const pct = props.experiment.num_stages_completed / (props.experiment.num_stages_remaining + props.experiment.num_stages_completed);
    const strokeDasharray = `${fullRadius*pct} ${fullRadius*(1-pct)}`;

    console.log(props.experiment)
    return <svg viewBox="0 0 32 32" width="1.5rem" height="1.5rem">
      <circle r="14" cx="16" cy="16" stroke="black" strokeWidth="2" fill="none"></circle>
      <g transform="translate(16,16)">
        <g transform="rotate(270)">
          <circle r={strokeWidth/2} cx="0" cy="0" strokeDasharray={strokeDasharray} stroke="green" fill="none"  strokeWidth={strokeWidth}></circle>
        </g>
      </g>
    </svg>
// strokeDashoffset={fullRadius*1/4}
  }
}

export function UserRoleIcon(props) {
  switch (props.role) {
    case 'anonymous':
      return <a title="Anonymous" ><i className="fas fa-ghost"/></a>;
    case 'registered_user':
      return <a title="Registered" ><i className="fas fa-user-check"/></a>;
    case 'admin':
      return <a title="Anonymous" ><i className="fas fa-user-shield"/></a>;
    case 'investigator':
      return <a title="Investigator" ><i className="fas fa-clipboard"/></a>;
  }
}

export function DetailProtocolList(props) {
  let protocolList = props.study_protocols.map((protocol, _i) => {
    // This is a little gross.  Because the protocol_definitions inside the study definitions
    // don't get updated when we patch the protocol definition, we need to check if there's
    // a protocol_definition in the protocol_definitions state which matches the id, and treat
    // that as authoritative.
    let protocolDefinition = props.protocols.data.filter((p) => (p.id === protocol.id));
    if (protocolDefinition && (protocolDefinition.length > 0)) {
      protocol = protocolDefinition[0]
    }
    const protocolUserList = protocol.protocol_users ? protocol.protocol_users.map((protocolUser) => {
      return <div key={protocolUser.id} className="row col-12 ">
        <div className="col-3">{protocolUser.user.email}</div>
        <div className="col-6">
          <span className="mx-4">
            <UserRoleIcon role={protocolUser.user.role}/>
          </span>
          <span className="mx-4">
          <a title={protocolUser.user.auto_created ? 'Auto Created' : 'Specified'}>
          {protocolUser.user.auto_created ? <i className="fas fa-user-plus"></i> : <i className="fas fa-user"></i>}
          </a>
          </span>
          <span className="mx-4">
          <a title={completionStatus(protocolUser.experiment)}>
            <ExperimentStatus experiment={protocolUser.experiment}/>
          </a>
          </span>
        </div>
      </div>
    }) : <div/>;
    return <EditableProtocolCard protocol={protocol} study={props.study} key={protocol.id}>
      <h3 className="row col-12">Users</h3>
      <div className="row container col-12">
        {protocolUserList}
      </div>
    </EditableProtocolCard>;
  });

  return (<>{protocolList}</>);
}

function EditStudyPanel(props) {
  if (props.study) {
    return (
      <div>
        <h1>Study {props.study.id} &mdash; {props.study.title}</h1>
        <div className="container">
          <div className="row study-info-row">
            <b className="col-2">PI:</b>
            <div className="col-5">
              <b>{props.study.principal_investigator.email}</b>
            </div>
          </div>
          <div className="row study-info-row">
            <b className="col-2">Description:</b>
            <div className="col-10">
              {props.study.description}
            </div>
          </div>
        </div>
        <DetailProtocolList protocols={{loading: false, sync: true, syncing: false, data:props.study.protocol_definitions}}
                            study_protocols={props.study.protocol_definitions}
                            study={props.study}/>
      </div>
    )
  } else {
    return (
      <div>
        <h1>Unknown study!</h1>
      </div>
    )
  }
}

EditStudyPanel.propTypes = {
  match: MatchType,
  study: StudyDefinitionType.isRequired,
  deleteStudyById: PropTypes.func,
  updateStudyDefinition: PropTypes.func,
}

export default EditStudyPanel;

DetailProtocolList.propTypes = {
  protocols: ApiReturnCollectionOf(ProtocolDefinitionType).isRequired,
  study: StudyDefinitionType.isRequired,
  study_protocols: PropTypes.arrayOf(ProtocolDefinitionType).isRequired,
}

UserRoleIcon.propTypes = {
  role: PropTypes.string.isRequired,
}
