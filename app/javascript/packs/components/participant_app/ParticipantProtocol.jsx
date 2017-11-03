import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import InlineEdit from 'react-edit-inline'
import update from 'react-addons-update'
import { Link } from 'react-router-dom'
import pathToRegexp from 'path-to-regexp'
import elicitApi from '../../api/elicit-api.js'
import { connect } from "react-redux";
import elicitConfig from '../../ElicitConfig.js'
import FormattedDate from '../ui_elements/FormattedDate.jsx'

const TakeProtocolLink = (props) => {
  return (
      <button onClick={ (e) => {
        props.take_protocol({study_definition_id: props.study_id, protocol_definition_id: props.protocol_id }) } } className="active btn btn-primary">
          Take Protocol
      </button>
  )
}

let Modal = React.createClass({
    componentDidMount() {
      const element = ReactDOM.findDOMNode(this);
      $(element).modal('show');
      $(element).on('hidden.bs.modal', this.props.handleHideModal);
    },
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
    },
    propTypes:{
        handleHideModal: React.PropTypes.func.isRequired
    }
});


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
    var experiment = <div><b>Not Started</b></div>
    console.dir(this.props)
    if (this.props.experiment) {
      const exp = this.props.experiment
      var exp_text = ""
      if (exp.completed_at) {
        exp_text = <b><span>Completed on <FormattedDate date={exp.completed_at}></FormattedDate></span></b>
      } else {
        const current_status = "Completed " + exp.current_stage.last_completed_trial + "/" + exp.current_stage.num_trials + " slides."
        exp_text = <div><span className="started-experiment">Started on <FormattedDate date={exp.completed_at}></FormattedDate></span><div>{current_status}</div></div>
      }
      experiment = <div className='row'>
            <div className='col-xs-12 '>
              {exp_text}
            </div>
          </div>

    } 
    return (
      <div className='protocols-wrapper col-xs-10' key={this.props.protocol.id}>
        <div className='well show protocol-summary' data-protocol_id={this.props.protocol.id}>
          <div className='row'>
            <b className="col-xs-2">Protocol:</b>
            <div className='col-xs-5'>
              #{this.props.protocol.id} — {this.props.protocol.name}
            </div>
          </div>
          <div className='row'>
            <b className="col-xs-2">Summary:</b>
            <div className='col-xs-10 protocol-summary-text'>
              {this.props.protocol.summary}
            </div>
          </div>
          <div className='row'>
            <div className='col-xs-12 protocol-description-text'>
              {this.props.protocol.description}
            </div>
          </div>
          {experiment}
          <div className='row'>
            <div className="col-xs-7">
            </div>
            <div className="col-xs-2">
              <button  className="active btn btn-link" onClick={this.handleShowModal.bind(this)}><span>Study</span>&nbsp;<span className="glyphicon glyphicon-info-sign" aria-hidden="true"></span></button>
            </div>
            <div className="col-xs-3">
              <TakeProtocolLink study_id={this.props.study.id} protocol_id={this.props.protocol.id} take_protocol={this.props.take_protocol}/>
            </div>
          </div>
        </div>
        {this.state.view.showModal ? <Modal title={`Study ${this.props.study.id} Details`} subtitle={this.props.study.title} body={this.props.study.description} handleHideModal={this.handleHideModal.bind(this)}/> : null}
      </div>
    )
  }
}

const mapStateToProps = (state) => ({
});
const mapDispatchToProps = (dispatch) => ({
    take_protocol: (s) => { dispatch(elicitApi.actions.take_protocol(s)) }
});

export default connect(mapStateToProps, mapDispatchToProps)(ParticipantProtocol);

