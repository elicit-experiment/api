import React from "react";
import Modal from "react-bootstrap/Modal";
import Button from "react-bootstrap/Button";
import PropTypes from "prop-types";

export const SimpleModal = ({show, title, subtitle, body, handleHideModal}) => (
  <Modal show={show}>
    <Modal.Header>
      <h4>{title}</h4>
    </Modal.Header>
    <Modal.Body>
      <p>{subtitle}</p>
      <hr/>
      <p>{body}</p>
    </Modal.Body>
    <Modal.Footer>
      <Button variant="secondary" onClick={handleHideModal}>
        Close
      </Button>
    </Modal.Footer>
  </Modal>
);

SimpleModal.propTypes = {
  body: PropTypes.string.isRequired,
  handleHideModal: PropTypes.func.isRequired,
  show: PropTypes.bool.isRequired,
  subtitle: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
}

export default SimpleModal;