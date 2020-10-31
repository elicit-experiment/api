import React from 'react'
import PropTypes from 'prop-types';
import {connect} from "react-redux"
import elicitApi from "../../api/elicit-api"
import ProtocolPreview from "./ProtocolPreview"
import {ApiReturnValueOf, ProtocolDefinitionType, MatchType} from '../../types';

class ProtocolPreviewContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      protocol_id: parseInt(this.props.match.params.protocol_id),
    }
  }
  render() {
    let protocol = this.props.protocol_definition.data[0];
    console.log(`Rendering protocol ${this.state.protocol_id} with ${protocol}`);
    if (protocol && (protocol.id == this.state.protocol_id)) {
      const protocol_info = <ProtocolPreview protocol={protocol} match={this.props.match}></ProtocolPreview>;
      return (
          <div>
            {protocol_info}
          </div>
      )
    }

    return <div>Loading Protocol {this.state.protocol_id} information</div>
  }

  ensureProtocolDefinitionLoaded() {
    if ((!this.props.protocol_definition.sync && !this.props.protocol_definition.loading) ||
        (this.props.protocol_definition.data[0].id !== this.state.protocol_id)) {
      this.props.loadProtocolDefinition(this.props.match.params.study_id,
          this.props.match.params.protocol_id)
    }
  }

  componentDidMount() {
    this.ensureProtocolDefinitionLoaded()
  }
}

ProtocolPreviewContainer.propTypes = {
  protocol_definition: ApiReturnValueOf(ProtocolDefinitionType),
  loadProtocolDefinition: PropTypes.func,
  match: MatchType,
};

const mapStateToProps = (state) => ({
  protocol_definition: state.protocol_definition,
});

const mapDispatchToProps = (dispatch) => ({
  loadProtocolDefinition: (study_definition_id, protocol_definition_id) => dispatch(elicitApi.actions.protocol_definition({
    study_definition_id: study_definition_id,
    protocol_definition_id: protocol_definition_id,
  })),
});

export default connect(mapStateToProps, mapDispatchToProps)(ProtocolPreviewContainer)
