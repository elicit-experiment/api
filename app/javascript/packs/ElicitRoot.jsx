//Import React and Dependencies
import React from 'react';
import { Route, IndexRoute } from 'react-router-dom';
import { BrowserRouter } from 'react-router-dom'
import history from './history.js'
import { connect } from 'react-redux';
import { Provider } from 'react-redux';

// Import Components
import { AdminApp } from './components/AdminApp';

// Import Actions
import { requestClientToken, receiveClientToken, receiveUserToken } from './actions/tokens_actions';

// Import Selectors
import { clientToken, userToken, currentUser } from './reducers/selector';


//Define Root Component and Router
const Root = (props) => {
  const store = props.store

  var token_status = 'none'

  if (!sessionStorage.clientToken || sessionStorage.clientToken === 'undefined') {
    console.log("no client token")
    store.dispatch(requestClientToken( () => { } ))
  } else if (!props.clientToken) {
    console.log(`client token not in state ${sessionStorage.clientToken}`)
    store.dispatch(receiveClientToken({access_token: sessionStorage.clientToken }))
    token_status = 'client'
  } else {
    token_status = 'client'    
  }

  if (!sessionStorage.userToken || sessionStorage.userToken === 'undefined') {
    console.log("no user token")
//    store.dispatch(requestUserToken( () => { } ))
  } else if (!props.userToken) {
    console.log(`user token not in state ${sessionStorage.clientToken}`)
    store.dispatch(receiveUserToken({access_token: sessionStorage.userToken }))
    token_status = 'user'
  } else {
    token_status = 'user'    
  }


  // Ensures the existence of a client/user token before accessing the site
  const _ensureClientOrUserToken = (asyncDoneCallback) => {
    return;
    if (!sessionStorage.clientToken && !sessionStorage.userToken) {
      store.dispatch(requestClientToken(asyncDoneCallback));
    } else if (sessionStorage.userToken && !store.getState().users.currentUser) {
      store.dispatch(requestCurrentUser(asyncDoneCallback));
    } else {
      asyncDoneCallback();
    }
  };

  // Ensures the user is logged in before accessing a particular route
  const _ensureLoggedIn = (nextState, replace) => {
    let currentUser = store.getState().users.currentUser;
    if (!currentUser) {
      replace("/");
    }
  };

  console.dir(props.store.getState())

  return (
<Provider store={store}>
    <BrowserRouter history={history}>
      <div>
      <Route exact path="/admin" render={routeProps => {
        if (token_status == 'user') {
          return <AdminApp />
        } else if (token_status == 'client') {
          return <div>Sign in... {props.clientToken}</div>
        } else {
          return <div>Loading...</div>          
        }
      } } >
      </Route>
      </div>
    </BrowserRouter>
</Provider>
  );
};


const mapStateToProps = (state) => ({
  clientToken: clientToken(state),
  userToken: userToken(state),
  currentUser: currentUser(state),
});

const mapDispatchToProps = (dispatch) => ({
});

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(Root);

