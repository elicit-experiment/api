//Import React and Dependencies
import React from 'react';
import { Route, IndexRoute, Redirect } from 'react-router-dom';
import { BrowserRouter } from 'react-router-dom'
import history from './history.js'
import { connect } from 'react-redux';
import { Provider } from 'react-redux';

// Import Components
import { AdminApp } from './components/AdminApp'
import { ParticipantApp } from './components/participant_app/ParticipantApp'
import LoginSignUpContainer from './components/login_signup/LoginSignUpContainer'

// Import Actions
import { requestClientToken, receiveClientToken, receiveUserToken } from './actions/tokens_actions';

// Import Selectors
import { clientToken, userToken, currentUser } from './reducers/selector';


//Define Root Component and Router
const RawRootRoutes = (props) => {
  const store = props.store


  const _tokenStatus = (props) => {
    var token_status = 'none'

    if (!props.clientToken || !props.clientToken.access_token) {
      console.log("no client token")
      store.dispatch(requestClientToken( () => { } ))
    } else {
      token_status = 'client'    
    }

    if (!props.userToken || !props.userToken.access_token) {
      console.log("no user token")
    } else {
      token_status = 'user'    
    }
    return token_status    
  }

  console.dir(`ROOT RERENDERING ${_tokenStatus(props)}`)

  return (
      <div>
      <Route exact path="/admin" name="admin_overview" render={ routeProps => {
        var token_status = _tokenStatus(props)
        if (token_status == 'user') {
          return <AdminApp {...props} />
        } else if (token_status == 'client') {
          return <LoginSignUpContainer></LoginSignUpContainer>
        } else {
          return <div>Loading...</div>          
        }
      } } >
      </Route>
      {["/participant", "/"].map(path =>
      <Route exact path={path} name="participant" render={ routeProps => {
        var token_status = _tokenStatus(props)
        if (token_status == 'user') {
          return <ParticipantApp {...props} />
        } else if (token_status == 'client') {
          return <LoginSignUpContainer></LoginSignUpContainer>
        } else {
          return <div>Loading...</div>          
        }
      } } >
      </Route>
      ) }
      </div>
  );
};


const mapStateToProps = (state) => ( {
  clientToken: clientToken(state),
  userToken: userToken(state),
//    currentUser: currentUser(state),
})

const mapDispatchToProps = (dispatch) => ({
});

const RootRoutes = connect(
    mapStateToProps,
    mapDispatchToProps
)(RawRootRoutes);

const Root = (props) => {
  return (
<Provider store={props.store}>
    <BrowserRouter history={history}>
      <RootRoutes {...props} />
    </BrowserRouter>
</Provider>
  );
};

export default Root