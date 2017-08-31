import $ from 'jquery'
import _ from 'lodash'

const api_root = 'http://localhost:3000/api/v1'

export const fetchClientToken = (success, error, callback) => {
  //Maybe the client_id and client_secret should be set in Environment Variables?
  // For my Mac
  // let data = {client_id: 'ae9c39a4d82fa28a51f0bae942b8e94fe1cec131e2131acb11bcd55a505f023e',
  //               client_secret: '3ddba5c35e65e7d41546ad48c23b983f309ec2ae63bc5ab91ba9a5325a597842',
  //               grant_type: 'client_credentials'};
  // For Ubuntu:
  // let data = {client_id: 'eec6c6a7e4d93dd0337aa5f0e708f1677f448286db15436c93388a8f33649ef6',
  //              client_secret: '7a7e7dae305055c73d5638f3df3321cafd113257ac14311687dc8799c3fca249',
  //              grant_type: 'client_credentials'};
  //For Heroku:
  let data = {
    client_id: 'admin_public',
    client_secret: 'czZCaGRSa3F0MzpnWDFmQmF0M2JW',
    grant_type: 'client_credentials'
  };
  $.ajax({
    method: 'POST',
    crossDomain: true,
    url: api_root + '/oauth/token',
    data: data,
    success: (token) => {
      success(token);
      callback();
    },
    error
  });
};

export const fetchUserToken = (credentials, success, error) => {
  //Maybe the client_id and client_secret should be set in Environment Variables?
  // For my Mac:
  // let params = {client_id: 'ae9c39a4d82fa28a51f0bae942b8e94fe1cec131e2131acb11bcd55a505f023e',
  //               client_secret: '3ddba5c35e65e7d41546ad48c23b983f309ec2ae63bc5ab91ba9a5325a597842',
  //               grant_type: 'password',
  //               username: credentials.userName,
  //               password: credentials.password};
  // For Ubuntu:
  // let params = {client_id: 'eec6c6a7e4d93dd0337aa5f0e708f1677f448286db15436c93388a8f33649ef6',
  //              client_secret: '7a7e7dae305055c73d5638f3df3321cafd113257ac14311687dc8799c3fca249',
  //              grant_type: 'password',
  //              username: credentials.userName,
  //              password: credentials.password};
  // For Heroku:
  let params = {
    client_id: '203ba57855d4a4debfd0ed87c19539b12123b644d6433a5c2bb4fb5b0f7db94c',
    client_secret: 'f5822b7a1d308fb5a5f60d94516c9b3a416fb4a37f22127c727fcf7f3d7bd76f',
    grant_type: 'password',
    username: credentials.userName,
    password: credentials.password
  };
  $.ajax({
    method: 'POST',
    crossDomain: true,
    url: api_root + '/oauth/token',
    data: params,
    success,
    error
  });
};