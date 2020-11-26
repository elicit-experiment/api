import React from "react";
import PropTypes from "prop-types";
import update from "react-addons-update";
import elicitApi from "../../../api/elicit-api.js";
import {connect} from "react-redux";
import BootstrapSwitchButton from 'bootstrap-switch-button-react'
import {ApiReturnCollectionOf, ProtocolDefinitionType, StudyDefinitionType} from '../../../types';
import SweetAlert from 'sweetalert2-react';
import {ProtocolInfoLink} from "./ProtocolInfoLink";
import {EditableProtocolList} from "./ProtocolDetailCard";
import {Link} from "react-router-dom";

class StudyCard extends React.Component {
  constructor(props) {
    super(props);
    this.titleChanged = this.titleChanged.bind(this);
    this.state = {
      title: this.props.study.title,
      deleteVerify: false,
    };
  }

  titleChanged(data) {
    const newData = update(this.props.study, {
      title: { $set: data.title },
    });
    this.props.updateStudyDefinition(this.props.study.id, newData);
    this.setState({ ...data });
  }

  validateTitle(text) {
    return text.length > 0 && text.length < 64;
  }

  dropDownOnChange(_x) {}

  onToggle() {
    const newValue = !this.props.study.allow_anonymous_users;
    this.props.updateStudyDefinition(this.props.study.id, {
      allow_anonymous_users: newValue,
    });
  }

  render() {
    let protocols_row, study_class;

    if (this.props.editProtocols) {
      protocols_row = (
        <EditableProtocolList
          study={this.props.study}
          study_protocols={this.props.study.protocol_definitions}
          protocols={this.props.protocols}
        />
      );
      study_class = "card show study-detail my-4";
    } else {
      protocols_row = (
        <ProtocolInfoLink
          study={this.props.study}
          study_protocols={this.props.study.protocol_definitions}
          protocol_definitions={this.props.protocols}
        />
      );
      study_class = "card show study-summary my-4";
    }

    // TODO: style sweetalert or replace it with a bootstrap modal doing the same thing
    // (and maybe using the same interface?)
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
          <div className="container">
            <div className="row study-info-row">
              <b className="col-2">Title:</b>
              <div className="col-5">
                {this.props.study.id} — {this.props.study.title}

              </div>
            </div>
            <div className="row study-info-row">
              <b className="col-2">PI:</b>
              <div className="col-5">
                <b>{this.props.study.principal_investigator.email}</b>
              </div>
            </div>
            <div className="row study-info-row">
              <b className="col-2">Description:</b>
              <div className="col-10">
                {this.props.study.description}
              </div>
            </div>
            {protocols_row}
            <button className="btn btn-danger remove-study" onClick={() => this.setState({ deleteVerify: true })}>
              {" "}
              &times;{" "}
            </button>
            <div className="row study-info-row">
              <div className="col-2" />

              <div className="col-8">
                <Link to={`/admin/studies/${this.props.study.id}/edit`} className="mr-4">
                  <div className="fas fa-edit" style={{width:'1em'}} aria-hidden="true"/> Edit
                </Link>

                <BootstrapSwitchButton
                  onlabel='Allow Anonymous Access'
                  offlabel='Registered Users Only'
                  size="md"
                  offstyle="danger"
                  onstyle="success"
                  width="240"
                  checked={this.props.study.allow_anonymous_users}
                  onChange={this.onToggle.bind(this)}
                />
                <button
                  onClick={() => this.setState({ deleteVerify: true })}
                  className="active btn btn-danger ml-2"
                >
                  Delete Study
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  deleteStudy() {
    this.props.deleteStudyById(this.props.study.id);
  }
}

StudyCard.propTypes = {
  protocols: ApiReturnCollectionOf(ProtocolDefinitionType),
  study: StudyDefinitionType,
  editProtocols: PropTypes.bool,
  deleteStudyById: PropTypes.func,
  updateStudyDefinition: PropTypes.func,
};

StudyCard.defaultProps = {
  editProtocols:   false,
};

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

export default connect(mapStateToProps, mapDispatchToProps)(StudyCard);
