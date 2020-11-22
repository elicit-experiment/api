import React from "react";
import Modal from "react-bootstrap/Modal";
import Button from "react-bootstrap/Button";
import PropTypes from "prop-types";

export class SimpleModal extends React.Component {
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

SimpleModal.propTypes = {
  body: PropTypes.string.isRequired,
  handleHideModal: PropTypes.func.isRequired,
  show: PropTypes.bool.isRequired,
  subtitle: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
}
/*
SimpleModal.propTypes = PropTypes.shape({
  title: PropTypes.string.isRequired,
  subtitle: PropTypes.string.isRequired,
  body: PropTypes.string.isRequired,
  show: PropTypes.string.isRequired,
  handleHideModal: PropTypes.func.isRequired,
}).isRequired;
*/
