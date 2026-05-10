import React, { useEffect, useState, useCallback } from 'react';
import DataGrid, { textEditor } from 'react-data-grid';
import Modal from 'react-bootstrap/Modal';
import Button from 'react-bootstrap/Button';

import UserConstants from '../../../constants/UserConstants';
import update from 'react-addons-update';
import elicitApi from '../../../api/elicit-api';
import { useDispatch, useSelector } from 'react-redux';
import { ApiReturnCollectionOf, UserType } from '../../../types';
import { useDebounce } from '../../../utils/useDebounce';
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
    sortable: true,
    renderEditCell: textEditor,
    renderCell({ row }) {
      if (row.syncing) {
        return <i className="fas fa-sync fa-spin" />;
      }
      return <div>{row.username}</div>;
    },
    editable: true,
    width: 200,
    resizable: true,
  },
  {
    key: 'email',
    name: 'Email',
    sortable: true,
    renderEditCell: textEditor,
    renderCell({ row }) {
      if (row.syncing) {
        return <i className="fas fa-sync fa-spin" />;
      }
      return <div>{row.email}</div>;
    },
    editable: true,
    width: 200,
    resizable: true,
  },
  {
    key: 'role',
    name: 'Role',
    sortable: true,
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
      if (row.syncing) {
        return <i className="fas fa-sync fa-spin" />;
      }
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
      if (row.syncing) {
        return <i className="fas fa-sync fa-spin" />;
      }
      const text = row.auto_created ? 'Auto Created' : 'Investigator Specified';
      return <div>{text}</div>;
    },
    editable: false,
    width: 180,
    resizable: true,
  },
  {
    key: 'created_at',
    name: 'Created',
    sortable: true,
    renderCell({ row }) {
      if (row.syncing) {
        return <i className="fas fa-sync fa-spin" />;
      }
      return <div>{row.created_at ? new Date(row.created_at).toLocaleDateString() : ''}</div>;
    },
    editable: false,
    width: 140,
    resizable: true,
  },
];

const PaginationControls = ({ currentPage, totalPages, totalItems, pageSize, onPageChange }) => {
  if (totalPages <= 0) return null;

  const startItem = (currentPage - 1) * pageSize + 1;
  const endItem = Math.min(currentPage * pageSize, totalItems);

  const getPageNumbers = () => {
    const pages = [];
    const maxVisible = 7;

    if (totalPages <= maxVisible) {
      for (let i = 1; i <= totalPages; i++) {
        pages.push(i);
      }
    } else {
      pages.push(1);
      if (currentPage > 3) pages.push('...');

      const start = Math.max(2, currentPage - 1);
      const end = Math.min(totalPages - 1, currentPage + 1);

      for (let i = start; i <= end; i++) {
        pages.push(i);
      }

      if (currentPage < totalPages - 2) pages.push('...');
      pages.push(totalPages);
    }

    return pages;
  };

  return (
    <div className="d-flex justify-content-between align-items-center mt-3">
      <span className="text-muted">
        Showing {startItem}&ndash;{endItem} of {totalItems} users
      </span>
      <nav>
        <ul className="pagination pagination-sm mb-0">
          <li className={`page-item ${currentPage === 1 ? 'disabled' : ''}`}>
            <button className="page-link" onClick={() => onPageChange(currentPage - 1)} disabled={currentPage === 1}>
              Previous
            </button>
          </li>
          {getPageNumbers().map((page, idx) => (
            <li
              key={idx}
              className={`page-item ${page === currentPage ? 'active' : ''} ${page === '...' ? 'disabled' : ''}`}
            >
              {page === '...' ? (
                <span className="page-link">...</span>
              ) : (
                <button className="page-link" onClick={() => onPageChange(page)}>
                  {page}
                </button>
              )}
            </li>
          ))}
          <li className={`page-item ${currentPage === totalPages ? 'disabled' : ''}`}>
            <button
              className="page-link"
              onClick={() => onPageChange(currentPage + 1)}
              disabled={currentPage === totalPages}
            >
              Next
            </button>
          </li>
        </ul>
      </nav>
    </div>
  );
};

