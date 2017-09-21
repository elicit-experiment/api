import $ from 'jquery'
import _ from 'lodash'

const api_root = 'http://localhost:3000/api/v1'
const public_client_id = 'admin_public'
const public_client_secret = 'czZCaGRSa3F0MzpnWDFmQmF0M2JW'
const default_headers = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
}

const handleResponse = (response) => {
  if (response.ok) {
    return response.json();
  }
  console.dir(response)
  throw new Error(`Network response was not ok: ${response.status} ${response.statusText}`);
}

const fetchToken = (request, headers = {}) => (
  fetch(api_root + '/oauth/token', {
    method: 'POST',
    headers: _.extend(default_headers, headers),
    body: JSON.stringify(request)
  })
  .then(handleResponse)
)

export const fetchClientToken = (success, error) => {
  let token_request = {
    client_id: public_client_id,
    client_secret: public_client_secret,
    grant_type: 'client_credentials'
  };
  return fetchToken(token_request)
};

export const fetchUserToken = (credentials, success, error) => {
  let token_request = _.extend({
    client_id: public_client_id,
    client_secret: public_client_secret,
    grant_type: 'password'
  }, credentials)
  return fetchToken(token_request)
};

export const fetchRefreshUserToken = (access_token, refresh_token, success, error) => {
  console.log("REFRESH")
  let token_request = _.extend({
    client_id: public_client_id,
    client_secret: public_client_secret,
    grant_type: 'refresh_token',
    refresh_token: refresh_token
  })
  return fetchToken(token_request, {
    Authorization: `Bearer ${access_token}`
  })
};