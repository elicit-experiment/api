import {Link} from "react-router-dom";
import React from "react";
import PropTypes from "prop-types";
import {ProtocolDefinitionType, StudyDefinitionType} from "../../../types";

export const ProtocolInfoLink = props => (
  <div className="row study-info-row">
    <b className="col-2">Protocols:</b>
    <div className="col-2">
      <Link to={`/admin/studies/${props.study.id}/edit`} className="active">
        <i className="fas fa-edit" aria-hidden="true"/> Edit
      </Link>
    </div>
    <b className="col-1 study-info-protocols-count">
      {(props.study_protocols || []).length}
    </b>
  </div>
);

ProtocolInfoLink.propTypes = {
  study_protocols: PropTypes.arrayOf(ProtocolDefinitionType),
  study: StudyDefinitionType,
};
