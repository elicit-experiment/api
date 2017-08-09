import StoreBase from './StoreBase';

const UserStore = new StoreBase({
  resource: 'users',
  store_name: 'users'
})
export default UserStore;