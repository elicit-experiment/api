import React from 'react'
import ReactDOM from 'react-dom'
import StudyStore from '../store/StudyStore'
import _ from 'lodash'
import InlineEdit from 'react-edit-inline';
import update from 'react-addons-update'
import Study from './Study'

class EditStudy extends React.Component {
  constructor(props) {
    super(props);
    this.titleChanged = this.titleChanged.bind(this)
    this.deleteStudy = this.deleteItem.bind(this)
    this.state = this.buildState(props)
  }

  componentWillReceiveProps(nextProps) {
    let newState = this.buildState(nextProps)
    if (newState.study_id !== this.state.study_id || !this.state.study) {
      this.setState(newState);
    }
  }

  buildState(props) {
    let study_id = props.match.params.study_id
    let study = _.find(props.studies, (study) => study_id == study.id)
    return {
        study_id: study_id,
        study: study
    }
  }

  titleChanged(data) {
      const newData = update(this.props.study, {
        title: {$set: data.title},
      });
      StudyStore.updateItem(newData)
      this.setState({...data})
  }

  validateTitle(text) {
    return (text.length > 0 && text.length < 64);
  }

  dropDownOnChange(x) {
  }

  render() {
    if (this.state.study) {
      return (
        <Study {...this.props} study={this.state.study} />
      )
    } else {
      return (
        <div>
          <h1>Unknown study {this.study_id}</h1>
        </div>
      )
    }
  }

  deleteItem(itm) {
    StudyStore.removeItem(this.state.study.id)
  }
}

export default EditStudy;