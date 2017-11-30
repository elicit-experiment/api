import React from 'react'
import {connect} from "react-redux"
import elicitApi from "../../api/elicit-api"
import ProtocolPreview from "./ProtocolPreview"

class ProtocolPreviewContainer extends React.Component {
  render() {
    let protocol_id = parseInt(this.props.match.params.protocol_id)
    let protocol_def = this.props.protocol_definition.data.filter((p) => (p.id == protocol_id))
    let protocol_info = ""
    if (protocol_def && (protocol_def.length > 0)) {
      let protocol = protocol_def[0]
      protocol_info = <ProtocolPreview protocol={protocol} match={this.props.match}></ProtocolPreview>
      return (
          <div>
            {protocol_info}
          </div>
      )
    }
    return <div></div>
  }

  componentDidMount() {
    if ((!this.props.protocol_definition.sync && !this.props.protocol_definition.loading) ||
        (this.props.protocol_definition.data[0].id == this.props.match.params.protocol_id)) {
      this.props.loadProtocolDefinition(this.props.match.params.study_id,
                                        this.props.match.params.protocol_id)
    }
  }
}


const mapStateToProps = (state) => ({
  protocol_definition: state.protocol_definition,
});

const mapDispatchToProps = (dispatch) => ({
  loadProtocolDefinition: (study_definition_id, protocol_definition_id) => dispatch(elicitApi.actions.protocol_definition({
    study_definition_id: study_definition_id,
    protocol_definition_id: protocol_definition_id
  })),
});

export default connect(mapStateToProps, mapDispatchToProps)(ProtocolPreviewContainer)