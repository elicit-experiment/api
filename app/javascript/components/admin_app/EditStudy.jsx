import React from 'react'
import update from 'react-addons-update'
import PropTypes from "prop-types";
import Study from './Study'
import {
  MatchType,
  StudyDefinitionType,
  ProtocolDefinitionType,
  ApiReturnCollectionOf,
} from "../../types";
import elicitApi from "../../api/elicit-api";
import {connect} from "react-redux";

class EditStudy extends React.Component {
  constructor(props) {
    super(props);
    this.titleChanged = this.titleChanged.bind(this);
    this.deleteStudy = this.deleteItem.bind(this);
    this.state = this.buildState(props);
  }

  buildState(props) {
    let studyId = props.match.params.studyId;
    let study = this.props.study;
    let studyProtocols = props.study.protocol_definitions;
    return {
        studyId: studyId,
        study: study,
        studyProtocols: studyProtocols,
        protocols: props.protocols,
    }
  }

  titleChanged(data) {
      const newData = update(this.props.study, {
        title: {$set: data.title},
      });
      this.props.updateStudyDefinition(this.props.study.id, newData);
      this.setState({...data});
  }

  validateTitle(text) {
    return (text.length > 0 && text.length < 64);
  }

  dropDownOnChange(_x) {
  }

  render() {

    console.log(this.props.protocols)
    if (this.state.study) {
      return (
        <div>
          <h1></h1>
          <Study {...this.props} study={this.state.study} studyProtocols={this.state.studyProtocols} protocols={this.props.protocols} edit_protocols={true} />
        </div>
      )
    } else {
      return (
        <div>
          <h1>Unknown study {this.studyId}</h1>
        </div>
      )
    }
  }

  deleteItem(/*itm*/) {
    this.props.deleteStudyById(this.state.study.id);
  }
}

const mapStateToProps = _state => ({});

const mapDispatchToProps = (dispatch) => ({
  deleteStudyById: (id) => dispatch(elicitApi.actions.study_definition.delete({ id })),
  updateStudyDefinition: (id, newData) =>
    dispatch(
      elicitApi.actions.study_definition.patch(
        { id },
        { body: JSON.stringify({ study_definition: newData }) }
      )
    ),
});

export default connect(mapStateToProps, mapDispatchToProps)(EditStudy);

EditStudy.propTypes = {
  match: MatchType,
  protocols: ApiReturnCollectionOf(ProtocolDefinitionType).isRequired,
  study: StudyDefinitionType.isRequired,
  deleteStudyById: PropTypes.func,
  updateStudyDefinition: PropTypes.func,
}
