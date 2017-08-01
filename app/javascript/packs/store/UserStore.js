// Study store
//
// Requiring the Dispatcher, Constants, and
// event emitter dependencies
import AppDispatcher from '../dispatcher/app_dispatcher';
import {
  SoreConstants
} from '../constants/store_constants';
import {
  EventEmitter
} from 'events';
import $ from 'jquery';
import update from 'react-addons-update'

const CHANGE_EVENT = 'change';

// Define the store as an empty array
let _store = {
  list: [],
  editing: false,
};

const userRootPath = "/users.json"
const userPath = (id) => {
  return `/users/${id}`
}

// Define the public event listeners and getters that
// the views will use to listen for changes and retrieve
// the store
class UserStoreClass extends EventEmitter {

  loadItems() {
    var loadRequest = $.ajax({
      type: 'GET',
      ifModified: true,
      url: userRootPath
    })
    loadRequest.done((dataFromServer, status) => {
      if (status == 'success') {
        if (dataFromServer) {
          _store.list = dataFromServer
          this.emit(CHANGE_EVENT)
        }
      } else {
        console.warn("GET of users: " + status)
      }
    })
  }

  newItem(x) {
    var postRequest = $.ajax({
      type: 'POST',
      dataType: 'json',
      contentType: "application/json; charset=utf-8",
      data: JSON.stringify(x, null, 2),
      url: userRootPath
    })
    postRequest.done((dataFromServer) => {
      console.dir(dataFromServer)
      if (dataFromServer) {
        _store.list = _store.list.concat(dataFromServer)
        this.emit(CHANGE_EVENT)
      }
    })
  }

  removeItem(id) {
    var loadRequest = $.ajax({
      type: 'DELETE',
      data: '{}',
      url: userPath(id)
    })
    loadRequest.done((dataFromServer) => {
      /*
            let index = _store.list.findIndex((x) => {
              return x.id == id
            })
            _store.list.splice(index, 1)
      */
      _store.list = _store.list.filter((s) => {
        return s.id !== id
      })
      console.dir(_store.list)
      this.emit(CHANGE_EVENT)
    })
  }

  updateItem(newItem) {
    console.dir(newItem)

    var putItem = JSON.parse(JSON.stringify(newItem))
    delete putItem['id']
    delete putItem['created_at']
    delete putItem['updated_at']
    var loadRequest = $.ajax({
      type: 'PUT',
      dataType: 'json',
      contentType: "application/json; charset=utf-8",
      data: JSON.stringify(putItem, null, 2),
      url: userPath(newItem.id)
    })
    loadRequest.done((dataFromServer) => {

      let index = _store.list.findIndex((x) => {
        return x.id == newItem.id
      })

      _store.list = update(_store.list, {
        $splice: [
          [index, 1, newItem]
        ]
      });
      console.dir(_store.list)
      this.emit(CHANGE_EVENT)
    })

  }

  addChangeListener(cb, handlerContext) {
    this.on(CHANGE_EVENT, cb, handlerContext)
  }

  removeChangeListener(cb) {
    this.removeListener(CHANGE_EVENT, cb);
  }

  getList() {
    return _store;
  }

}

// Initialize the singleton to register with the
// dispatcher and export for React components
const UserStore = new UserStoreClass();

export default UserStore;