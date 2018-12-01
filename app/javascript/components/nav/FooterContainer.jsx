import React from 'react'
import ReactDOM from 'react-dom'

export default class FooterContainer extends React.Component {
  render() {
    return(
        <footer id="footer" className="navbar navbar-fixed-bottom admin-footer">
          <div className="container">
            <p className="text-muted credit">DTU</p>
          </div>
        </footer>
    )
  }
}


