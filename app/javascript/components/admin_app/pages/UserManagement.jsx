import PropTypes from 'prop-types'
import React from 'react';
import ReactDataGrid from 'react-data-grid';
const { Editors, Toolbar } = require('react-data-grid-addons');
const { DropDownEditor } = Editors;
import UserConstants from '../../../constants/UserConstants';
import update from 'react-addons-update';
import elicitApi from "../../../api/elicit-api";
import {connect} from "react-redux";
import {ApiReturnCollectionOf, UserType} from "../../../types";

const COLUMNS = [
  {
    key: 'id',
    name: 'ID',
    width: 80,
    resizable: true,
  },
  {
    key: 'username',
    name: 'Name',
    editable: true,
    width: 200,
    resizable: true,
  },
  {
    key: 'email',
    name: 'Email',
    editable: true,
    width: 200,
    resizable: true,
  },
  {
    key: 'role',
    name: 'Role',
    editor: <DropDownEditor options={UserConstants.roles}/>,
    editable: true,
    width: 200,
    resizable: true,
  },
  {
    key: 'auto_created',
    name: 'How Created?',
    formatter: (col) => (col.value ? 'Auto Created' : 'Investigator Specified'),
    editable: false,
    width: 200,
    resizable: true,
  },
];

class UserList extends React.Component {
  constructor(props) {
    super(props);
    this.state = { rows: [] };
  }
//    this.props.reset();
  getColumns() {
    let clonedColumns = COLUMNS.slice();
    clonedColumns[2].events = {
      onClick: (_ev, args) => {
        const idx = args.idx;
        const rowIdx = args.rowIdx;
        this.grid.openCellEditor(rowIdx, idx);
      },
    };

    return clonedColumns
  }

  handleGridRowsUpdated({ fromRow, toRow, updated }) {
    let rows = this.state.rows.slice();
    for (let i = fromRow; i <= toRow; i++) {
      let rowToUpdate = rows[i];
      let updatedRow = update(rowToUpdate, {$merge: updated});
      this.props.updateUser(updatedRow.id, updatedRow);
      rows[i] = updatedRow;
    }

//    this.setState({ rows });
  }

  handleAddRow() { // ({ newRowIndex }) {
    const newRow = {
      email: `user${this.state.rows.length + 2 + Math.random(100)}@elicit.com`,
      name: 'New User',
      role: 'registered_user',
      password: 'password',
      password_confirmation: 'password',
    };
    this.props.createUser(newRow);
    newRow.id = 0;
    /*
    const rows = update(this.state.rows, {$push: [newRow]});
    this.setState({ rows });
     */
  }

  getSize() {
    return this.state.rows.length
  }

  getRowAt(index) {
    const lastLoadedRow = this.props.users.currentPage * this.props.users.pageSize;

    // Time to load more rows?
    if (this.props.users.sync && !this.props.users.loading ) {
      const target = Math.min(index + this.props.users.pageSize, this.props.users.totalItems);  // don't try to load past end of data
      if (target > lastLoadedRow) {
        console.log("Triggered reload at getRow " + index);
        this.props.loadNext();
      }
    }

    // Return the row if we have it
    if (index < this.getSize()) {
      return this.state.rows[index];
    } else {
      return this.emptyRow();
    }

  }

  emptyRow() {
    return {
      auto_created: null,
      created_at:  null,
      email:  null,
      id:  null,
      role:  null,
      updated_at:  null,
      username:  null,
    }
  }

  render() {
    if (!this.props.users.sync && this.state.rows.length === 0) {
      if (!this.props.users.loading && this.props.users.error) {
        return <div>Error. Please reload page and contact support if this problem persists.</div>;
      }
      return <div>Loading.</div>;
    }

    const loadingGlyph = this.props.users.loading ?
      <span style={{fontSize: '50%', opacity: 0.6}}><i className="fas fa-sync"></i></span> : '';


    return (
      <div>
        <h1>{this.props.users.totalItems} Users {loadingGlyph}</h1>
        <ReactDataGrid
        ref={ node => this.grid = node }
        onChange={x => console.log(x) }
        enableCellSelect={true}
        columns={this.getColumns()}
        rowGetter={this.getRowAt.bind(this)}
        rowsCount={this.getSize()}
        onGridRowsUpdated={this.handleGridRowsUpdated.bind(this)}
        toolbar={<Toolbar addRowButtonText={<span><i className="fas fa-plus"></i> Add User</span>} onAddRow={this.handleAddRow.bind(this)}/>}
        enableRowSelect={true}
        rowHeight={50}
        minHeight={(Math.floor(window.innerHeight*0.65/50)*50)}
        rowScrollTimeout={200} />
      </div>
      );
  }

  ensureUsersLoaded() {
    if (!this.props.users.sync) {
      if (!this.props.users.loading && !this.props.users.error) {
        this.props.loadNext();
      }
    }
  }

  componentDidMount() {
    // this.reset();
    this.ensureUsersLoaded()
  }

  static getDerivedStateFromProps(nextProps, prevState) {
    if (!nextProps?.users?.data) return prevState;

    const combinedRows = [...prevState.rows, ...nextProps.users.data].sort((a, b) => (a.id - b.id));
    if (combinedRows.length < 2) { return { rows: combinedRows } }
    const rows = combinedRows.slice(1).reduce((accumulatedRows, currentElement) => {
      const lastAccum = accumulatedRows[accumulatedRows.length - 1];
      if (lastAccum.id !== currentElement.id) {
        return [...accumulatedRows, currentElement];
      } else {
        if (lastAccum.updated_at < currentElement.updated_at) {
          accumulatedRows.splice((accumulatedRows.length - 1), 1, currentElement)
        }
        return accumulatedRows;
      }
    }, combinedRows.slice(0,1)).filter(Boolean);

    return { rows };
  }
}

UserList.propTypes = {
  reset: PropTypes.func,
  loadUsers: PropTypes.func,
  loadNext: PropTypes.func,
  createUser: PropTypes.func,
  updateUser: PropTypes.func,
  deleteUser: PropTypes.func,
  users: ApiReturnCollectionOf(UserType),
}

const UserManagement = (props) => (
  <div>
    <UserList users={ {users: props.users } } {...props} ></UserList>
  </div>
);

UserManagement.propTypes = {
  users: ApiReturnCollectionOf(UserType),
}

const mapStateToProps = (state) => {
  return {
  users: state.users_paginated,
}}

const mapDispatchToProps = (dispatch) => ({
  reset: () => dispatch(elicitApi.actions.users_paginated.reset()),
  loadNext: () => dispatch(elicitApi.actions.users_paginated.loadNextPage()),
  loadUsers: () => dispatch(elicitApi.actions.users()),
  createUser: (user) => { return dispatch(elicitApi.actions.user.post({}, {body: JSON.stringify({user})})) },
  updateUser: (user_id, user) => dispatch(elicitApi.actions.user.patch({id: user_id}, { body: JSON.stringify({user}) })),
  deleteUser: (user_id) => dispatch(elicitApi.actions.user.delete({id: user_id})),
});

export default connect(mapStateToProps, mapDispatchToProps)(UserManagement)
