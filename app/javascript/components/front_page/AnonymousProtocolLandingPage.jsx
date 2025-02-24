import React from 'react';
import PropTypes from 'prop-types';
import {ProtocolDefinitionType} from '../../types';
import TakeProtocolLink from '../participant_app/components/TakeProtocolLink';

const AnonymousProtocolLandingPage = ({ protocol, takeProtocol }) => {
  const htmlDescription = {
    dangerouslySetInnerHTML: {__html: protocol.description},
  };

  const takeProtocolLink = <TakeProtocolLink
      study_id={protocol.study_definition_id}
      protocol_id={protocol.id}
      available={protocol.has_remaining_anonymous_slots}
      take_protocol={takeProtocol}/>;

  let instructions = '';

  try {
    let instructionsHtml = "No instructions";
    try {
      instructionsHtml = (JSON.parse(protocol.definition_data) || {}).instructionsHtml;
    } catch (e) {
      console.warn("Error parsing instructions");
    }
    if (instructionsHtml) {
      const htmlInstructions = {
        dangerouslySetInnerHTML: {__html: instructionsHtml},
      };
      instructions = <div className="row">
        <div className="col-12"><h3>Instructions</h3></div>
        <div className="col-12" {...htmlInstructions}></div>
      </div>;
    }
  }
  catch (pe) {
    console.error(pe);
  }

  return (
    <div className="row well " key={protocol.id}>
      <div
          className="protocol-row protocol-header-row"
          key={'t' + protocol.id}
      >
        <div className="col-10 offset-2">
          <b>{protocol.id} — {protocol.name}</b>
        </div>
      </div>

      <div className="row">
        <div className="col-12"><h3>Description</h3></div>
        <div className="col-10 offset-2"
             key={'d' + protocol.id}>
          <div className="col-12" {...htmlDescription}></div>
        </div>
      </div>

      {instructions}

      <div className="row">
        <div className="col-12 center">
          {takeProtocolLink}
        </div>
      </div>
    </div>
  );
};

AnonymousProtocolLandingPage.propTypes = {
  protocol: ProtocolDefinitionType,
  takeProtocol: PropTypes.func.isRequired,
};

export default AnonymousProtocolLandingPage;
