import React from 'react'
import ReactDataGrid from 'react-data-grid'
const { Editors, Toolbar, Formatters } = require('react-data-grid-addons');
const { AutoComplete: AutoCompleteEditor, DropDownEditor } = Editors;
const { ImageFormatter } = Formatters;
import UserConstants from '../constants/UserConstants'
import update from 'react-addons-update'

class UserList extends React.Component {
  constructor(props) {
    super(props)
    this.rows = []
    this.state = this.props.users || { rows: [] }
    this._columns = [
      {
        key: 'id',
        name: 'ID',
        width: 80,
        resizable: true
      },
      {
        key: 'name',
        name: 'Name',
        editable: true,
        width: 200,
        resizable: true
      },
      {
        key: 'email',
        name: 'Email',
        editable: true,
        width: 200,
        resizable: true
      },
      {
        key: 'role',
        name: 'Role',
        editor: <DropDownEditor options={UserConstants.roles}/>,
        editable: true,
        width: 200,
        resizable: true
      },
    ];
  }

  rowGetter(i) {
    return this._rows[i];
  }

  getColumns() {
    let clonedColumns = this._columns.slice();
    clonedColumns[2].events = {
      onClick: (ev, args) => {
        const idx = args.idx;
        const rowIdx = args.rowIdx;
        this.grid.openCellEditor(rowIdx, idx);
      }
    };

    return clonedColumns
  }

  handleGridRowsUpdated({ fromRow, toRow, updated }) {
    let rows = this.state.rows.slice();
    for (let i = fromRow; i <= toRow; i++) {
      let rowToUpdate = rows[i];
      let updatedRow = /* React.addons.*/update(rowToUpdate, {$merge: updated});
      UserStore.updateItem(updatedRow)
      rows[i] = updatedRow;
    }

//    this.setState({ rows });
  }

  handleAddRow({ newRowIndex }) {
    const newRow = {
      email: 'test@example.com',
      name: 'New User',
      role: 'registered_user'
    }
    UserStore.newItem(newRow);

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
    console.dir(this)
    UserStore.loadItems()
    UserStore.on('change', this.handleChangedEvent.bind(this), this);
  }

  handleChangedEvent(event) {
    let users = {rows: UserStore.getList().list }
    this.setState(users)
  }
}

const UserManagement = () => (
  <div>
    <UserList users={ {rows: UserStore.getList().list } } ></UserList>
  </div>
)

export default UserManagement