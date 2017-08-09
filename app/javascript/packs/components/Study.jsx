import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import InlineEdit from 'react-edit-inline'
import update from 'react-addons-update'
import Dropdown from './DropDown'
import ProtocolStore from '../store/ProtocolStore'
import StudyProtocolsStore from '../store/StudyProtocolsStore'
import StudyStore from '../store/StudyStore'
import { AppRoutes } from './AdminApp'
import { Link } from 'react-router-dom'
import pathToRegexp from 'path-to-regexp'


const ProtocolInfoLink = (props) => (
  <div className="row study-info-row">
    <b className="col-xs-2">Protocols:</b>
    <div className="col-xs-2">
      <Link to={ `/admin/studies/${props.study.id}` } className="active">
          <i className="glyphicon glyphicon-edit" aria-hidden="true"></i> Edit
      </Link>
    </div>
    <b className="col-xs-1 study-info-protocols-count">0</b>
  </div>
)


const NewProtocol = (props) => (
    <div className='well glyphicon glyphicon-plus' onClick={(e) => {
      StudyProtocolsStore.newItem({ study_id: props.study.id })
    }
  }></div>
)


const ProtocolEdit = (props) => {

  console.dir(props)
  let protocols = props.study_protocols.map( (sp, i) => {
    return (
            <div key={i}>{sp.study_id} x {sp.protocol_id}</div>
    )
  })

  return (  
  <div className="row study-info-row">
    <b className="col-xs-2">Protocols:</b>
    <div className="col-xs-8">
    {protocols}
    <NewProtocol {...props} />
    </div>
  </div>
)
}


class Study extends React.Component {
  constructor(props){
    super(props);
    this.titleChanged = this.titleChanged.bind(this)
    this.deleteStudy = this.deleteItem.bind(this)
    this.state = {
        title: this.props.study.title,
        users: this.props.users,
        studies: this.props.studies
    }
    console.dir(props)
  }

  titleChanged(data) {
      const newData = update(this.props.study, {
        title: {$set: data.title},
      });
      StudyStore.updateItem(newData)
      console.log(data)
      this.setState({...data})
  }

  validateTitle(text) {
    return (text.length > 0 && text.length < 64);
  }

  dropDownOnChange(x) {
    console.log(x)
  }

  render() {
    var protocols_row, study_class;
    console.log(this.props)
    if (this.props.edit_protocols) {
      protocols_row = <ProtocolEdit study={this.props.study} study_protocols={this.props.study_protocols} />
      study_class = 'well show study-detail'
    } else {
      protocols_row = <ProtocolInfoLink study={this.props.study} />
      study_class = 'well show study-summary'
    }
    return (
      <div className='study-wrapper' key={this.props.study.id}>
        <div className={study_class} data-studyId={this.props.study.id}>
          <div className="row study-info-row">
            <b className="col-xs-2">Title:</b>
            <div className='col-xs-5'>
              <InlineEdit
                validate={this.customValidateTitle}
                activeClassName="editing col-xs-5"
                className='col-xs-5'
                text={this.state.title}
                paramName="title"
                change={this.titleChanged}
                style={{
                  minWidth: 150,
                  display: 'inline-block',
                  margin: 0,
                  padding: 0,
                  fontSize: 15,
                  outline: 0,
                  border: 0
                }}
              />
            </div>
          </div>
          <div className="row study-info-row">
            <b className="col-xs-2">PI:</b>
            <div className='col-xs-5'>
            <Dropdown id='userDropDown'
                  options={this.props.users} 
                  value='this.props.study.principal_investigator_user_id'
                  labelField='name'
                  valueField='id'
                  onChange={this.dropDownOnChange}/>
            </div>
          </div>
          {protocols_row}
          <button className='remove-study' onClick={this.deleteStudy}> &times; </button>
        </div>
      </div>
    )
  }

  deleteItem(itm) {
    StudyStore.removeItem(this.props.study.id)
  }
}

export default Study;

