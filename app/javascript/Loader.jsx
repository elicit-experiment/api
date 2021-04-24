import $ from 'jquery'

window.jQuery = $;

import React from 'react'
import ReactDOM from 'react-dom'

//Store and Root Component
import { configureStore } from './store/store';
import ElicitRoot from './ElicitRoot';
import 'packs/main.scss'

const getToken = (tok) => {
  if (sessionStorage[tok]) {
    try {
        let token = JSON.parse(sessionStorage[tok]);
        let expire_time = token.created_at + token.expires_in;
        if (expire_time < (new Date()).getTime()) {
          console.warn('returning expired usertoken')
        }
        if ('access_token' in token) {
          if (token.access_token) {
            return token
          }
        }
        return undefined;
    } catch (e) {
     console.warn("Bad stuff in localstorage for usertoken.");
     sessionStorage.removeItem(tok)
    }
  }
  return undefined;
};

const preloadedStore = {
  tokens: {
    clientToken: getToken('clientToken'),
    userToken: getToken('userToken'),
  },
};

const store = configureStore(preloadedStore);
console.log("Elicit App Loading...");
console.dir(preloadedStore);

const onload = () => {
  console.log("Loader::onload");
  const elt = document.getElementById('elicit-app');
  ReactDOM.render(<ElicitRoot store={store}></ElicitRoot>, elt);
};

export default onload;


