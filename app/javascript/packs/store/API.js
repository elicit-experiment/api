import $ from 'jquery'
import _ from 'lodash'

const BASE_API_URL = "/api/v1"

class API {
  constructor(props) {
    this.props = props
    this.json = {
      dataType: 'json',
      contentType: "application/json; charset=utf-8"
    }
  }

  get(success, failure) {
    let url = `${BASE_API_URL}/${this.props.resource}.json`
    console.log(`GET: ${url}`)
    let req = $.ajax(_.extend({
      type: 'GET',
      url: url,
      data: JSON.stringify({}),
      success: success,
      failure: failure
    }, this.json))
  }

  post(x, success, failure) {
    let url = `${BASE_API_URL}/${this.props.resource}.json`
    console.log(`POST ${url}`)
    console.dir(x)
    let req = $.ajax(_.extend({
      type: 'POST',
      url: url,
      data: JSON.stringify(x),
      success: success,
      failure: failure
    }, this.json))
  }

  remove(id, success, failure) {
    let url = `${BASE_API_URL}/${this.props.resource}/${id}`
    console.log(`DELETE: ${url}`)
    let req = $.ajax(_.extend({
      type: 'DELETE',
      data: '{}',
      url: url,
      success: success,
      failure: failure
    }, this.json))
  }

  update(newItem, success, failure) {
    console.dir(newItem)

    var putItem = JSON.parse(JSON.stringify(newItem))
    delete putItem['id']
    delete putItem['created_at']
    delete putItem['updated_at']
    let req = $.ajax(_.extend({
      type: 'PUT',
      url: `${BASE_API_URL}/${this.props.resource}/${newItem.id}`,
      data: putItem,
      success: success,
      failure: failure
    }, this.json))
  }
}

export default API