const AddUserModal = ({ show, onHide, onUserCreated }) => {
  const dispatch = useDispatch();
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    role: 'registered_user',
    password: '',
    password_confirmation: '',
  });
  const [errors, setErrors] = useState({});
  const [submitting, setSubmitting] = useState(false);

  const resetForm = () => {
    setFormData({
      username: '',
      email: '',
      role: 'registered_user',
      password: '',
      password_confirmation: '',
    });
    setErrors({});
    setSubmitting(false);
  };

  const handleShow = () => {
    resetForm();
  };

  const handleChange = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    if (errors[field]) {
      setErrors((prev) => {
        const next = { ...prev };
        delete next[field];
        return next;
      });
    }
  };

  const validate = () => {
    const newErrors = {};
    if (!formData.username.trim()) newErrors.username = 'Username is required';
    if (!formData.email.trim()) newErrors.email = 'Email is required';
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) newErrors.email = 'Invalid email format';
    if (!formData.password) newErrors.password = 'Password is required';
    else if (formData.password.length < 8) newErrors.password = 'Password must be at least 8 characters';
    if (formData.password !== formData.password_confirmation) newErrors.password_confirmation = 'Passwords do not match';
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validate()) return;

    setSubmitting(true);
    try {
      await dispatch(
        elicitApi.actions.user.post({}, { body: JSON.stringify({ user: formData }) }),
      );
      resetForm();
      onUserCreated();
      onHide();
    } catch {
      setErrors({ submit: 'Failed to create user. Please try again.' });
      setSubmitting(false);
    }
  };

  const handleModalHide = () => {
    resetForm();
    onHide();
  };

  return (
    <Modal show={show} onShow={handleShow} onHide={handleModalHide}>
      <form onSubmit={handleSubmit}>
        <Modal.Header closeButton>
          <Modal.Title>Add User</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          {errors.submit && (
            <div className="alert alert-danger">{errors.submit}</div>
          )}
          <div className="mb-3">
            <label htmlFor="add-user-username" className="form-label">
              Username
            </label>
            <input
              type="text"
              id="add-user-username"
              className={`form-control ${errors.username ? 'is-invalid' : ''}`}
              value={formData.username}
              onChange={(e) => handleChange('username', e.target.value)}
              autoFocus
            />
            {errors.username && <div className="invalid-feedback">{errors.username}</div>}
          </div>
          <div className="mb-3">
            <label htmlFor="add-user-email" className="form-label">
              Email
            </label>
            <input
              type="email"
              id="add-user-email"
              className={`form-control ${errors.email ? 'is-invalid' : ''}`}
              value={formData.email}
              onChange={(e) => handleChange('email', e.target.value)}
            />
            {errors.email && <div className="invalid-feedback">{errors.email}</div>}
          </div>
          <div className="mb-3">
            <label htmlFor="add-user-role" className="form-label">
              Role
            </label>
            <select
              id="add-user-role"
              className="form-select"
              value={formData.role}
              onChange={(e) => handleChange('role', e.target.value)}
            >
              {UserConstants.roles.map((role) => (
                <option key={role} value={role}>
                  {role}
                </option>
              ))}
            </select>
          </div>
          <div className="mb-3">
            <label htmlFor="add-user-password" className="form-label">
              Password
            </label>
            <input
              type="password"
              id="add-user-password"
              className={`form-control ${errors.password ? 'is-invalid' : ''}`}
              value={formData.password}
              onChange={(e) => handleChange('password', e.target.value)}
            />
            {errors.password && <div className="invalid-feedback">{errors.password}</div>}
          </div>
          <div className="mb-3">
            <label htmlFor="add-user-password-confirm" className="form-label">
              Confirm Password
            </label>
            <input
              type="password"
              id="add-user-password-confirm"
              className={`form-control ${errors.password_confirmation ? 'is-invalid' : ''}`}
              value={formData.password_confirmation}
              onChange={(e) => handleChange('password_confirmation', e.target.value)}
            />
            {errors.password_confirmation && <div className="invalid-feedback">{errors.password_confirmation}</div>}
          </div>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleModalHide}>
            Cancel
          </Button>
          <Button variant="primary" type="submit" disabled={submitting}>
            {submitting ? 'Creating...' : 'Create User'}
          </Button>
        </Modal.Footer>
      </form>
    </Modal>
  );
};

