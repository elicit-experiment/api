import React from "react";
import update from "react-addons-update";
import elicitApi from "../../../api/elicit-api";
import {Link} from "react-router-dom";
import {CopyToClipboard} from "react-copy-to-clipboard";
import BootstrapSwitchButton from "bootstrap-switch-button-react";
import {ApiReturnCollectionOf, ProtocolDefinitionType, StudyDefinitionType} from "../../../types";
import PropTypes from "prop-types";
import {connect} from "react-redux";

class _Protocol extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      active: props.protocol.active,
    };
  }

  static getDerivedStateFromProps(nextProps, _state) {
    return {active: nextProps.protocol.active};
  }

  onToggle() {
    this.setState((prevState, _props) => {
      const newActive = !prevState.active;
      const newData = update(this.props.protocol, {
        active: {$set: newActive},
      });
      this.props.updateProtocol(this.props.protocol, newData);
      return {count: newActive}
    })
  }

  render() {
    const htmlDescription = {
      dangerouslySetInnerHTML: {__html: this.props.protocol.description},
    };

    return (
      <div className="container card p-4 mb-4 " key={this.props.protocol.id}>
        <div
          className="protocol-row container protocol-header-row"
          key={"t" + this.props.protocol.id}
        >
          <div className="col-4">
            <b>{this.props.protocol.id} —{" "}
              {this.props.protocol.name}</b>
          </div>

        </div>

        <div className="protocol-row row" key={"d" + this.props.protocol.id}>
          <div className="col-12 "><p className="col-12" {...htmlDescription}></p></div>
          <div className="col-12 study-action-bar">
            <Link to={`/admin/studies/${this.props.study.id}/protocols/${this.props.protocol.id}`}
                  className="active btn btn-primary">
              Preview
            </Link>

            <CopyToClipboard
              text={`${window.location.origin}/studies/${this.props.study.id}/protocols/${this.props.protocol.id}`}
              onCopy={() => this.setState({copied: true})}>
              <button type="button" className="btn btn-primary">
                {this.state.copied ? <span style={{color: 'red'}}>Copied.</span> : <span>Get Link</span>}
                &nbsp;
                <i className="fas fa-link" aria-hidden="true"/>
              </button>
            </CopyToClipboard>

            <button type="button" className="btn btn-primary">
              Phases &nbsp; <span
              className="badge badge-secondary">{this.props.protocol.phase_definitions.length}</span>
            </button>
            <BootstrapSwitchButton
              onChange={this.onToggle.bind(this)}
              onlabel='Active'
              offlabel='Inactive'
              size="md"
              offstyle="danger"
              onstyle="success"
              width="100"
              checked={this.state.active}/>
          </div>
        </div>

        {this.props.children && <div className="protocol-row row" >{this.props.children}</div>}
      </div>
    );
  }
}

_Protocol.propTypes = {
  protocol: ProtocolDefinitionType,
  study: StudyDefinitionType,
  updateProtocol: PropTypes.func,
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]),
};

const mapDispatchToProps = (dispatch) => ({
  updateProtocol: (protocol, newData) => dispatch(
    elicitApi.actions.protocol_definition.patch({
        study_definition_id: protocol.study_definition_id,
        id: protocol.id,
      },
      {body: JSON.stringify({protocol_definition: newData})}
    )
  ),
});


export const EditableProtocolCard = connect(_state => ({}), mapDispatchToProps)(_Protocol);

export function EditableProtocolList(props) {
  let protocol_list = props.study_protocols.map((protocol, _i) => {
    // This is a little gross.  Because the protocol_definitions inside the study definitions
    // don't get updated when we patch the protocol definition, we need to check if there's
    // a protocol_definition in the protocol_definitions state which matches the id, and treat
    // that as authoritative.
    let protocol_def = props.protocols.data.filter((p) => (p.id == protocol.id));
    if (protocol_def && (protocol_def.length > 0)) {
      protocol = protocol_def[0]
    }
    return <EditableProtocolCard protocol={protocol} study={props.study} key={protocol.id}/>;
  });

  return (
    <div className="row study-info-row" key={"new-protocol"}>
      <b className="col-2">Protocols:</b>
      <div className="col-10">{protocol_list}</div>
    </div>
  );
}

EditableProtocolList.propTypes = {
  study_protocols: PropTypes.arrayOf(ProtocolDefinitionType),
  protocols: ApiReturnCollectionOf(ProtocolDefinitionType),
  study: StudyDefinitionType,
};
