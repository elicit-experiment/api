import PropTypes from 'prop-types'
import React from 'react';
import ReactDataGrid from 'react-data-grid';
const { Editors, Toolbar } = require('react-data-grid-addons');
const { DropDownEditor } = Editors;
import UserConstants from '../../../constants/UserConstants';
import update from 'react-addons-update';
import elicitApi from "../../../api/elicit-api";
import {connect} from "react-redux";
import {UserType} from "../../../types";

const COLUMNS = [
  {
    key: 'id',
    name: 'ID',
    width: 80,
    resizable: true,
  },
  {
    key: 'name',
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
    console.log(`CNT ${this.state.rows.length + 2}`)
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
    if (index < 0 || index > this.getSize()) {
      return undefined;
    }

    return this.state.rows[index];
  }

  render() {
    if (!this.props.users.sync){
      if (!this.props.users.loading && !this.props.users.error) {
        this.props.loadUsers();
      }
      return <div>Loading.</div>;
    }

    return (
      <div>
        <h1>{this.getSize()} Users</h1>
        <ReactDataGrid
        ref={ node => this.grid = node }
        enableCellSelect={true}
        columns={this.getColumns()}
        rowGetter={this.getRowAt.bind(this)}
        rowsCount={this.getSize()}
        onGridRowsUpdated={this.handleGridRowsUpdated.bind(this)}
        toolbar={<Toolbar addRowButtonText={<span><i className="fas fa-plus"></i> Add User</span>} onAddRow={this.handleAddRow.bind(this)}/>}
        enableRowSelect={true}
        rowHeight={50}
        minHeight={600}
        rowScrollTimeout={200} />
      </div>
      );
  }

  static getDerivedStateFromProps(nextProps, prevState) {
    const combinedRows = [...prevState.rows, ...nextProps.users.data].sort((a, b) => (a.id - b.id));
    const rows = combinedRows.slice(1).reduce((accumulatedRows, currentElement) => {
      const lastAccum = accumulatedRows[accumulatedRows.length - 1];
      if (lastAccum.id !== currentElement.id) {
        return [...accumulatedRows, currentElement];
      } else {
        if (lastAccum.updated_at > currentElement.updated_at) {
          return accumulatedRows;
        }
        return accumulatedRows.splice((accumulatedRows.length - 1), 1, currentElement)
      }
    }, combinedRows.slice(0,1)).filter(Boolean);

    return { rows };
  }
}

UserList.propTypes = {
  loadUsers: PropTypes.func,
  createUser: PropTypes.func,
  updateUser: PropTypes.func,
  deleteUser: PropTypes.func,
  users: PropTypes.arrayOf(UserType),
}

const UserManagement = (props) => (
  <div>
    <UserList users={ {users: props.users } } {...props} ></UserList>
  </div>
);

UserManagement.propTypes = {
  users: PropTypes.arrayOf(UserType),
}

const mapStateToProps = (state) => ({
  users: state.users,
});

const mapDispatchToProps = (dispatch) => ({
  loadUsers: () => dispatch(elicitApi.actions.users()),
  createUser: (user) => { console.log(elicitApi); return dispatch(elicitApi.actions.user.post({}, {body: JSON.stringify({user})})) },
  updateUser: (user_id, user) => dispatch(elicitApi.actions.user.patch({id: user_id}, { body: JSON.stringify(user) })),
  deleteUser: (user_id) => dispatch(elicitApi.actions.user.delete({id: user_id})),
});

export default connect(mapStateToProps, mapDispatchToProps)(UserManagement)
