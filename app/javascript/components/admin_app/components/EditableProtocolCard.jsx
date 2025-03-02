import React, { useState, useEffect } from "react";
import update from "react-addons-update";
import elicitApi from "../../../api/elicit-api";
import { Link } from "react-router-dom";
import { CopyToClipboard } from "react-copy-to-clipboard";
import BootstrapRoutesButton from "bootstrap-switch-button-react";
import { ProtocolDefinitionType, StudyDefinitionType } from "../../../types";
import PropTypes from "prop-types";
import { useDispatch } from 'react-redux';

export const EditableProtocolCard = ({ protocol, study, children }) => {
  const [active, setActive] = useState(protocol.active);
  const [copied, setCopied] = useState(false);
  const dispatch = useDispatch();

  useEffect(() => {
    setActive(protocol.active);
  }, [protocol.active]);

  const onToggle = () => {
    const newActive = !active;
    const newData = update(protocol, {
      active: {$set: newActive},
    });
    dispatch(
      elicitApi.actions.protocol_definition.patch(
        {
          study_definition_id: protocol.study_definition_id,
          id: protocol.id,
        },
        {body: JSON.stringify({protocol_definition: newData})}
      )
    );
    setActive(newActive);
  };
  const htmlDescription = {
    dangerouslySetInnerHTML: {__html: protocol.description},
  };

  return (
    <div className="container card p-4 mb-4 " key={protocol.id}>
      <div
        className="protocol-row container protocol-header-row"
        key={"t" + protocol.id}
      >
        <div className="col-4">
          <b>{protocol.id} —{" "}
            {protocol.name}</b>
        </div>
      </div>

      <div className="protocol-row row" key={"d" + protocol.id}>
        <div className="col-12 "><p className="col-12" {...htmlDescription}></p></div>
        <div className="col-12 study-action-bar">
          <Link to={`/admin/studies/${study.id}/protocols/${protocol.id}`}
                className="btn btn-primary">
            Preview
          </Link>

          <CopyToClipboard
            text={`${window.location.origin}/studies/${study.id}/protocols/${protocol.id}`}
            onCopy={() => setCopied(true)}>
            <button type="button" className="btn btn-primary protocol-link-button">
              {copied ? <span style={{color: 'pink'}}>Copied.</span> : <span>Get Link</span>}
              &nbsp;
              <i className="fas fa-link" aria-hidden="true"/>
            </button>
          </CopyToClipboard>

          <button type="button" className="btn btn-primary">
            Phases &nbsp; <span
            className="badge bg-secondary">{protocol.phase_definitions.length}</span>
          </button>
          <BootstrapRoutesButton
            onChange={onToggle}
            onlabel='Active'
            offlabel='Inactive'
            size="md"
            offstyle="danger"
            onstyle="success"
            width="100"
            checked={active}/>
        </div>
      </div>

      {children && <div className="protocol-row row" >{children}</div>}
    </div>
  );
};

EditableProtocolCard.propTypes = {
  protocol: ProtocolDefinitionType,
  study: StudyDefinitionType,
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]),
};

