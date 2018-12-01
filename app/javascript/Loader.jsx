import $ from 'jquery'
import _ from 'lodash'

window.jQuery = $

import React from 'react'
import ReactDOM from 'react-dom'

//Store and Root Component
import { configureStore } from './store/store';
import ElicitRoot from './ElicitRoot';

const getToken = (tok) => {
  if (sessionStorage[tok]) {
    try {
        let token = JSON.parse(sessionStorage[tok])
        let expire_time = token.created_at + token.expires_in
        if (expire_time < (new Date()).getTime()) {
          console.log('EXPIRED!')
        }
        return token
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


