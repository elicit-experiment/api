import React from 'react';
import { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import {connect} from "react-redux"
import elicitApi from "../../../api/elicit-api"
import ProtocolPreview from "../components/ProtocolPreview"
import {ApiReturnCollectionOf, ProtocolDefinitionType} from '../../../types';
import {useParams} from "react-router-dom";

const ProtocolPreviewContainer = (props) => {
  const { protocolId, studyId } = useParams()

  const [currentProtocolId, setCurrentProtocolId] = useState(() => (parseInt(protocolId, 10)))

  const ensureProtocolDefinitionLoaded = () => {
    props.loadProtocolDefinition(studyId, protocolId)
  }

  if (!props.protocol_definition.loading && !( (props.protocol_definition.sync && (props.protocol_definition.data[0]?.id === currentProtocolId))))  {
    ensureProtocolDefinitionLoaded()
  }

  console.dir(currentProtocolId);
  let protocol = props.protocol_definition.data[0];
  console.log(`Rendering protocol ${currentProtocolId} with ${protocol}`);
  if (protocol && (protocol.id == currentProtocolId)) {
    return (
        <div>
          <ProtocolPreview protocol={protocol} studyId={studyId} protocolId={currentProtocolId}></ProtocolPreview>
        </div>
    )
  }

  return <div>Loading Protocol {currentProtocolId} information</div>
}

ProtocolPreviewContainer.propTypes = {
  protocol_definition: ApiReturnCollectionOf(ProtocolDefinitionType),
  loadProtocolDefinition: PropTypes.func,
};

const mapStateToProps = (state) => ({
  protocol_definition: state.protocol_definition,
});

const mapDispatchToProps = (dispatch) => ({
  loadProtocolDefinition: (study_definition_id, protocol_definition_id) => dispatch(elicitApi.actions.protocol_definition({
    study_definition_id: study_definition_id,
    protocol_definition_id: protocol_definition_id,
  })),
});

export default connect(mapStateToProps, mapDispatchToProps)(ProtocolPreviewContainer)
