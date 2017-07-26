// Study store
//
// Requiring the Dispatcher, Constants, and
// event emitter dependencies
import AppDispatcher from '../dispatcher/app_dispatcher';
import {
  TodoConstants
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

// Define the public event listeners and getters that
// the views will use to listen for changes and retrieve
// the store
class StudyStoreClass extends EventEmitter {

  loadItems() {
    var loadRequest = $.ajax({
      type: 'GET',
      url: "/studies.json"
    })
    loadRequest.done((dataFromServer) => {
      if (dataFromServer) {
        _store.list = dataFromServer
        this.emit(CHANGE_EVENT)
      }
    })
  }

  newItem(x) {
    var postRequest = $.ajax({
      type: 'POST',
      dataType: 'json',
      contentType: "application/json; charset=utf-8",
      data: JSON.stringify(x, null, 2),
      url: "/studies.json"
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
      url: "/studies/" + id
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
      url: "/studies/" + newItem.id // + ".json"
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

  addChangeListener(cb) {
    this.on(CHANGE_EVENT, cb)
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
const StudyStore = new StudyStoreClass();

// Register each of the actions with the dispatcher
// by changing the store's data and emitting a
// change
AppDispatcher.register((payload) => {
  const action = payload.action;

  switch (action.actionType) {

    case TodoConstants.NEW_ITEM:

      // Add the data defined in the TodoActions
      // which the View will pass as a payload
      _store.editing = true;
      StudyStore.emit(CHANGE_EVENT);
      break;

      /*
        case TodoConstants.SAVE_ITEM:

          // Add the data defined in the TodoActions
          // which the View will pass as a payload
          _store.list.push(action.text);
          _store.editing = false;
          TodoStore.emit(CHANGE_EVENT);
          break;

        case TodoConstants.REMOVE_ITEM:

          // View should pass the text's index that
          // needs to be removed from the store
          _store.list = _store.list.filter((item, index) => {
            return index !== action.index;
          });
          TodoStore.emit(CHANGE_EVENT);
          break;

        case TodoConstants.GET_RANDOM_RESPONSE:

          // Construct the new todo string
          const firstName = action.response.results[0].user.name.first;
          const city = action.response.results[0].user.location.city;
          const newTodo = `Call ${firstName} about real estate in ${city}`;

          // Add the new todo to the list
          _store.list.push(newTodo);
          TodoStore.emit(CHANGE_EVENT);
          break;
      */
    default:
      return true;
  }
});

export default StudyStore;