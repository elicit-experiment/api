import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import elicitApi from '../../api/elicit-api.js';
import { connect } from "react-redux";
import { ExperimentDetails } from "./ExperimentDetails.jsx";

const TakeProtocolLink = (props) => {
  return (
      <button onClick={ () => {
        props.take_protocol({study_definition_id: props.study_id, protocol_definition_id: props.protocol_id }) } } className="active btn btn-primary">
          Participate
      </button>
  )
};

class Modal extends React.Component {
   componentDidMount() {
      const element = ReactDOM.findDOMNode(this);
      $(element).modal('show');
      $(element).on('hidden.bs.modal', this.props.handleHideModal);
    }

    render(){
        return (
          <div className="modal fade">
            <div className="modal-dialog">
              <div className="modal-content">
                <div className="modal-header">
                  <button type="button" className="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                  <h4 className="modal-title">{this.props.title}</h4>
                </div>
                <div className="modal-body">
                  <p>{this.props.subtitle}</p>
                  <hr/>
                  <p>{this.props.body}</p>
                </div>
                <div className="modal-footer">
                  <button type="button" className="btn btn-primary" data-dismiss="modal">Close</button>
                </div>
              </div>
            </div>
          </div>
        )
    }

    static propTypes = {
        handleHideModal: PropTypes.func.isRequired
    }
};

class ParticipantProtocol extends React.Component {
  constructor(props){
    super(props);
    this.state = {view: {showModal: false}}
  }

  handleHideModal(){
      this.setState({view: {showModal: false}})
  }

  handleShowModal() {
      this.setState({view: {showModal: true}})
  }

  render() {
    var take_protocol = "";
    if (!this.props.experiment || !this.props.experiment.completed_at) {
      take_protocol = <TakeProtocolLink study_id={this.props.study.id} protocol_id={this.props.protocol.id} take_protocol={this.props.take_protocol}/>
    }
    return (
      <div className='protocols-wrapper row' key={this.props.protocol.id}>
        <div className='well show protocol-summary' data-protocol_id={this.props.protocol.id}>
          <div className='row'>
            <b className="col-xs-2">Protocol:</b>
            <div className='col-xs-5'>
              #{this.props.protocol.id} — {this.props.protocol.name}
            </div>
            <div className="col-xs-offset-3 col-xs-2">
              <button  className="active btn btn-link" onClick={this.handleShowModal.bind(this)}>
                  <span>Study</span>&nbsp;
                  <span className="glyphicon glyphicon-info-sign" aria-hidden="true"></span>
              </button>
            </div>
          </div>
          <div className='row'>
            <b className="col-xs-2">Summary:</b>
            <div className='col-xs-10 protocol-summary-text'>
              {this.props.protocol.summary}
            </div>
          </div>
          <div className='row'>
            <div className='col-xs-offset-2 col-xs-10 protocol-description-text'>
              {this.props.protocol.description}
            </div>
          </div>
          <ExperimentDetails experiment={this.props.experiment} />
          <div className='row'>
            <div className="col-xs-9">
            </div>
            <div className="col-xs-3">
              {take_protocol}
            </div>
          </div>
        </div>
        {this.state.view.showModal ? <Modal title={`Study ${this.props.study.id} Details`}
                                            subtitle={this.props.study.title}
                                            body={this.props.study.description}
                                            handleHideModal={this.handleHideModal.bind(this)}/> : null}
      </div>
    )
  }
}

const mapStateToProps = (/*state*/) => ({
});
const mapDispatchToProps = (dispatch) => ({
    take_protocol: (s) => { dispatch(elicitApi.actions.take_protocol(s)) }
});

export default connect(mapStateToProps, mapDispatchToProps)(ParticipantProtocol);

