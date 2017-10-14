import React from 'react'
import ReactDOM from 'react-dom'
import { Provider, connect } from "react-redux";
import PropTypes from 'prop-types'
import { Fade } from '../effects/Fade'
import TransitionGroup from 'react-transition-group/TransitionGroup'
import InlineEdit from 'react-edit-inline';
import update from 'react-addons-update'
import Dropdown from '../DropDown'
import Study from './ParticipantStudy'
import { Link } from 'react-router-dom'
import pathToRegexp from 'path-to-regexp'
import elicitApi from "../../api/elicit-api.js"; 


class ParticipantStudyList extends React.Component {
  render() {
    if (!this.props.studies || !this.props.studies.data) {
      return (<div><h1>Loading...</h1></div>)
    }
    var studies = this.props.studies.data.map( (study, i) => {
      return(
        <Fade key={study.id} appear={true} >
        <div>
        <Study study={study} users={this.props.users} key={study.id}> </Study>
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
    </div>)
  }
}

export default ParticipantStudyList;

