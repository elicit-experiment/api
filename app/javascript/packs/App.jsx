import React from 'react'
import ReactDOM from 'react-dom'
import { BrowserRouter } from 'react-router-dom'
import { Header, AdminApp } from './components/AdminApp'

document.addEventListener('DOMContentLoaded', () => {
  var elt = document.getElementById('admin-app')
  console.dir(elt)
  ReactDOM.render((
      <AdminApp />
  ), elt)
})

