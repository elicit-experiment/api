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
import API from './API'

const CHANGE_EVENT = 'change';

// Define the store as an empty array
let _store = {}

// Define the public event listeners and getters that
// the views will use to listen for changes and retrieve
// the store
class StoreBase extends EventEmitter {

  constructor(props) {
    super()
    this.props = props
    this.api = new API(props)

    if (!_store.hasOwnProperty(props.store_name)) {
      _store[props.store_name] = {
        list: [],
        editing: false,
      };
    }

    this.store = _store[props.store_name]
  }

  loadItems() {
    let success = (dataFromServer) => {
      if (dataFromServer) {
        this.store.list = dataFromServer
        this.emit(CHANGE_EVENT)
      }
    }
    this.api.get(success, (e) => {})
  }

  newItem(item) {
    let success = (dataFromServer) => {
      console.dir(dataFromServer)
      if (dataFromServer) {
        this.store.list = this.store.list.concat(dataFromServer)
        this.emit(CHANGE_EVENT)
      }
    }
    this.api.post(item, success, (e) => {})
  }

  removeItem(id) {
    let success = (dataFromServer) => {
      /*
            let index = _store.list.findIndex((x) => {
              return x.id == id
            })
            _store.list.splice(index, 1)
      */
      this.store.list = this.store.list.filter((s) => {
        return s.id !== id
      })
      console.dir(this.store.list)
      this.emit(CHANGE_EVENT)
    }
    this.api.remove(success, (e) => {})
  }

  updateItem(newItem) {
    let success = (dataFromServer) => {
      let index = this.store.list.findIndex((x) => {
        return x.id == newItem.id
      })

      this.store.list = update(this.store.list, {
        $splice: [
          [index, 1, newItem]
        ]
      });
      console.dir(this.store.list)
      this.emit(CHANGE_EVENT)
    }
    this.api.update(success, (e) => {})
  }

  addChangeListener(cb) {
    this.on(CHANGE_EVENT, cb)
  }

  removeChangeListener(cb) {
    this.removeListener(CHANGE_EVENT, cb);
  }

  getList() {
    return this.store;
  }
}

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
      ProtocolStore.emit(CHANGE_EVENT);
      break;
    default:
      return true;
  }
});

export default StoreBase;