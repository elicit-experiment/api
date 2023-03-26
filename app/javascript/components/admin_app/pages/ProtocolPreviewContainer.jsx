import React from 'react';
import {useState, useEffect} from 'react';
import {useDispatch, useSelector} from "react-redux"
import elicitApi from "../../../api/elicit-api"
import ProtocolPreview from "../components/ProtocolPreview"
import {useParams} from "react-router-dom";
import {ensureSyncableLoaded} from "../../../api/api-helpers";

const ProtocolPreviewContainer = () => {
  const {protocolId, studyId} = useParams()

  const [currentProtocolId] = useState(() => (parseInt(protocolId, 10)))
  const [currentStudyId] = useState(() => (parseInt(studyId, 10)))

  const dispatch = useDispatch();
  const protocolDefinitions = useSelector(state => state.protocol_definition)

  const protocolDefinitionState = ensureSyncableLoaded(protocolDefinitions, (protocolDefinition) => protocolDefinition.id === currentProtocolId);

  useEffect(() => {
    protocolDefinitionState === 'start-load' && dispatch(elicitApi.actions.protocol_definition({study_definition_id: currentStudyId, protocol_definition_id: currentProtocolId}))
  }, [])
  if (protocolDefinitionState === 'start-load' || protocolDefinitionState === 'loading') {
    return (<div><h1>Loading...</h1></div>)
  }
  if (protocolDefinitionState === 'error') {
    return (<div><h1>Error. Try reloading the page.</h1></div>)
  }

  let protocol = protocolDefinitions.data[0];
  console.log(`Rendering protocol ${currentStudyId}.${currentProtocolId} with ${protocol}`);
  return (
    <div>
      <ProtocolPreview protocol={protocol} studyId={studyId} protocolId={currentProtocolId}></ProtocolPreview>
    </div>
  )
}

export default ProtocolPreviewContainer
