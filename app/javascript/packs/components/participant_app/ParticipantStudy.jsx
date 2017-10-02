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


const TakeStudyLink = (props) => (
  <div className="row study-info-row">
    <b className="col-xs-2"></b>
    <div className="col-xs-2">
      <i className="glyphicon glyphicon-edit" aria-hidden="true"></i> 
      <a href={ `http://localhost:8080/#Experiment/${props.study.id}` } className="active">
          Take Study
      </a>
    </div>
  </div>
)


class ParticipantStudy extends React.Component {
  constructor(props){
    super(props);
    this.state = {
        title: this.props.study.title,
        users: this.props.users
    }
  }


  render() {
    var study_class = 'well show study-summary'
    return (
      <div className='study-wrapper' key={this.props.study.id}>
        <div className={study_class} data-studyId={this.props.study.id}>
          <div className="row study-info-row">
            <b className="col-xs-2">Title:</b>
            <div className='col-xs-5'>
              {this.state.title}
            </div>
          </div>
          <div className="row study-info-row">
            <b className="col-xs-2">PI:</b>
            <div className='col-xs-5'>
            <Dropdown id='userDropDown'
                  options={this.props.users || []} 
                  value='this.props.study.principal_investigator_user_id'
                  labelField='name'
                  valueField='id'
                  onChange={this.dropDownOnChange}/>
            </div>
          </div>
          <div className="row study-info-row">
            <TakeStudyLink study={this.props.study}/>
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => ({
});

export default connect(mapStateToProps)(ParticipantStudy);

