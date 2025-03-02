import React from "react";
import PropTypes from "prop-types";
import { useState } from "react";
import update from "react-addons-update";
import elicitApi from "../../../api/elicit-api.js";
import {useDispatch} from "react-redux";
import BootstrapRoutesButton from 'bootstrap-switch-button-react'
import {ApiReturnCollectionOf, ProtocolDefinitionType, StudyDefinitionType} from '../../../types';
import SweetAlert from 'react-sweetalert2';
import {ProtocolInfoLink} from "./ProtocolInfoLink";
import {Link} from "react-router-dom";
import {EditableProtocolList} from "./EditableProtocolList";

const StudyCard = (props) =>  {
  const [title, setTitle] = useState(props.study.title);
  const [deleteVerify, setDeleteVerify] = useState(false);
  const dispatch = useDispatch();

  const deleteStudyDefinition = (id) => dispatch(elicitApi.actions.study_definition.delete({ id }));

  const updateStudyDefinition = (id, studyDefinition) => {
    dispatch(elicitApi.actions.study_definition.patch(
      { id },
      { body: JSON.stringify({ study_definition: studyDefinition }) }
    ))
  };

  const titleChanged = (data) => {
    const newData = update(props.study, {
      title: { $set: data.title },
    });
    updateStudyDefinition(props.study.id, newData);
    setTitle(data.title);
  }

  const validateTitle = (text) => (text.length > 0 && text.length < 64);

  const dropDownOnChange = (_x) => {}

  const onToggleAllowAnonymousUsers = () => {
    const newValue = !props.study.allow_anonymous_users;
    updateStudyDefinition(props.study.id, {
      allow_anonymous_users: newValue,
    });
  }

  const onToggleShowInStudyList = () => {
    const newValue = !props.study.show_in_study_list;
    updateStudyDefinition(props.study.id, {
      show_in_study_list: newValue,
    });
  }
  const deleteStudy = () => deleteStudyDefinition(props.study.id);

  let protocolsRow, studyClass;

  if (props.editProtocols) {
    protocolsRow = (
      <EditableProtocolList
        study={props.study}
        study_protocols={props.study.protocol_definitions}
        protocols={props.protocols}
      />
    );
    studyClass = "card show study-detail my-4";
  } else {
    protocolsRow = (
      <ProtocolInfoLink
        study={props.study}
        study_protocols={props.study.protocol_definitions}
        protocol_definitions={props.protocols}
      />
    );
    studyClass = "card show study-summary my-4";
  }

  // TODO: style sweetalert or replace it with a bootstrap modal doing the same thing
  // (and maybe using the same interface?)
  const deleteAlert = <SweetAlert
    show={deleteVerify}
    title="Really delete?"
    text="Are you sure you want to delete this study and all its results?"
    type='warning'
    buttonsStyling={false}
    confirmButtonClass='btn btn-primary btn-lg'
    cancelButtonClass='btn btn-lg'
    showCancelButton={true}
    confirmButtonText="Yes, delete it!"
    onConfirm={() => {
      setDeleteVerify(false)
      deleteStudy();
    }}
  />

  const created = new Date(Date.parse(props.study.created_at));
  return (
    <div className="study-wrapper" key={props.study.id}>
      {deleteAlert}
      <div className={studyClass} data-studyid={props.study.id}>
        <div className="container">
          <div className="row study-info-row">
            <b className="col-2">ID:</b>
            <div className="col-5">
              {props.study.id}
            </div>
          </div>
          <div className="row study-info-row">
            <b className="col-2">Title:</b>
            <div className="col-5">
              {title}
            </div>
          </div>
          <div className="row study-info-row">
            <b className="col-2">Created:</b>
            <div className="col-5">
              {`${created.toLocaleDateString()}  ${created.toLocaleTimeString()}`}
            </div>
          </div>
          <div className="row study-info-row">
            <b className="col-2">PI:</b>
            <div className="col-5">
              <b>{props.study.principal_investigator.email}</b>
            </div>
          </div>
          <div className="row study-info-row">
            <b className="col-2">Description:</b>
            <div className="col-10">
              {props.study.description}
            </div>
          </div>
          {protocolsRow}
          <button className="btn btn-danger remove-study d-none" onClick={() => setDeleteVerify(true)}>
            {" "}
            &times;{" "}
          </button>
          <div className="row study-info-row">
            <div className="col-2" />

            <div className="col-6 d-flex justify-content-around align-items-center">
              <Link to={`/admin/studies/${props.study.id}/edit`}
                    className="mr-2">
                <span className="fas fa-edit pe-1" aria-hidden="true"/><span>Edit</span>
              </Link>
              <span className="mr-2">
                <BootstrapRoutesButton
                  onlabel='Allow Anonymous'
                  offlabel='Registered Users Only'
                  className="ml-4"
                  size="sm"
                  offstyle="danger"
                  onstyle="success"
                  width="180"
                  checked={props.study.allow_anonymous_users}
                  onChange={onToggleAllowAnonymousUsers}
                />
                </span>
              <span className="mr-2">
                  <BootstrapRoutesButton
                    onlabel='Show in Study List'
                    offlabel='Hide in Study List'
                    size="sm"
                    offstyle="danger"
                    onstyle="success"
                    width="150"
                    checked={props.study.show_in_study_list}
                    onChange={onToggleShowInStudyList}
                  />
                </span>
            </div>
            <div className="col-4 d-flex justify-content-end">
              <button
                onClick={() => setDeleteVerify(true)}
                className="btn btn-danger"
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

StudyCard.propTypes = {
  protocols: ApiReturnCollectionOf(ProtocolDefinitionType),
  study: StudyDefinitionType,
  editProtocols: PropTypes.bool,
};

StudyCard.defaultProps = {
  editProtocols:   false,
};

export default StudyCard;
