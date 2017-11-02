import React from 'react'
import StudyList from './StudyList'
import { connect } from "react-redux"

const StudyManagement = (props) => (
  <div>
    <StudyList {...props} />
  </div>
)

const mapStateToProps = (state) => ({
  studies: state.studies,
  study_definition: state.study_definition,
  protocol_definitions: state.protocol_definitions,
});

export default connect(mapStateToProps)(StudyManagement)