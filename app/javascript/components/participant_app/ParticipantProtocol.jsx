import React from 'react';
import PropTypes from 'prop-types';
import elicitApi from '../../api/elicit-api.js';
import {connect} from 'react-redux';
import {ExperimentDetails} from './ExperimentDetails.jsx';
import TakeProtocolLink from './TakeProtocolLink.jsx';
import Modal from "react-bootstrap/Modal";
import Button from "react-bootstrap/Button";
import {ExperimentType, ProtocolDefinitionType, StudyDefinitionType} from "../../types";

class SimpleModal extends React.Component {

  constructor(props) {
    super(props);
  }
  render() {
    return (
    <Modal show={this.props.show}>
      <Modal.Header>
        <h4>{this.props.title}</h4>
      </Modal.Header>
      <Modal.Body>
        <p>{this.props.subtitle}</p>
        <hr/>
        <p>{this.props.body}</p>
      </Modal.Body>
      <Modal.Footer>
        <Button variant="secondary" onClick={this.props.handleHideModal}>
          Close
        </Button>
      </Modal.Footer>
    </Modal>
    );
  }
}

SimpleModal.propTypes = PropTypes.shape({
  title: PropTypes.string.isRequired,
  subtitle: PropTypes.string.isRequired,
  body: PropTypes.string.isRequired,
  show: PropTypes.string.isRequired,
  handleHideModal: PropTypes.func.isRequired,
}).isRequired;

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

    let take_protocol = '';
    if (!this.props.experiment || !this.props.experiment.completed_at) {
      take_protocol = <TakeProtocolLink study_id={this.props.study.id}
                                        protocol_id={this.props.protocol.id}
                                        take_protocol={this.props.take_protocol}/>;
    }
    return (
        <div className='protocols-wrapper row col-12 my-2' key={this.props.protocol.id}>
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
                        aria-hidden="true"></span>
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
            <ExperimentDetails experiment={this.props.experiment}/>
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

const mapStateToProps = (/*state*/) => ({});
const mapDispatchToProps = (dispatch) => ({
  take_protocol: (s) => {
    dispatch(elicitApi.actions.take_protocol(s));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(
    ParticipantProtocol);

SimpleModal.propTypes = {
  body: PropTypes.string.isRequired,
  handleHideModal: PropTypes.func.isRequired,
  show: PropTypes.bool.isRequired,
  subtitle: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
}

ParticipantProtocol.propTypes = {
  experiment: ExperimentType.isRequired,
  protocol: ProtocolDefinitionType.isRequired,
  study: StudyDefinitionType.isRequired,
  take_protocol: PropTypes.func,
}
