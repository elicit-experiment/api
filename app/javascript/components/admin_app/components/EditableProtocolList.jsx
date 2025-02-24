import {useSelector} from "react-redux";
import PropTypes from "prop-types";
import {ProtocolDefinitionType, StudyDefinitionType} from "../../../types";
import React from "react";
import {EditableProtocolCard} from "./ProtocolDetailCard";

export function EditableProtocolList(props) {
  const protocols = useSelector(state => state.protocol_definitions)

  let protocol_list = props.study_protocols.map((protocol, _i) => {
    // This is a little gross.  Because the protocol_definitions inside the study definitions
    // don't get updated when we patch the protocol definition, we need to check if there's
    // a protocol_definition in the protocol_definitions state which matches the id, and treat
    // that as authoritative.
    let protocol_def = protocols.data.filter((p) => (p.id === protocol.id));
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
  study: StudyDefinitionType,
};