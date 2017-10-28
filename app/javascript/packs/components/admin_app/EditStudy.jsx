import React from 'react'
import ReactDOM from 'react-dom'
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
    //if (newState.study_id !== this.state.study_id || !this.state.study) {
      this.setState(newState);
    //}
  }

  buildState(props) {
    let study_id = props.match.params.study_id
    let study = _.find(props.studies, (study) => study_id == study.id)
    console.dir(props)
    let study_protocols = props.study_protocols.filter((sp) => sp.study_id !== study_id )
    console.dir(study_protocols)
    return {
        study_id: study_id,
        study: study,
        study_protocols: study_protocols,
        protocols: props.protocols
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
        <div>
          <h1></h1>
          <Study {...this.props} study={this.state.study} study_protocols={this.state.study_protocols} protocols={this.state.protocols} edit_protocols={true} />
        </div>
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