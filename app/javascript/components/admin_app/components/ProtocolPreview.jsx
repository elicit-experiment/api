import React from 'react';
import {MatchType, ProtocolDefinitionType} from 'types';

export default class ProtocolPreview extends React.Component {
  render() {
    if (this.props.protocol) {
      let phases = this.props.protocol.phase_definitions.map( (phase) => {
        let trials = phase.trial_definitions.map( (trial) => {
          let preview_href = `/api/v1/study_definitions/${this.props.match.params.study_id}/protocol_definitions/${this.props.match.params.protocol_id}/preview?phase_definition_id=${phase.id}&trial_definition_id=${trial.id}`;
          let trialInfo = `Trial ${trial.id}`;
          if ('name' in trial && !!trial.name && trial.name !== '') {
            trialInfo += ` ${trial.name}`
          }
          return <div className="row" key={trial.id}>
              <div className="offset-4 col-4">{trialInfo}</div>
            <div className="col-4"><a href={preview_href}> See Preview</a></div>
          </div>
        });
        return <div className="container" key={phase.id}>
          <div className="row offset-2 col-10">Phase {phase.id}</div>
          {trials}
        </div>
      });
      return <div>
          <h3 className="offset-1 col-10 center">Protocol &ldquo;{this.props.protocol.name}&rdquo; Preview</h3>
        <div className="row card">
        {phases}
        </div>
      </div>
    } else {
      return <div></div>
    }
  }
}

ProtocolPreview.propTypes = {
  protocol: ProtocolDefinitionType,
	match: MatchType,
};
