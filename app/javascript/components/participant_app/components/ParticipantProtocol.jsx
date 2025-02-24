import React, { useState } from 'react';
import PropTypes from 'prop-types';
import elicitApi from '../../../api/elicit-api.js';
import { useDispatch, useSelector } from 'react-redux';
import {ExperimentDetails} from './ExperimentDetails.jsx';
import TakeProtocolLink from './TakeProtocolLink.jsx';
import {ExperimentType, ProtocolDefinitionType, StudyDefinitionType} from "../../../types";
import {SimpleModal} from "../../ui_elements/SimpleModal";

const ParticipantProtocol = ({ experiment, protocol, study }) => {
  const dispatch = useDispatch();
  const taken_protocol = useSelector(state => state.take_protocol);
  const [showModal, setShowModal] = useState(false);

  const handleHideModal = () => setShowModal(false);
  const handleShowModal = () => setShowModal(true);

  const htmlDescription = {
    dangerouslySetInnerHTML: {__html: protocol.description},
  };

  const signedInExperiment = experiment !== undefined;

  const alreadyTaken = (study_id, protocol_id) => {
    if (taken_protocol && taken_protocol.data?.code === 410 /* HTTP GONE */ && taken_protocol?.request) {
      const { study_definition_id, protocol_definition_id } = taken_protocol.request.pathvars;
      return (study_id === study_definition_id && protocol_id === protocol_definition_id);
    }
  };

  const resetTakeError = () => {
    dispatch(elicitApi.actions.take_protocol.reset());
  };

  const take_protocol_action = (s) => {
    dispatch(elicitApi.actions.take_protocol(s));
  };

  const takenModal = alreadyTaken(study.id, protocol.id) ?
    <SimpleModal title={'Cannot Take Study'}
                 subtitle={'Study has Already Hit Anonymous Participation Maximum'}
                 body={'Please try Another'}
                 show={true}
                 handleHideModal={resetTakeError} />
            : '';

  let take_protocol = '';
  if (!experiment || !experiment.completed_at) {
    take_protocol = <TakeProtocolLink study_id={study.id}
                                      protocol_id={protocol.id}
                                      take_protocol={take_protocol_action}
                                      available={signedInExperiment || !!protocol.has_remaining_anonymous_slots}
                                      taken_protocol={taken_protocol}/>;
  }

  return (
    <div className='protocols-wrapper row col-12 my-2' key={protocol.id}>
      {takenModal}
      <div className='card show protocol-summary col-12 p-4'
           data-protocol_id={protocol.id}>
        <div className='row'>
          <b className="col-2">Protocol:</b>
          <div className='col-5'>
            #{protocol.id} — {protocol.name}
          </div>
          <div className="offset-3 col-2">
            <button className="active btn btn-link"
                    onClick={handleShowModal}>
              <span>Study</span>&nbsp;
              <span className="fas fa-info-circle"
                    aria-hidden="true"/>
            </button>
          </div>
        </div>
        <div className='row'>
          <b className="col-2">Summary:</b>
          <div className='col-10 protocol-summary-text'>
            {protocol.summary}
          </div>
        </div>
        <div className='row'>
          <div
              className='offset-2 col-10 protocol-description-text' {...htmlDescription}>
          </div>
        </div>
        {experiment && <ExperimentDetails experiment={experiment}/>}
        <div className='row'>
          <div className="col-9">
          </div>
          <div className="col-3">
            {take_protocol}
          </div>
        </div>
      </div>
      <SimpleModal
        show={showModal}
        title={`Study ${study.id} Details`}
        subtitle={study.title}
        body={study.description}
        handleHideModal={handleHideModal}/>
    </div>
  );
};

ParticipantProtocol.propTypes = {
  experiment: ExperimentType,
  protocol: ProtocolDefinitionType.isRequired,
  study: StudyDefinitionType.isRequired,
};

export default ParticipantProtocol;
