import React from 'react'
import ReactDOM from 'react-dom'
import { Switch, Route, BrowserRouter } from 'react-router-dom'
import { Link } from 'react-router-dom'
import StudyManagement from './StudyManagement'
import UserManagement from './UserManagement'
import {withRouter} from 'react-router'

const Header = () => (
  <nav className="navbar navbar-default navbar-fixed-top">
    <div className="container">
      <div className="navbar-header">
        <button type="button" className="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
          <span className="icon-bar"></span>
          <span className="icon-bar"></span>
          <span className="icon-bar"></span>
        </button>
        <a className="navbar-brand" href="#">CogSci</a>
      </div>
      <div id="admin-nav" className="navbar-collapse ">
        <ul className="nav navbar-nav">
          <li><Link to='/'>Home</Link></li>
          <li><Link to='/admin'>Admin</Link></li>
          <li><Link to='/admin/studies'>Study Management</Link></li>
          <li><Link to='/admin/users'>User Management</Link></li>
        </ul>
      </div>
    </div>
  </nav>
)

class AdminApp extends React.Component {
    render() {
      return(
    <BrowserRouter>
    <div>
      <Header></Header>
      <div id="wrap">
          <div className="container">
          <Switch>
            <Route path='/admin/studies' component={StudyManagement}/>
            <Route path='/admin/users' component={UserManagement}/>
            <Route exact path='/admin' component={StudyManagement}/>
          </Switch>
        </div>
      </div>

      <div id="footer">
        <div className="container">
          <p className="text-muted credit">DTU</p>
        </div>
      </div>
    </div>
    </BrowserRouter>
  )
  }
}

export { Header as Header, AdminApp as AdminApp };