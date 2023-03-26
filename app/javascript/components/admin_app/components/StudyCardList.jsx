import React, {useEffect} from 'react'
import PropTypes from 'prop-types'
import TransitionGroup from 'react-transition-group/TransitionGroup'
import CSSTransition from 'react-transition-group/CSSTransition';
import Study from './StudyCard'
import {ProtocolDefinitionType, ApiReturnCollectionOf} from '../../../types';
import pluralize from 'pluralize';
import InfiniteScroll from 'react-infinite-scroll-component'
import {useDispatch, useSelector} from "react-redux";
import elicitApi from "../../../api/elicit-api";
import {ensureSyncableListLoaded} from "../../../api/api-helpers";

const Fade = ({children, ...props}) => (
  <CSSTransition
    {...props}
    timeout={500}
    classNames="fade"
  >
    {children}
  </CSSTransition>
);

const StudyCardList = () => {
  const dispatch = useDispatch();
  const studiesList = useSelector(state => state.studies_paginated)
  const studies = studiesList.data

  const loadNextPage = () => {
    dispatch(elicitApi.actions.studies_paginated.loadNextPage());
  };

  const studiesState = ensureSyncableListLoaded(studiesList);

  useEffect(() => {
    studiesState === 'start-load' && dispatch(elicitApi.actions.studies_paginated.loadNextPage())
  }, [])
  if (studiesState === 'start-load') {
    return (<div><h1>Loading...</h1></div>)
  }
  if (studiesState === 'error') {
    return (<div><h1>Error. Try reloading the page.</h1></div>)
  }

  const hasMore = studies.length < studiesList.totalItems;

  return (
    <div id="scrollableTarget" style={{}}>
      <h1>{studiesList.totalItems} {pluralize('Study', studiesList.totalItems)} (showing {studies.length})</h1>


      {/*Put the scroll bar always on the bottom*/}
      <div style={{}}>
        <TransitionGroup>
          <InfiniteScroll
            dataLength={studies.length}
            next={loadNextPage}
            hasMore={hasMore}
            loader={<h4>Loading...</h4>}
          >
            {
              studies.map((study, _i) => (
                <div key={study.id}>
                  <Study study={study} editProtocols={true} > </Study>
                </div>
              ))
            }

          </InfiniteScroll>
        </TransitionGroup>
      </div>
    </div>
  )
}

StudyCardList.propTypes = {
}

export default StudyCardList;

Fade.propTypes = {
  children: PropTypes.any,
}
