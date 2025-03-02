import React from 'react';
import PropTypes from 'prop-types';

const TakeProtocolLink = (props) => {
  const queryParams = window.location.search.replace(/^\?(.*)/, '$1')
    .split('&')
    .map((p) => {
      const x = p.split(/=/);
      let y = {};
      y[x[0]] = x[1];
      return y;
    })
    .reduce((l, r) => Object.assign(l, r), {});

  const take = () => {
    props.take_protocol({
      study_definition_id: props.study_id,
      protocol_definition_id: props.protocol_id, ...queryParams,
    });
  }

  return (
    <button onClick={take} disabled={!props.available} className="btn btn-primary">
      Participate
    </button>
  )
};

TakeProtocolLink.propTypes = {
  study_id: PropTypes.number.isRequired,
  protocol_id: PropTypes.number.isRequired,
  take_protocol: PropTypes.func.isRequired,
  available: PropTypes.bool.isRequired,
  taken_protocol: PropTypes.object,
};

export default TakeProtocolLink;
