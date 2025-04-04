import React from 'react'
import StudyCardList from '../components/StudyCardList'
import { connect } from "react-redux"
import elicitApi from "../../../api/elicit-api";

const StudyManagement = (props) => (
  <div>
    <StudyCardList {...props} />
  </div>
);

const mapStateToProps = (state) => ({
  studies: state.studies,
  study_definition: state.study_definition,
  protocol_definitions: state.protocol_definitions,
});

const mapDispatchToProps = (dispatch) => ({
  loadStudies: () => dispatch(elicitApi.actions.studies()),
  loadCurrentUser: () => dispatch(elicitApi.actions.current_user()),
});

export default connect(mapStateToProps, mapDispatchToProps)(StudyManagement)
