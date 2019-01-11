import React from 'react';
import PropTypes from 'prop-types';

const TakeProtocolLink = (props) => {
  return (
      <button onClick={ () => {
        props.take_protocol({study_definition_id: props.study_id, protocol_definition_id: props.protocol_id }) } } className="active btn btn-primary">
        Participate
      </button>
  )
};

TakeProtocolLink.propTypes = {
  study_id: PropTypes.number.isRequired,
  protocol_id: PropTypes.number.isRequired,
  take_protocol: PropTypes.func.isRequired,
};

export default TakeProtocolLink;