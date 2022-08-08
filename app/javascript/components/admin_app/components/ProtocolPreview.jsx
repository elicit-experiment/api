import React from 'react';
import {ProtocolDefinitionType} from 'types';
import { apiOptions } from "../../../api/elicit/tokens";
import { store } from "../../../store/store";

const ProtocolPreview = (props) => {
  if (props.protocol) {
    let phases = props.protocol.phase_definitions.map( (phase) => {
      let trials = phase.trial_definitions.map( (trial) => {
        let previewUrl = `/api/v1/study_definitions/${props.studyId}/protocol_definitions/${props.protocolId}/preview?phase_definition_id=${phase.id}&trial_definition_id=${trial.id}`;
        const fetchTrial = () => {
          console.dir(store)
          console.dir(apiOptions(undefined, undefined, () => store.getState()))
          window.fetch(previewUrl, apiOptions(undefined, undefined, () => store.getState())).then(response => response.json()).then(responseJson => window.location = responseJson.url)
        }
        let trialInfo = `Trial ${trial.id}`;
        if ('name' in trial && !!trial.name && trial.name !== '') {
          trialInfo += ` ${trial.name}`
        }
        return <div className="row" key={trial.id}>
            <div className="offset-4 col-4">{trialInfo}</div>
          <div className="col-4"><button className="btn btn-link" onClick={fetchTrial}> See Preview</button  ></div>
        </div>
      });
      return <div className="container" key={phase.id}>
        <div className="row offset-2 col-10">Phase {phase.id}</div>
        {trials}
      </div>
    });
    return <div>
        <h3 className="offset-1 col-10 center">Protocol &ldquo;{props.protocol.name}&rdquo; Preview</h3>
      <div className="row card">
      {phases}
      </div>
    </div>
  } else {
    return <div></div>
  }
}

ProtocolPreview.propTypes = {
  protocol: ProtocolDefinitionType,
};

export default ProtocolPreview;

