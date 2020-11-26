import React, {useEffect} from 'react'
import PropTypes from 'prop-types';
import {connect} from "react-redux"
import elicitApi from "../../../api/elicit-api"
import EditStudyPanel from "../components/EditStudyPanel"
import {ApiReturnCollectionOf, MatchType, StudyDefinitionType} from '../../../types';

const ensureSyncableLoaded = (syncable, expectedDatum, load) => {
  if (syncable.loading) return 'loading';
  if (syncable.error) return 'error';
  if (!syncable.sync) {
    console.log('sync1');
    load();
    return 'loading';
  }
  if (syncable.sync && (!syncable.data.map((d) => expectedDatum(d)).reduce((a,b)  => a&&b, true))) {
    console.log('sync2');
    load();
    return 'loading';
  }
  return 'loaded';
}

function EditStudyContainer(props) {
  const {match} = props;
  const studyId = parseInt(match.params.study_id);

  const studyDefinitionState = ensureSyncableLoaded(props.study_definition,
    (studyDefinition) => studyDefinition.id === studyId,
    () => useEffect(() => { props.loadStudyDefinition(studyId); return undefined; }));

  if (studyDefinitionState !== 'loaded') {
    return <div>Loading Study Information</div>
  }

  let studyDefinition = props.study_definition.data[0];
  return (
     <EditStudyPanel study={studyDefinition} match={match}></EditStudyPanel>
  )
}

EditStudyContainer.propTypes = {
  study_definition: ApiReturnCollectionOf(StudyDefinitionType),
  loadStudyDefinition: PropTypes.func,
  loadProtocolDefinitions: PropTypes.func,
  match: MatchType,
};

const mapStateToProps = (state) => ({
  study_definition: state.study_definition,
});

const mapDispatchToProps = (dispatch) => ({
  loadStudyDefinition: (id) => dispatch(elicitApi.actions.study_definition({ id })),
  deleteStudyById: (id) => dispatch(elicitApi.actions.study_definition.delete({ id })),
  updateStudyDefinition: (id, newData) =>
    dispatch(
      elicitApi.actions.study_definition.patch(
        { id },
        { body: JSON.stringify({ study_definition: newData }) }
      )
    ),
});

export default connect(mapStateToProps, mapDispatchToProps)(EditStudyContainer)
