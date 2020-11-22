import PropTypes from 'prop-types'
import React from 'react';
import ReactDataGrid from 'react-data-grid';
const { Editors, Toolbar } = require('react-data-grid-addons');
const { DropDownEditor } = Editors;
import UserConstants from '../../constants/UserConstants';
import update from 'react-addons-update';
import elicitApi from "../../api/elicit-api";
import {connect} from "react-redux";
import {UserType} from "../../types";

class UserList extends React.Component {
  constructor(props) {
    super(props);
    this.rows = [];
    console.dir(props.users);
    this.state = { rows: this.props.users || [] };
    this._columns = [
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
    ];
  }

  rowGetter(i) {
    return this._rows[i];
  }

  getColumns() {
    let clonedColumns = this._columns.slice();
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
      let updatedRow = /* React.addons.*/update(rowToUpdate, {$merge: updated});
      this.props.updateUser(updatedRow.id, updatedRow);
      rows[i] = updatedRow;
    }

//    this.setState({ rows });
  }

  handleAddRow() { // ({ newRowIndex }) {
    const newRow = {
      email: 'test@example.com',
      name: 'New User',
      role: 'registered_user',
    };
    this.props.createUser(newRow);

//    let rows = this.state.rows.slice();
//    rows = /* React.addons.*/update(rows, {$push: [newRow]});
//   this.setState({ rows });
  }

  getSize() {
    if (!this.state || !this.state.rows) {
      return 0
    }
    return this.state.rows.length
  }

  getRowAt(index) {
    if (index < 0 || index > this.getSize()) {
      return undefined;
    }

    return this.state.rows[index];
  }

  render() {
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
        toolbar={<Toolbar onAddRow={this.handleAddRow.bind(this)}/>}
        enableRowSelect={true}
        rowHeight={50}
        minHeight={600}
        rowScrollTimeout={200} />
      </div>
      );
  }

  componentDidMount() {
    this.props.loadUsers();
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
  users: state.users.data,
});

const mapDispatchToProps = (dispatch) => ({
  loadUsers: () => dispatch(elicitApi.actions.users()),
  createUser: (user) => dispatch(elicitApi.actions.users.post(user)),
  updateUser: (user_id, user) => dispatch(elicitApi.actions.protocol_definition.patch({id: user_id}, { body: JSON.stringify(user) })),
  deleteUser: (user_id) => dispatch(elicitApi.actions.protocol_definition.delete({id: user_id})),
});

export default connect(mapStateToProps, mapDispatchToProps)(UserManagement)
