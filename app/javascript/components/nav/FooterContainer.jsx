import React from 'react'
import ReactDOM from 'react-dom'

export default class FooterContainer extends React.Component {
  render() {
    return(
        <footer id="footer" className="footer admin-footer">
          <div className="container">
            <p className="text-muted credit my-1">DTU</p>
          </div>
        </footer>
    )
  }
}


