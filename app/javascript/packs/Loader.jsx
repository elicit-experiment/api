import $ from 'jquery'
import _ from 'lodash'

import React from 'react'
import ReactDOM from 'react-dom'

//Store and Root Component
import configureStore from './store/store';
import ElicitRoot from './ElicitRoot';

const preloadedStore = {
  tokens: {
    clientToken: sessionStorage.clientToken,
    userToken: sessionStorage.userToken
  },
  users: {
    currenUser: undefined
  }
}

const store = configureStore(preloadedStore);
console.log("Elicit App Loading...")

const onload = () => {
  var elt = document.getElementById('elicit-app')
  ReactDOM.render(<ElicitRoot store={store}></ElicitRoot>, elt);
}

export default onload;


