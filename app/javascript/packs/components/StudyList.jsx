import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import TransitionGroup from 'react-transition-group/TransitionGroup'
import Transition from 'react-transition-group/Transition';
import CSSTransition from 'react-transition-group/CSSTransition';
import InlineEdit from 'react-edit-inline';
import update from 'react-addons-update'
import Dropdown from './DropDown'
import Study from './Study'
import StudyStore from '../store/StudyStore'
import { AppRoutes } from './AdminApp'
import { Link } from 'react-router-dom'
import pathToRegexp from 'path-to-regexp'

const Fade = ({ children, ...props }) => (
 <CSSTransition
   {...props}
   timeout={500}
   classNames="fade"
 >
  {children}
 </CSSTransition>
);

const NewStudy = props => (
    <div className='well new-study well show study-summary' onClick={(e) => {
      StudyStore.newItem({title: "New Study", principal_investigator_user_id: 1})
    }
  }>+</div>
)

class StudyList extends React.Component {
  render() {
    if (!this.props.studies) {
      return (<div><h1>Loading...</h1></div>)
    }
    var studies = this.props.studies.map( (study, i) => {
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

