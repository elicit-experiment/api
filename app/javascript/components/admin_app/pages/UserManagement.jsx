import React, { useEffect, useState } from 'react';
import DataGrid from 'react-data-grid';
import { textEditor } from 'react-data-grid';

import UserConstants from '../../../constants/UserConstants';
import update from 'react-addons-update';
import elicitApi from "../../../api/elicit-api";
import { useDispatch, useSelector } from "react-redux";
import {ApiReturnCollectionOf, UserType} from "../../../types";
import 'react-data-grid/lib/styles.css';

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
    renderEditCell: textEditor,
    renderCell({ row }) {
      if (row.syncing) { return <i className="fas fa-sync fa-spin"/> }
      return <div>{row.username}</div>;
    },
    editable: true,
    width: 200,
    resizable: true,
  },
  {
    key: 'email',
    name: 'Email',
    renderEditCell: textEditor,
    renderCell({ row }) {
      if (row.syncing) { return <i className="fas fa-sync fa-spin"/> }
      return <div>{row.email}</div>;
    },
    editable: true,
    width: 200,
    resizable: true,
  },
  {
    key: 'role',
    name: 'Role',
    //editor: <DropDownEditor options={UserConstants.roles}/>,
    renderEditCell({ row, onRowChange }) {
      return (
        <select
          className={''}
          value={row.role}
          onChange={(event) => onRowChange({ ...row, role: event.target.value }, true)}
          autoFocus
        >
          {UserConstants.roles.map((role) => (
            <option key={role} value={role}>
              {role}
            </option>
          ))}
        </select>
      );
    },
    renderCell({ row }) {
      if (row.syncing) { return <i className="fas fa-sync fa-spin"/> }
      return <div>{row.role}</div>;
    },
    editable: true,
    width: 200,
    resizable: true,
  },
  {
    key: 'auto_created',
    name: 'How Created?',
    renderCell({ row }) {
      if (row.syncing) { return <i className="fas fa-sync fa-spin"/> }

      const text = (row.value ? 'Auto Created' : 'Investigator Specified');
      return <div>{text}</div>;
    },
    editable: false,
    width: 200,
    resizable: true,
  },
];

const UserList = ({ users }) => {
  const dispatch = useDispatch();
  const [rows, setRows] = useState([]);

  const getColumns = () => {
    let clonedColumns = COLUMNS.slice();
    return clonedColumns;
  };

  const handleGridRowsUpdated = (updatedRows, rowChangeData) => {
    console.dir(updatedRows)
    console.dir(rowChangeData)

    rowChangeData.indexes.forEach((index) => {
      const updatedRow = updatedRows[index];
      const localSyncingRow = update(updatedRow, {$merge: { syncing: true }});
      dispatch(elicitApi.actions.user.patch(
        { id: updatedRow.id },
        { body: JSON.stringify({user: updatedRow}) }
      ));
      updatedRows[index] = localSyncingRow;
    })

    setRows(updatedRows);
  };

  const handleAddRow = () => {
    const newRow = {
      email: `user${rows.length + 2 + Math.random(100)}@elicit.com`,
      name: 'New User',
      role: 'registered_user',
      password: 'password',
      password_confirmation: 'password',
    };
    dispatch(elicitApi.actions.user.post({}, {body: JSON.stringify({user: newRow})}));
    newRow.id = 0;
  };

  const handleFetchMore = () => {
    dispatch(elicitApi.actions.users_paginated.loadNextPage());
  }

  useEffect(() => {
    if (!users?.data) return;

    const combinedRows = [...rows, ...users.data].sort((a, b) => (a.id - b.id));
    if (combinedRows.length < 2) {
      setRows(combinedRows);
      return;
    }

    const newRows = combinedRows.slice(1).reduce((accumulatedRows, currentElement) => {
      const lastAccum = accumulatedRows[accumulatedRows.length - 1];
      if (lastAccum.id !== currentElement.id) {
        return [...accumulatedRows, currentElement];
      } else {
        console.log(`Updating ${currentElement.id} ${lastAccum.updated_at} / ${lastAccum.syncing} --  ${currentElement.updated_at} / ${currentElement.syncing}`)
        if (lastAccum.updated_at < currentElement.updated_at) {
          accumulatedRows.splice((accumulatedRows.length - 1), 1, currentElement)
        }
        return accumulatedRows;
      }
    }, combinedRows.slice(0,1)).filter(Boolean);

    setRows(newRows);
  }, [users?.data]);


  // Initial load of rows.
  useEffect(() => {
    if (users.sync) { return }
    if (users.loading) { return }
    if (users.error) { return }

    dispatch(elicitApi.actions.users_paginated.loadNextPage());
  }, [users.sync, users.loading])


  if (!users.sync && rows.length === 0) {
    if (!users.loading && users.error) {
      return <div>Error. Please reload page and contact support if this problem persists.</div>;
    }
    return <div>Loading.</div>;
  }

  const loadingGlyph = users.loading ?
    <span style={{fontSize: '50%', opacity: 0.6}}><i className="fas fa-sync"></i></span> : '';

  return (
    <div>
      <h1>{users.totalItems} Users {loadingGlyph}</h1>
      <div><button className="btn btn-info mb-sm-2" onClick={handleAddRow}><i className="fas fa-plus"></i> Add User</button></div>
      <DataGrid
        enableCellSelect={true}
        columns={getColumns()}
        rows={rows}
        rowKeyGetter={(row) => row.id}
        onRowsChange={handleGridRowsUpdated}
        rowHeight={50}
        minHeight={(Math.floor(window.innerHeight*0.65/50)*50)}
        rowScrollTimeout={200}
      />
      <div className="d-flex justify-content-end">
        <button className="btn btn-info mt-sm-2" onClick={handleFetchMore}><i className="fas fa-download"></i>Fetch More
        </button>
      </div>
    </div>
  );
};

UserList.propTypes = {
  users: ApiReturnCollectionOf(UserType),
};


const UserManagement = () => {
  const users = useSelector(state => state.users_paginated);

  return (
    <div>
      <UserList users={users} />
    </div>
  );
};

export default UserManagement;
