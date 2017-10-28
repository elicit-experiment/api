import React from 'react'
import StudyList from './StudyList'
import { connect } from "react-redux"

class _NewStudy extends React.Component {
  constructor(props){
    super(props);
  }
  render() {
    const {dispatch} = this.props;
    const new_study_def = {study_definition: { title: "New Study", principal_investigator_user_id: 0 } }
    console.dir(new_study_def)
   return (
    <div className='well new-study well show study-summary' onClick={(e) => {
        dispatch(elicitApi.actions.study_definition.post({}, { body: JSON.stringify(new_study_def) } ));
    }
  }>+</div>
  )
  }
}

const NewStudy = connect((state) => ({ }))(_NewStudy)

const StudyManagement = (props) => (
  <div>
    <StudyList {...props} />
    <NewStudy {...props} ></NewStudy>
  </div>
)

export default StudyManagement