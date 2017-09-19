import $ from 'jquery'
import _ from 'lodash'

import React from 'react'
import ReactDOM from 'react-dom'

//Store and Root Component
import { configureStore } from './store/store';
import ElicitRoot from './ElicitRoot';

const getToken = (tok) => {
  if (sessionStorage[tok]) {
    try {
        return JSON.parse(sessionStorage[tok])
    } catch (e) {
     console.warn("Bad stuff in localstorage for usertoken.")
     sessionStorage.removeItem(tok)
    }
  }
  return  {
      access_token: undefined
    }
}

const preloadedStore = {
  tokens: {
    clientToken: getToken('clientToken'),
    userToken: getToken('userToken')
  },
  users: {
    currenUser: undefined
  }
}

const store = configureStore(preloadedStore);
console.log("Elicit App Loading...")
console.dir(preloadedStore)

const onload = () => {
  var elt = document.getElementById('elicit-app')
  ReactDOM.render(<ElicitRoot store={store}></ElicitRoot>, elt);
}

export default onload;


