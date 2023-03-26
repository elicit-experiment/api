import React, {useEffect} from 'react'
import PropTypes from 'prop-types';
import {connect, useDispatch, useSelector} from "react-redux"
import elicitApi from "../../../api/elicit-api"
import EditStudyPanel from "../components/EditStudyPanel"
import {ApiReturnCollectionOf, StudyDefinitionType} from '../../../types';
import {ensureSyncableLoaded} from "../../../api/api-helpers";
import {useMatch} from "react-router-dom";



function EditStudyContainer() {
  const editPageUrl = `admin/studies/:study_id/edit`;
  const editPageMatch = useMatch(editPageUrl);

  const studyId = parseInt(editPageMatch?.params?.study_id, 10)

  const dispatch = useDispatch();
  const studyDefinition = useSelector(state => state.study_definition)

  const studyDefinitionState = ensureSyncableLoaded(studyDefinition, (studyDefinition) => studyDefinition.id === studyId);

  useEffect(() => {
    studyDefinitionState === 'start-load' && dispatch(elicitApi.actions.study_definition({ id: studyId }))
  }, [])
  if (studyDefinitionState === 'start-load' || studyDefinitionState === 'loading') {
    return (<div><h1>Loading...</h1></div>)
  }
  if (studyDefinitionState === 'error') {
    return (<div><h1>Error. Try reloading the page.</h1></div>)
  }

  return (
     <EditStudyPanel study={studyDefinition.data[0]}></EditStudyPanel>
  )
}

EditStudyContainer.propTypes = {
  study_definition: ApiReturnCollectionOf(StudyDefinitionType),
};

export default EditStudyContainer
