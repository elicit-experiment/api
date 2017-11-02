import React from "react";
import ReactDOM from "react-dom";
import PropTypes from "prop-types";
import InlineEdit from "react-edit-inline";
import update from "react-addons-update";
import Dropdown from "../ui_elements/DropDown";
import { AppRoutes } from "./AdminApp";
import { Link } from "react-router-dom";
import pathToRegexp from "path-to-regexp";
import elicitApi from "../../api/elicit-api.js";
import { connect } from "react-redux";
import $ from "jquery";
import Toggle from "react-bootstrap-toggle";

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

class _Protocol extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      active: props.protocol.active
    };
  }
  componentWillReceiveProps(nextProps) {
    this.setState({ active: nextProps.protocol.active });
  }
  onToggle() {
    this.setState((prevState, props) => {
      const newActive = !prevState.active
      const newData = update(this.props.protocol, {
        active: { $set: newActive }
      });
      this.updateProtocol(newData)
      return { count: newActive }
    })
  }
  updateProtocol(newData) {
    const { dispatch } = this.props;
    let body = { protocol_definition: newData };
    console.dir(body);
    console.dir(elicitApi.actions);
    dispatch(
      elicitApi.actions.protocol_definition.patch({
          study_definition_id: this.props.protocol.study_definition_id,
          id: this.props.protocol.id
         },
        { body: JSON.stringify(body) }
      )
    );
  }
  render() {
    return (
      <div className="row well " key={this.props.protocol.id}>
        <div
          className="protocol-row protocol-header-row"
          key={"t" + this.props.protocol.id}
        >
          <div className="col-xs-1">
            <b>{this.props.protocol.id}</b>
          </div>
          <div className="col-xs-6">
            <b>{this.props.protocol.name}</b>
          </div>
          <div className="col-xs-3">
            <button type="button" className="btn btn-primary">
              Phases &nbsp; <span className="badge badge-secondary">{this.props.protocol.phase_definitions.length}</span>
            </button>
          </div>
          <div className="col-xs-2">
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
          <div className="col-xs-12">{this.props.protocol.description}</div>
        </div>
      </div>
    );
  }
}


const Protocol = connect(state => ({}))(_Protocol);


class ProtocolEdit extends React.Component {
  render() {
    let protocol_list = this.props.study_protocols.map((protocol, i) => {
      // This is a little gross.  Because the protocol_defnitions inside the study definitions
      // don't get updated when we patch the protocol definition, we need to check if there's
      // a protocol_definition in the protocol_definitions state which matches the id, and treat
      // that as authoritative.
      let protocol_def = this.props.protocol_definitions.data.filter( (p) => (p.id == protocol.id) )
      if (protocol_def && (protocol_def.length > 0)) {
        protocol = protocol_def[0]
      }
      return <Protocol protocol={protocol} key={protocol.id} />;
    });

    return (
      <div className="row study-info-row" key={"new-protocol"}>
        <b className="col-xs-2">Protocols:</b>
        <div className="col-xs-10">{protocol_list}</div>
      </div>
    );
  }
}

class Study extends React.Component {
  constructor(props) {
    super(props);
    this.titleChanged = this.titleChanged.bind(this);
    this.deleteStudy = this.deleteItem.bind(this);
    this.state = {
      title: this.props.study.title,
      users: this.props.users,
      studies: this.props.studies
    };
  }

  componentDidUpdate() {
    $('[data-toggle="tooltip"]').tooltip();
  }

  titleChanged(data) {
    const newData = update(this.props.study, {
      title: { $set: data.title }
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
    var protocols_row, study_class;
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
    return (
      <div className="study-wrapper" key={this.props.study.id}>
        <div className={study_class} data-studyId={this.props.study.id}>
          <div className="row study-info-row">
            <b className="col-xs-2">Title:</b>
            <div className="col-xs-5">
              {this.props.study.id} —{" "}
              <InlineEdit
                validate={this.customValidateTitle}
                activeClassName="editing col-xs-5xx"
                className="col-xs-5xx"
                text={this.state.title}
                paramName="title"
                change={this.titleChanged}
                style={{
                  minWidth: 150,
                  display: "inline-block",
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
            <div className="col-xs-5">
              <b>{this.props.study.principal_investigator.email}</b>
            </div>
          </div>
          <div className="row study-info-row">
            <b className="col-xs-2">Description:</b>
            <div className="col-xs-10">
              <b>{this.props.study.description}</b>
            </div>
          </div>
          {protocols_row}
          <button className="remove-study" onClick={this.deleteStudy}>
            {" "}
            &times;{" "}
          </button>
          <div className="row study-info-row">
            <div className="col-xs-2" />
            <div className="col-xs-5">
              <button
                onClick={this.deleteStudy}
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

  deleteItem(itm) {
    console.dir(itm);
    console.dir(this.props.study);
    const { dispatch } = this.props;
    console.dir(elicitApi.actions);
    dispatch(
      elicitApi.actions.study_definition.delete({ id: this.props.study.id })
    );
  }
}

const mapStateToProps = state => ({});

export default connect(mapStateToProps)(Study);
