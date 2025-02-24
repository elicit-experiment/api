import PropTypes from 'prop-types'
import React from 'react';
const dateFormat = require('dateformat');

const ParticipantProtocol = ({date}) => {
  const parsedDate = Date.parse(date);
  const dateText = dateFormat(parsedDate, "dddd, mmmm dS, yyyy, h:MM:ss TT");
  return (<span>{dateText}</span>)
};

ParticipantProtocol.propTypes = {
  date: PropTypes.object.isRequired,
}

export default ParticipantProtocol;