import React from 'react'
import ReactDOM from 'react-dom'
import { Provider, connect } from "react-redux";
import PropTypes from 'prop-types'
import TransitionGroup from 'react-transition-group/TransitionGroup'
import Transition from 'react-transition-group/Transition';
import CSSTransition from 'react-transition-group/CSSTransition';
import InlineEdit from 'react-edit-inline';
import update from 'react-addons-update'
import Dropdown from './DropDown'
import Study from './Study'
import { AppRoutes } from './AdminApp'
import { Link } from 'react-router-dom'
import pathToRegexp from 'path-to-regexp'
import elicitApi from "../api/elicit-api.js"; 

const Fade = ({ children, ...props }) => (
 <CSSTransition
   {...props}
   timeout={500}
   classNames="fade"
 >
  {children}
 </CSSTransition>
);

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


class StudyList extends React.Component {
  render() {
    if (!this.props.studies || !this.props.studies.data) {
      return (<div><h1>Loading...</h1></div>)
    }
    var studies = this.props.studies.data.map( (study, i) => {
      return(
        <Fade key={study.id} appear={true} >
        <div>
        <Study study={study} users={this.props.users} study_protocols={this.props.study_protocols} key={study.id}> </Study>
        </div>
        </Fade>
      )
    })

    return(
    <div>
      <h1>{studies.length} Studies</h1>
      <TransitionGroup>
        {studies}
      </TransitionGroup>
      <NewStudy></NewStudy>
    </div>)
  }
}

export default StudyList;

