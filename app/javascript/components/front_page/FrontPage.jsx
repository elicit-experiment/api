// Import React and Dependencies
import React from 'react';
// Import components
import FrontPagePreface from './FrontPagePreface.html';
import PropTypes from "prop-types";
import {useSelector} from "react-redux";
import {currentUserAnyHasRoles} from "../../reducers/selector";

const htmlDoc = {__html: FrontPagePreface};

function ElicitWordMark() {
  return <div className="wordmark-container">
    <div className="mx-auto lead font-wordmark title-wordmark">E</div>
  </div>;
}

const Card = (props) => {
  return <div className="col-lg-4 mb-4">
    <div className="feature-card card shadow-sm rounded-lg p-2">
      <h2 className="card-title text-secondary">{props.title}</h2>
      <p className="card-text" style={{height: "5em"}}>
        {props.description}
      </p>
      <a className="btn btn-primary m-auto" href={props.link_to}>{props.link_title}</a>
    </div>
  </div>;
}

Card.propTypes = {
  title: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
  link_to: PropTypes.string.isRequired,
  link_title: PropTypes.string.isRequired,
};

export default function FrontPage() {
  let admin = '';
  const isAdmin = useSelector(state => currentUserAnyHasRoles(state, ['admin', 'investigator']));
  if (isAdmin) {
    admin = <Card description="Administration console." link_to="/admin" link_title="Admin" title="Admin"/>
  }

  console.log('FRONT PAGE')
  return (
    <div id="wrap" className="admin-app-container container">
      <div className="row mt-5">
        <ElicitWordMark/>
      </div>
      <div className="row">
        <div className="col-12 mx-auto text-center text-secondary" dangerouslySetInnerHTML={htmlDoc}/>
      </div>
      <div className="row wrap">
        <Card description="Elicit is a web framework for creating psychological studies." link_to="/about" link_title="Learn About Elicit" title="About"/>
        <Card description="Investigators can create their own surveys, request." link_to="/request" link_title="Request Access" title="Investigators"/>
        <Card description="Participate in a study!" link_to="/participate" link_title="Participate Anonymously" title="Participants"/>
        {admin}
      </div>
    </div>
  )
}
