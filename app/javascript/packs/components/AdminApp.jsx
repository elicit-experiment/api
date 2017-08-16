import React from 'react'
import ReactDOM from 'react-dom'
import { Switch, Route, BrowserRouter } from 'react-router-dom'
import { Link } from 'react-router-dom'
import StudyStore from '../store/StudyStore'
import UserStore from '../store/UserStore'
import ProtocolStore from '../store/ProtocolStore'
import StudyProtocolStore from '../store/StudyProtocolsStore'
import StudyManagement from './StudyManagement'
import UserManagement from './UserManagement'
import EditStudy from './EditStudy'
import {withRouter} from 'react-router'
import pathToRegexp from 'path-to-regexp'

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

const AppRoutes = {
  edit_study: {
    route: '/admin/studies/:study_id',
    //toPath: pathToRegexp.compile('/admin/studies/:study_id')
  }
}

const Foo = () => (
  <h1>h1</h1>
)

class AdminApp extends React.Component {
  constructor(props){
    super(props);
    this.state = {
        users: [],
        studies: [],
        protocols: [],
        study_protocols: []
    }
  }


  render() {
      if (this.state.studies) {
        console.log(`setting state: ${this.state.studies.length} studies`)
      }
      return(
    <BrowserRouter>
    <div>
      <Header></Header>
      <div id="wrap" className="admin-app-container container">
          <Switch>
            <Route exact path='/admin/studies' render={routeProps => <StudyManagement {...routeProps} users={this.state.users} studies={this.state.studies} protocols={this.state.protocols} study_protocols={this.state.study_protocols} /> } />
            <Route exact path='/admin' render={routeProps => <StudyManagement {...routeProps} users={this.state.users} studies={this.state.studies} protocols={this.state.protocols} study_protocols={this.state.study_protocols} /> } />
            <Route path='/admin/studies/:study_id' render={routeProps => <EditStudy {...routeProps} users={this.state.users} studies={this.state.studies} protocols={this.state.protocols} study_protocols={this.state.study_protocols} /> } />
            <Route path='/admin/users' component={UserManagement}/>
          </Switch>
      </div>
      <footer id="footer" className="navbar navbar-fixed-bottom admin-footer">
        <div className="container">
          <p className="text-muted credit">DTU</p>
        </div>
      </footer>
    </div>
    </BrowserRouter>
  )
  }

  componentDidMount() {
    for (let store of [UserStore, StudyStore, ProtocolStore, StudyProtocolStore]) {
      store.loadItems()
      store.addListener('change', this.handleChangedEvent, this);
    }
  }

  handleChangedEvent = (event) => {
    let s = {
      studies: StudyStore.getList().list, 
      users: UserStore.getList().list,
      protocols: ProtocolStore.getList().list,
      study_protocols: StudyProtocolStore.getList().list,
    }
    console.dir(s)
    this.setState(s)
  }
}

export { Header as Header, AdminApp as AdminApp, AppRoutes };