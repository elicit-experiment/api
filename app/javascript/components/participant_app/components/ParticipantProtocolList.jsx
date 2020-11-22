import React from 'react';
import ParticipantProtocol from "./ParticipantProtocol";
import {CurrentUserType, EligibleProtocolsType, LocationType, MatchType, UserTokenType} from 'types';
import PropTypes from 'prop-types';

function ParticipantProtocolList(props) {
  if (!props.eligeable_protocols.sync) {
    if (!props.eligeable_protocols.loading) {
      props.loadEligeableProtocols()
    }
    return (<div><h1>Loading...</h1></div>)
  }

  const protocols = props.eligeable_protocols.data.map((protocolUser) => {
    console.log(protocolUser)
    return (
      <ParticipantProtocol protocol={protocolUser.protocol_definition}
                           study={protocolUser.study_definition}
                           users={props.users}
                           experiment={protocolUser.experiment}
                           key={protocolUser.protocol_definition.id}>
      </ParticipantProtocol>
    )
  });

  return (
    <div className="row">
      <h1 className={"row"}>You are eligible to take {protocols.length} experiments.</h1>
      {protocols}
    </div>)
}

ParticipantProtocolList.propTypes = PropTypes.shape({
    current_user: CurrentUserType.isRequired,
    eligeable_protocols: EligibleProtocolsType.isRequired,
    history: PropTypes.shape({
        action: PropTypes.string.isRequired,
        length: PropTypes.number.isRequired,
        location: LocationType.isRequired,
    }).isRequired,
    location: LocationType.isRequired,
    match: MatchType.isRequired,
    tokenStatus: PropTypes.string.isRequired,
    userToken: UserTokenType,
}).isRequired;

export default ParticipantProtocolList;

