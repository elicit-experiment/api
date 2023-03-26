import React, { useState } from 'react'
import StudyCardList from '../components/StudyList/StudyCardList'
import {connect, useSelector} from "react-redux"
import elicitApi from "../../../api/elicit-api";
import StudyFilterBar from "../components/StudyList/StudyFilterBar";
import pluralize from "pluralize";

const StudyManagement = (props) => {
  const [sortOrder, setSortOrder] = useState('down');
  const [searchText, setSearchText] = useState('');
  const toggleSortOrder = () => {
    setSortOrder(sortOrder === 'down' ? 'up' : 'down');
  }

  const studiesList = useSelector(state => state.studies_paginated);
  const studies = studiesList.data;

  const title = studies ? <div className="col-md-11">
    <h1>{studiesList.totalItems} {pluralize('Study', studiesList.totalItems)} (showing {studies.length})</h1>
  </div> : <div></div>

  const onSearch = (searchText) => {
    console.log('settings')
    setSearchText(searchText);
  }

  return (<div>
    <StudyFilterBar onSearch={onSearch}/>
    <div className="row height d-flex justify-content-center align-items-center">
      { title }
      <div className="col-md-1">
        <button className="btn btn-outline-primary display-2">
          <i className={`fas fa-sort-amount-${sortOrder}`} onClick={toggleSortOrder}></i>
        </button>
      </div>
    </div>

    <StudyCardList sortOrder={sortOrder}
                   searchText={searchText}
                   {...props } />
  </div>)
};

const mapStateToProps = (state) => ({
  studies: state.studies,
  study_definition: state.study_definition,
  protocol_definitions: state.protocol_definitions,
});

const mapDispatchToProps = (dispatch) => ({
  loadStudies: () => dispatch(elicitApi.actions.studies()),
  loadCurrentUser: () => dispatch(elicitApi.actions.current_user()),
});

export default connect(mapStateToProps, mapDispatchToProps)(StudyManagement)
