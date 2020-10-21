import React from 'react';
import PropTypes from 'prop-types';
import {ProtocolDefinitionType} from '../../types';
import TakeProtocolLink from '../participant_app/TakeProtocolLink';

class AnonymousProtocolLandingPage extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const htmlDescription = {
      dangerouslySetInnerHTML: {__html: this.props.protocol.description},
    };

    const takeProtocol = <TakeProtocolLink
        study_id={this.props.protocol.study_definition_id}
        protocol_id={this.props.protocol.id}
        take_protocol={this.props.takeProtocol}/>;

    let instructions = '';

    try {
      let instructionsHtml = "No instructions";
      try {
        instructionsHtml = (JSON.parse(this.props.protocol.definition_data) || {}).instructionsHtml;
      } catch (e) {
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
        <div className="row well " key={this.props.protocol.id}>
          <div
              className="protocol-row protocol-header-row"
              key={'t' + this.props.protocol.id}
          >
            <div className="col-10 offset-2">
              <b>{this.props.protocol.id} — {this.props.protocol.name}</b>
            </div>
          </div>

          <div className="row">
            <div className="col-12"><h3>Description</h3></div>
            <div className="col-10 offset-2"
                 key={'d' + this.props.protocol.id}>
              <div className="col-12" {...htmlDescription}></div>
            </div>
          </div>

          {instructions}

          <div className="row">
            <div className="col-12 center">
              {takeProtocol}
            </div>
          </div>
        </div>
    );
  }
}

AnonymousProtocolLandingPage.propTypes = {
  protocol: ProtocolDefinitionType,
  takeProtocol: PropTypes.func.isRequired,
};

export default AnonymousProtocolLandingPage;
