import React from 'react';
//import PropTypes from 'prop-types';
import { MatchType } from 'types';

export default class ProtocolPreview extends React.Component {
  render() {
    if (this.props.protocol) {
      let phases = this.props.protocol.phase_definitions.map( (phase) => {
        let trials = phase.trial_definitions.map( (trial) => {
          let preview_href = `/api/v1/study_definitions/${this.props.match.params.study_id}/protocol_definitions/${this.props.match.params.protocol_id}/preview?phase_definition_id=${phase.id}&trial_definition_id=${trial.id}`;
          return <div className="row" key={trial.id}>
              <div className="col-xs-offset-4 col-xs-4">Trial {trial.id}</div>
            <div className="col-xs-4"><a href={preview_href}> See Preview</a></div>
          </div>
        });
        return <div className="row" key={phase.id}>
          <div className="row col-xs-offset-2 col-xs-10">Phase {phase.id}</div>
          {trials}
        </div>
      });
      return <div>
          <h3 className="col-xs-offset-1 col-xs-10 center">Protocol &ldquo;{this.props.protocol.name}&rdquo; Preview</h3>
        <div className="row well">
        {phases}
        </div>
      </div>
    } else {
      return <div></div>
    }
  }
}

ProtocolPreview.propTypes = {
	match: MatchType,
};
