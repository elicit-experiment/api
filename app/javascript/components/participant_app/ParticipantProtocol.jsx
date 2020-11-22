import React from 'react';
import PropTypes from 'prop-types';
import elicitApi from '../../api/elicit-api.js';
import {connect} from 'react-redux';
import {ExperimentDetails} from './ExperimentDetails.jsx';
import TakeProtocolLink from './TakeProtocolLink.jsx';
import {ExperimentType, ProtocolDefinitionType, StudyDefinitionType} from "../../types";
import {SimpleModal} from "../ui_elements/SimpleModal";

class ParticipantProtocol extends React.Component {
  constructor(props) {
    super(props);
    this.state = {view: {showModal: false}};
  }

  handleHideModal() {
    this.setState({view: {showModal: false}});
  }

  handleShowModal() {
    this.setState({view: {showModal: true}});
  }

  render() {
    const htmlDescription = {
      dangerouslySetInnerHTML: {__html: this.props.protocol.description},
    };

    const alreadyTaken = (study_id, protocol_id) => {
      if (this.props.taken_protocol && this.props.taken_protocol.data?.code === 410 /* HTTP GONE */ && this.props.taken_protocol?.request) {
        const { study_definition_id,  protocol_definition_id } = this.props.taken_protocol.request.pathvars;
        return (study_id === study_definition_id && protocol_id === protocol_definition_id);
      }
    };

    const takenModal = alreadyTaken(this.props.study.id, this.props.protocol.id) ?
      <SimpleModal title={'Cannot Take Study'}
                   subtitle={'Study has Already Hit Anonymous Participation Maximum'}
                   body={'Please try Another'}
                   show={true}
                   handleHideModal={ () => { this.props.resetTakeError() } } />
              : '';


    let take_protocol = '';
    if (!this.props.experiment || !this.props.experiment.completed_at) {
      take_protocol = <TakeProtocolLink study_id={this.props.study.id}
                                        protocol_id={this.props.protocol.id}
                                        take_protocol={this.props.take_protocol}
                                        available={!!this.props.protocol.has_remaining_anonymous_slots}
                                        taken_protocol={this.props.taken_protocol}/>;
    }
    return (
        <div className='protocols-wrapper row col-12 my-2' key={this.props.protocol.id}>
          { takenModal }
          <div className='card show protocol-summary col-12 p-4'
               data-protocol_id={this.props.protocol.id}>
            <div className='row'>
              <b className="col-2">Protocol:</b>
              <div className='col-5'>
                #{this.props.protocol.id} — {this.props.protocol.name}
              </div>
              <div className="offset-3 col-2">
                <button className="active btn btn-link"
                        onClick={this.handleShowModal.bind(this)}>
                  <span>Study</span>&nbsp;
                  <span className="glyphicon glyphicon-info-sign"
                        aria-hidden="true"/>
                </button>
              </div>
            </div>
            <div className='row'>
              <b className="col-2">Summary:</b>
              <div className='col-10 protocol-summary-text'>
                {this.props.protocol.summary}
              </div>
            </div>
            <div className='row'>
              <div
                  className='offset-2 col-10 protocol-description-text' {...htmlDescription}>
              </div>
            </div>
            { this.props.experiment && <ExperimentDetails experiment={this.props.experiment}/> }
            <div className='row'>
              <div className="col-9">
              </div>
              <div className="col-3">
                {take_protocol}
              </div>
            </div>
          </div>
              <SimpleModal
                show={this.state.view.showModal}
                title={`Study ${this.props.study.id} Details`}
                     subtitle={this.props.study.title}
                     body={this.props.study.description}
                     handleHideModal={this.handleHideModal.bind(this)}/>
        </div>
    );
  }
}

const mapStateToProps = (state) => ({ taken_protocol: state.take_protocol });
const mapDispatchToProps = (dispatch) => ({
  take_protocol: (s) => {
    dispatch(elicitApi.actions.take_protocol(s));
  },
  resetTakeError: () => {
    dispatch(elicitApi.actions.take_protocol.reset())
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(
    ParticipantProtocol);

ParticipantProtocol.propTypes = {
  experiment: ExperimentType,
  protocol: ProtocolDefinitionType.isRequired,
  study: StudyDefinitionType.isRequired,
  take_protocol: PropTypes.func,
  resetTakeError: PropTypes.func,
  taken_protocol: PropTypes.object,
}
