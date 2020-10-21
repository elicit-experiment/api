/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import jquery from 'jquery'

// madness: https://stackoverflow.com/questions/40288268/using-jquery-and-bootstrap-with-es6-import-for-react-app
window.$ = jquery;
window.jQuery = jquery;
window.jquery = jquery;

import Loader from '../Loader.jsx'

document.addEventListener("DOMContentLoaded", Loader);
