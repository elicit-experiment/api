import React from 'react'
import ReactDOM from 'react-dom'
import { Switch, Route } from 'react-router-dom'
import { Link } from 'react-router-dom'
import StudyManagement from './StudyManagement'
import UserManagement from './UserManagement'

const Header = () => (
  <ul className="nav navbar-nav">
    <li><Link to='/admin'>Home</Link></li>
    <li><Link to='/admin/studies'>Study Management</Link></li>
    <li><Link to='/admin/users'>User Management</Link></li>
  </ul>
)

//      <Route exact path='/admin' component={Home}/>

const Content = () => (
  <main>
    <Switch>
      <Route path='/admin/studies' component={StudyManagement}/>
      <Route path='/admin/users' component={UserManagement}/>
      <Route exact path='/admin' component={StudyManagement}/>
    </Switch>
  </main>
)

// this component will be rendered by our <___Router>
const AdminApp = () => (
  <div>
    <Content />
  </div>
)

class Main extends React.Component {
  render() {
    return(
      <div>
        <Header />
        <Content />
      </div>)
  }
}


export { Header as Header, AdminApp as AdminApp };