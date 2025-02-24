import PropTypes from 'prop-types'
import React, { useEffect, useState, useRef } from 'react';
import ReactDataGrid from 'react-data-grid';
const { Editors, Toolbar } = require('react-data-grid-addons');
const { DropDownEditor } = Editors;
import UserConstants from '../../../constants/UserConstants';
import update from 'react-addons-update';
import elicitApi from "../../../api/elicit-api";
import { useDispatch, useSelector } from "react-redux";
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

const UserList = ({ users }) => {
  const dispatch = useDispatch();
  const [rows, setRows] = useState([]);
  const gridRef = useRef(null);

  const getColumns = () => {
    let clonedColumns = COLUMNS.slice();
    clonedColumns[2].events = {
      onClick: (_ev, args) => {
        const idx = args.idx;
        const rowIdx = args.rowIdx;
        gridRef.current.openCellEditor(rowIdx, idx);
      },
    };
    return clonedColumns;
  };

  const handleGridRowsUpdated = ({ fromRow, toRow, updated }) => {
    let newRows = rows.slice();
    for (let i = fromRow; i <= toRow; i++) {
      let rowToUpdate = newRows[i];
      let updatedRow = update(rowToUpdate, {$merge: updated});
      dispatch(elicitApi.actions.user.patch(
        {id: updatedRow.id}, 
        { body: JSON.stringify({user: updatedRow}) }
      ));
      newRows[i] = updatedRow;
    }
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

  const getSize = () => rows.length;

  const getRowAt = (index) => {
    const lastLoadedRow = users.currentPage * users.pageSize;

    // Time to load more rows?
    if (users.sync && !users.loading) {
      const target = Math.min(index + users.pageSize, users.totalItems);  // don't try to load past end of data
      if (target > lastLoadedRow) {
        console.log("Triggered reload at getRow " + index);
        dispatch(elicitApi.actions.users_paginated.loadNextPage());
      }
    }

    // Return the row if we have it
    if (index < getSize()) {
      return rows[index];
    } else {
      return emptyRow();
    }
  };

  const emptyRow = () => ({
    auto_created: null,
    created_at: null,
    email: null,
    id: null,
    role: null,
    updated_at: null,
    username: null,
  });

  const ensureUsersLoaded = () => {
    if (!users.sync) {
      if (!users.loading && !users.error) {
        dispatch(elicitApi.actions.users_paginated.loadNextPage());
      }
    }
  };

  useEffect(() => {
    ensureUsersLoaded();
  }, []);

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
        if (lastAccum.updated_at < currentElement.updated_at) {
          accumulatedRows.splice((accumulatedRows.length - 1), 1, currentElement)
        }
        return accumulatedRows;
      }
    }, combinedRows.slice(0,1)).filter(Boolean);

    setRows(newRows);
  }, [users?.data]);

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
      <ReactDataGrid
        ref={gridRef}
        onChange={x => console.log(x)}
        enableCellSelect={true}
        columns={getColumns()}
        rowGetter={getRowAt}
        rowsCount={getSize()}
        onGridRowsUpdated={handleGridRowsUpdated}
        toolbar={<Toolbar addRowButtonText={<span><i className="fas fa-plus"></i> Add User</span>} onAddRow={handleAddRow}/>}
        enableRowSelect={true}
        rowHeight={50}
        minHeight={(Math.floor(window.innerHeight*0.65/50)*50)}
        rowScrollTimeout={200}
      />
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