const UserList = ({ users }) => {
  const dispatch = useDispatch();
  const [rows, setRows] = useState([]);
  const [searchInput, setSearchInput] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [sortColumns, setSortColumns] = useState([]);
  const [showAddModal, setShowAddModal] = useState(false);

  const debouncedSearch = useDebounce(searchInput, 300);

  const getColumns = () => {
    return COLUMNS.slice();
  };

  const triggerLoad = useCallback(
    (params) => {
      dispatch(elicitApi.actions.users_paginated.reloadWithNewParams(params));
    },
    [dispatch],
  );

  useEffect(() => {
    const sortCol = sortColumns.length > 0 ? sortColumns[0].columnKey : 'created_at';
    const sortDir = sortColumns.length > 0 ? sortColumns[0].direction.toLowerCase() : 'desc';
    const role = roleFilter;

    triggerLoad({
      q: debouncedSearch,
      sort_column: sortCol,
      sort_direction: sortDir,
      role: role,
    });
  }, [debouncedSearch, roleFilter, sortColumns, triggerLoad]);

  useEffect(() => {
    if (!users?.data) return;
    setRows(users.data.map((user) => ({ ...user, syncing: false })));
  }, [users?.data]);

  useEffect(() => {
    if (users.sync) return;
    if (users.loading) return;
    if (users.error) return;

    triggerLoad({
      sort_column: 'created_at',
      sort_direction: 'desc',
    });
  }, [users.sync, users.loading, users.error, triggerLoad]);

  const handleGridRowsUpdated = (updatedRows, rowChangeData) => {
    rowChangeData.indexes.forEach((index) => {
      const updatedRow = updatedRows[index];
      const localSyncingRow = update(updatedRow, { $merge: { syncing: true } });
      dispatch(elicitApi.actions.user.patch({ id: updatedRow.id }, { body: JSON.stringify({ user: updatedRow }) }));
      updatedRows[index] = localSyncingRow;
    });
    setRows(updatedRows);
  };

  const handleShowAddModal = () => {
    setShowAddModal(true);
  };

  const handleHideAddModal = () => {
    setShowAddModal(false);
  };

  const handleUserCreated = () => {
    triggerLoad({
      q: debouncedSearch,
      sort_column: sortColumns.length > 0 ? sortColumns[0].columnKey : 'created_at',
      sort_direction: sortColumns.length > 0 ? sortColumns[0].direction.toLowerCase() : 'desc',
      role: roleFilter,
    });
  };

  const handlePageChange = (page) => {
    dispatch(elicitApi.actions.users_paginated.goToPage(page));
  };

  const handleSortChange = (newSortColumns) => {
    setSortColumns(newSortColumns.slice(-1));
  };

  const handleSearchChange = (e) => {
    setSearchInput(e.target.value);
  };

  const handleClearSearch = () => {
    setSearchInput('');
  };

  const handleRoleFilterChange = (e) => {
    setRoleFilter(e.target.value);
  };

  if (!users.sync && rows.length === 0) {
    if (!users.loading && users.error) {
      return <div>Error. Please reload page and contact support if this problem persists.</div>;
    }
    return <div>Loading.</div>;
  }

  const loadingGlyph = users.loading ? (
    <span style={{ fontSize: '50%', opacity: 0.6 }}>
      <i className="fas fa-sync"></i>
    </span>
  ) : (
    ''
  );

  return (
    <div>
      <h1>
        {users.totalItems} Users {loadingGlyph}
      </h1>

      <div className="d-flex gap-3 mb-3 align-items-end">
        <div className="flex-grow-1">
          <label htmlFor="user-search" className="form-label">
            Search
          </label>
          <div className="input-group">
            <input
              id="user-search"
              type="text"
              className="form-control"
              placeholder="Search by name or email..."
              value={searchInput}
              onChange={handleSearchChange}
            />
            {searchInput && (
              <button className="btn btn-outline-secondary" type="button" onClick={handleClearSearch}>
                <i className="fas fa-times"></i>
              </button>
            )}
          </div>
        </div>

        <div>
          <label htmlFor="user-role-filter" className="form-label">
            Role
          </label>
          <select id="user-role-filter" className="form-select" value={roleFilter} onChange={handleRoleFilterChange}>
            <option value="">All Roles</option>
            {UserConstants.roles.map((role) => (
              <option key={role} value={role}>
                {role}
              </option>
            ))}
          </select>
        </div>

        <div>
          <button className="btn btn-info" onClick={handleShowAddModal}>
            <i className="fas fa-plus"></i> Add User
          </button>
        </div>
      </div>

      <DataGrid
        enableCellSelect={true}
        columns={getColumns()}
        rows={rows}
        rowKeyGetter={(row) => row.id}
        onRowsChange={handleGridRowsUpdated}
        rowHeight={50}
        minHeight={Math.floor((window.innerHeight * 0.65) / 50) * 50}
        rowScrollTimeout={200}
        sortColumns={sortColumns}
        onSortColumnsChange={handleSortChange}
        // Force light mode since the rest of the admin page is light-themed
        style={{ colorScheme: 'light' }}
      />

      <PaginationControls
        currentPage={users.currentPage}
        totalPages={users.totalPages}
        totalItems={users.totalItems}
        pageSize={users.pageSize}
        onPageChange={handlePageChange}
      />

      <AddUserModal
        show={showAddModal}
        onHide={handleHideAddModal}
        onUserCreated={handleUserCreated}
      />
    </div>
  );
};

UserList.propTypes = {
  users: ApiReturnCollectionOf(UserType),
};

const UserManagement = () => {
  const users = useSelector((state) => state.users_paginated);

  return (
    <div>
      <UserList users={users} />
    </div>
  );
};

export default UserManagement;
