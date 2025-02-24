import React, { useState } from 'react'
import update from 'react-addons-update'
import Study from './StudyCard'
import {
  MatchType,
  StudyDefinitionType,
  ProtocolDefinitionType,
  ApiReturnCollectionOf,
} from "../../../types";
import elicitApi from "../../../api/elicit-api";
import { useDispatch } from "react-redux";

const EditStudyCard = ({ match, study, protocols }) => {
  const dispatch = useDispatch();
  
  const [studyData, setStudyData] = useState({
    studyId: match.params.studyId,
    study: study,
    studyProtocols: study.protocol_definitions,
    protocols: protocols,
  });

  const titleChanged = (data) => {
    const newData = update(study, {
      title: {$set: data.title},
    });
    dispatch(
      elicitApi.actions.study_definition.patch(
        { id: study.id },
        { body: JSON.stringify({ study_definition: newData }) }
      )
    );
    setStudyData(prev => ({...prev, ...data}));
  };

  const validateTitle = (text) => {
    return (text.length > 0 && text.length < 64);
  };

  const deleteItem = () => {
    dispatch(elicitApi.actions.study_definition.delete({ id: studyData.study.id }));
  };

  if (studyData.study) {
    return (
      <div>
        <h1></h1>
        <Study 
          match={match}
          study={studyData.study}
          studyProtocols={studyData.studyProtocols}
          protocols={protocols}
          edit_protocols={true}
        />
      </div>
    );
  }

  return (
    <div>
      <h1>Unknown study {studyData.studyId}</h1>
    </div>
  );
};

EditStudyCard.propTypes = {
  match: MatchType,
  protocols: ApiReturnCollectionOf(ProtocolDefinitionType).isRequired,
  study: StudyDefinitionType.isRequired,
};

export default EditStudyCard;
