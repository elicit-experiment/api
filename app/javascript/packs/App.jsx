import React from 'react'
import ReactDOM from 'react-dom'
import { BrowserRouter } from 'react-router-dom'
import { Header, AdminApp } from './components/Main'

document.addEventListener('DOMContentLoaded', () => {
  var elt = document.getElementById('admin-app')
  console.dir(elt)
  ReactDOM.render((
    <BrowserRouter>
      <AdminApp />
    </BrowserRouter>
  ), elt)
  var hdr = document.getElementById('admin-nav')
  ReactDOM.render((
    <BrowserRouter>
      <Header />
    </BrowserRouter>
  ), hdr)
})

