import React from "react";
import PropTypes from "prop-types";
import update from "react-addons-update";
import { AppRoutes } from "./AdminApp";
import { Link } from "react-router-dom";
import elicitApi from "../../api/elicit-api.js";
import { connect } from "react-redux";
import $ from "jquery";
import Toggle from "react-bootstrap-toggle";
import {StudyDefinitionType, ProtocolDefinitionType, ApiReturnCollectionOf} from '../../types';
import {CopyToClipboard} from 'react-copy-to-clipboard';
import SweetAlert from 'sweetalert2-react';

const ProtocolInfoLink = props => (
  <div className="row study-info-row">
    <b className="col-xs-2">Protocols:</b>
    <div className="col-xs-2">
      <Link to={`/admin/studies/${props.study.id}`} className="active">
        <i className="glyphicon glyphicon-edit" aria-hidden="true" /> Edit
      </Link>
    </div>
    <b className="col-xs-1 study-info-protocols-count">
      {(props.protocols || []).length}
    </b>
  </div>
);

ProtocolInfoLink.propTypes = {
  protocols: PropTypes.arrayOf(ProtocolDefinitionType),
  study: StudyDefinitionType,
};

class _Protocol extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      active: props.protocol.active,
    };
  }
  componentWillReceiveProps(nextProps) {
    this.setState({ active: nextProps.protocol.active });
  }
  onToggle() {
    this.setState((prevState, props) => {
      const newActive = !prevState.active;
      const newData = update(this.props.protocol, {
        active: { $set: newActive },
      });
      this.updateProtocol(newData);
      return { count: newActive }
    })
  }
  updateProtocol(newData) {
    const { dispatch } = this.props;
    let body = { protocol_definition: newData };
    dispatch(
      elicitApi.actions.protocol_definition.patch({
          study_definition_id: this.props.protocol.study_definition_id,
          id: this.props.protocol.id,
         },
        { body: JSON.stringify(body) }
      )
    );
  }
  render() {
      const htmlDescription = {
          dangerouslySetInnerHTML: { __html: this.props.protocol.description },
      };

    return (
      <div className="row well " key={this.props.protocol.id}>
        <div
          className="protocol-row protocol-header-row"
          key={"t" + this.props.protocol.id}
        >
          <div className="col-xs-6">
            <b>{this.props.protocol.id}  —{" "}
            {this.props.protocol.name}</b>
          </div>
          <div className="col-xs-6 study-action-bar">
            <Link to={`/admin/studies/${this.props.study.id}/protocols/${this.props.protocol.id}`} className="active btn btn-primary">
              Preview
            </Link>
            <CopyToClipboard text={`${window.location.origin}/studies/${this.props.study.id}/protocols/${this.props.protocol.id}`}
                             onCopy={() => this.setState({copied: true})}>
              <button type="button" className="btn btn-primary">
                {this.state.copied ? <span style={{color: 'red'}}>Copied.</span> : <span>Get Link</span>}
                &nbsp;
                <i className="glyphicon glyphicon-link" aria-hidden="true" />
              </button>
            </CopyToClipboard>

            <button type="button" className="btn btn-primary">
              Phases &nbsp; <span className="badge badge-secondary">{this.props.protocol.phase_definitions.length}</span>
            </button>
            <Toggle
              onClick={this.onToggle.bind(this)}
              on={<span>Active</span>}
              off={<span>Inactive</span>}
              size="md"
              offstyle="danger"
              onstyle="success"
              active={this.state.active}
            />
          </div>
        </div>

        <div className="protocol-row " key={"d" + this.props.protocol.id}>
          <div className="col-xs-12" {...htmlDescription}></div>
        </div>
      </div>
    );
  }
}

_Protocol.propTypes = {
  protocol: ProtocolDefinitionType,
  study: StudyDefinitionType,
};

const Protocol = connect(state => ({}))(_Protocol);


class ProtocolEdit extends React.Component {
  render() {
    let protocol_list = this.props.study_protocols.map((protocol, i) => {
      // This is a little gross.  Because the protocol_defnitions inside the study definitions
      // don't get updated when we patch the protocol definition, we need to check if there's
      // a protocol_definition in the protocol_definitions state which matches the id, and treat
      // that as authoritative.
      let protocol_def = this.props.protocol_definitions.data.filter( (p) => (p.id == protocol.id) );
      if (protocol_def && (protocol_def.length > 0)) {
        protocol = protocol_def[0]
      }
      return <Protocol protocol={protocol} study={this.props.study} key={protocol.id} />;
    });

    return (
      <div className="row study-info-row" key={"new-protocol"}>
        <b className="col-xs-2">Protocols:</b>
        <div className="col-xs-10">{protocol_list}</div>
      </div>
    );
  }
}

