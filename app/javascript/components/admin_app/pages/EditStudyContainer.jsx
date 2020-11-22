import React from 'react'
import PropTypes from 'prop-types';
import {connect} from "react-redux"
import elicitApi from "../../../api/elicit-api"
import EditStudy from "../components/EditStudyCard"
import {ApiReturnValueOf, StudyDefinitionType, ProtocolDefinitionType, MatchType} from '../../../types';

class EditStudyContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      study_id: parseInt(this.props.match.params.study_id),
    }
  }
  render() {
    let studyDefinition = this.props.study_definition.data[0];
    let protocolDefinition = this.props.protocol_definition;
    if (studyDefinition && (studyDefinition.id == this.state.study_id)) {
      return (
        <EditStudy study={studyDefinition} protocols={protocolDefinition} match={this.props.match}></EditStudy>
      )
    }

    return <div>Loading Study {this.state.study_id} information</div>
  }

  ensureStudyDefinitionLoaded() {
    if ((!this.props.study_definition.sync && !this.props.study_definition.loading) ||
        (this.props.study_definition.data[0].id !== this.state.study_id)) {
      this.props.loadStudyDefinition(this.props.match.params.study_id,
          this.props.match.params.study_id)
    }
  }

  ensureProtocolDefinitionLoaded() {
    if ((!this.props.protocol_definition.sync && !this.props.protocol_definition.loading) ||
      (this.props.protocol_definition.data[0].id !== this.state.protocol_id)) {
      this.props.loadProtocolDefinition(this.props.match.params.study_id,
        this.props.match.params.protocol_id)
    }
  }

  componentDidMount() {
    this.ensureStudyDefinitionLoaded();
    this.ensureProtocolDefinitionLoaded();
  }
}

EditStudyContainer.propTypes = {
  study_definition: ApiReturnValueOf(StudyDefinitionType),
  protocol_definition: ApiReturnValueOf(ProtocolDefinitionType),
  loadStudyDefinition: PropTypes.func,
  loadProtocolDefinition: PropTypes.func,
  match: MatchType,
};

const mapStateToProps = (state) => ({
  study_definition: state.study_definition,
  protocol_definition: state.protocol_definition,
});

const mapDispatchToProps = (dispatch) => ({
  loadProtocolDefinition: (study_definition_id, protocol_definition_id) => dispatch(elicitApi.actions.protocol_definition({
    study_definition_id: study_definition_id,
    protocol_definition_id: protocol_definition_id,
  })),
  loadStudyDefinition: (study_definition_id) => dispatch(elicitApi.actions.study_definition({
    study_definition_id: study_definition_id,
  })),
});

export default connect(mapStateToProps, mapDispatchToProps)(EditStudyContainer)
