import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

const Experiment = props => (
  <div>Hello {props.name}!</div>
)

Experiment.defaultProps = {
  name: 'David'
}

Experiment.propTypes = {
  name: PropTypes.string
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Experiment name="Experiment" />,
    document.body.appendChild(document.createElement('div')),
  )
})