ProtocolEdit.propTypes = {
  study_protocols: PropTypes.arrayOf(ProtocolDefinitionType),
  protocol_definitions: ApiReturnCollectionOf(ProtocolDefinitionType),
  study: StudyDefinitionType,
};


class Study extends React.Component {
  constructor(props) {
    super(props);
    this.titleChanged = this.titleChanged.bind(this);
    this.state = {
      title: this.props.study.title,
      deleteVerify: false,
    };
  }

  componentDidUpdate() {
    $('[data-toggle="tooltip"]').tooltip();
  }

  titleChanged(data) {
    const newData = update(this.props.study, {
      title: { $set: data.title },
    });
    const { dispatch } = this.props;
    let body = { study_definition: newData };
    dispatch(
      elicitApi.actions.study_definition.patch(
        { id: this.props.study.id },
        { body: JSON.stringify(body) }
      )
    );
    this.setState({ ...data });
  }

  validateTitle(text) {
    return text.length > 0 && text.length < 64;
  }

  dropDownOnChange(x) {}

  render() {
    let protocols_row, study_class;
    if (true || this.props.edit_protocols) {
      protocols_row = (
        <ProtocolEdit
          study={this.props.study}
          study_protocols={this.props.study.protocol_definitions}
          protocol_definitions={this.props.protocol_definitions}
        />
      );
      study_class = "well show study-detail";
    } else {
      protocols_row = (
        <ProtocolInfoLink
          study={this.props.study}
          study_protocols={this.props.study.protocol_definitions}
          protocol_definitions={this.props.protocol_definitions}
        />
      );
      study_class = "well show study-summary";
    }

    // TODO: style sweetalert or replace it with a bootstrap modal doing the same thing
    // (and maybe using the same interface)
    const deleteAlert = <SweetAlert
        show={this.state.deleteVerify}
        title="Really delete?"
        text="Are you sure you want to delete this study and all its results?"
        type='warning'
        buttonsStyling={false}
        confirmButtonClass='btn btn-primary btn-lg'
        cancelButtonClass='btn btn-lg'
        showCancelButton={true}
        confirmButtonText="Yes, delete it!"
        onConfirm={() => {
          this.setState({ deleteVerify: false });
          this.deleteStudy();
        }}
    />

    return (
      <div className="study-wrapper" key={this.props.study.id}>
        {deleteAlert}
        <div className={study_class} data-studyid={this.props.study.id}>
          <div className="row study-info-row">
            <b className="col-xs-2">Title:</b>
            <div className="col-xs-5">
              {this.props.study.id} — {this.props.study.title}

            </div>
          </div>
          <div className="row study-info-row">
            <b className="col-xs-2">PI:</b>
            <div className="col-xs-5">
              <b>{this.props.study.principal_investigator.email}</b>
            </div>
          </div>
          <div className="row study-info-row">
            <b className="col-xs-2">Description:</b>
            <div className="col-xs-10">
              {this.props.study.description}
            </div>
          </div>
          {protocols_row}
          <button className="remove-study" onClick={() => this.setState({ deleteVerify: true })}>
            {" "}
            &times;{" "}
          </button>
          <div className="row study-info-row">
            <div className="col-xs-2" />
            <div className="col-xs-5">
              <button
                onClick={() => this.setState({ deleteVerify: true })}
                className="active btn btn-danger"
              >
                Delete Study
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  deleteStudy() {
    const { dispatch } = this.props;
    dispatch(
      elicitApi.actions.study_definition.delete({ id: this.props.study.id })
    );
  }
}

Study.propTypes = {
  protocol_definitions: ApiReturnCollectionOf(ProtocolDefinitionType),
  study: StudyDefinitionType,
  edit_protocols: PropTypes.bool,
};

Study.defaultProps = {
  edit_protocols: false,
};

const mapStateToProps = state => ({});

export default connect(mapStateToProps)(Study);
