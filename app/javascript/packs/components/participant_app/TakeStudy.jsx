import React from 'react'
import { connect } from "react-redux"

class _TakeStudy extends React.Component {
  constructor(props){
    super(props);
  }
  render() {
    const {dispatch} = this.props;
    const new_study_def = {study_definition: { title: "New Study", principal_investigator_user_id: 0 } }
    console.dir(new_study_def)
   return (
    <div className='well new-study well show study-summary'>take</div>
  )
  }
}

const TakeStudy = connect((state) => ({ }))(_TakeStudy)
