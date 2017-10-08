import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import InlineEdit from 'react-edit-inline'
import update from 'react-addons-update'
import Dropdown from '../DropDown'
import { Link } from 'react-router-dom'
import pathToRegexp from 'path-to-regexp'
import elicitApi from '../../api/elicit-api.js'
import { connect } from "react-redux";
import elicitConfig from '../../ElicitConfig.js'

const TakeStudyLink = (props) => {

  return <div className="row study-info-row">
    <b className="col-xs-2">
      <button onClick={ (e) => {
        props.take_study({id: props.study_id}) } } className="active btn btn-xs ">
          Take Study
      </button>
    </b>
    <div className="col-xs-5">
    </div>
  </div>
}


class ParticipantStudy extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
    var study_class = 'well show study-summary'
    return (
      <div className='study-wrapper' key={this.props.study.id}>
        <div className={study_class} data-studyId={this.props.study.id}>
          <div className="row study-info-row">
            <b className="col-xs-2">Title:</b>
            <div className='col-xs-5'>
              {this.props.study.id} — {this.props.study.title}
            </div>
          </div>
          <div className="row study-info-row">
            <b className="col-xs-2">PI:</b>
            <div className='col-xs-5'>
            <b>{this.props.study.principal_investigator.email}</b>
            </div>
          </div>
          <div className="row study-info-row">
            <TakeStudyLink study_id={this.props.study.id} take_study={this.props.take_study}/>
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => ({
});
const mapDispatchToProps = (dispatch) => ({
    take_study: (x) => { dispatch(elicitApi.actions.take_study(x)) }
});

export default connect(mapStateToProps, mapDispatchToProps)(ParticipantStudy);

