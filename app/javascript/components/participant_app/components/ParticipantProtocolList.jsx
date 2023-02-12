import React, {useEffect} from 'react';
import ParticipantProtocol from "./ParticipantProtocol";
import {CurrentUserType, LocationType, MatchType, UserTokenType} from 'types';
import PropTypes from 'prop-types';
import InfiniteScroll from 'react-infinite-scroll-component'
import elicitApi from "../../../api/elicit-api";
import {useDispatch, useSelector} from "react-redux";
import {ensureSyncableListLoaded} from "../../../api/api-helpers";

function ParticipantProtocolList(props) {

  const dispatch = useDispatch();
  const eligeableProtocolsList = useSelector(state => state.eligeable_protocols)
  const eligeableProtocols = eligeableProtocolsList.data

  //const loadNextPage = () => dispatch(elicitApi.actions.eligeable_protocols.loadNextPage());

  const eligeableProtocolsState = ensureSyncableListLoaded(eligeableProtocolsList);

  useEffect(() => {
    eligeableProtocolsState === 'start-load' && dispatch(elicitApi.actions.eligeable_protocols({public:true}))
  }, [])
  if (eligeableProtocolsState === 'start-load') {
    return (<div><h1>Loading...</h1></div>)
  }
  if (eligeableProtocolsState === 'error') {
    return (<div><h1>Error. Try reloading the page.</h1></div>)
  }

  const protocols = eligeableProtocols.map((protocolUser) => {
    return (
      <ParticipantProtocol protocol={protocolUser.protocol_definition}
                           study={protocolUser.study_definition}
                           users={props.users}
                           experiment={protocolUser.experiment}
                           key={protocolUser.protocol_definition.id}>
      </ParticipantProtocol>
    )
  });

  if (protocols.length === 0) {
    return (<div className="row">
      <h1 className={"row"}>There are no experiments available to you at this time.</h1>
    </div>)
  }

  return (
    <div className="row">
      <h1 className={"row"}>You are eligible to take {protocols.length} experiments.</h1>
            <InfiniteScroll
                dataLength={eligeableProtocols.length}
                next={() => {}}
                hasMore={false}
                loader={<h4>Loading...</h4>}
            >
                {protocols}
            </InfiniteScroll>
    </div>)
}

ParticipantProtocolList.propTypes = PropTypes.shape({
    current_user: CurrentUserType.isRequired,
    history: PropTypes.shape({
        action: PropTypes.string.isRequired,
        length: PropTypes.number.isRequired,
        location: LocationType.isRequired,
    }).isRequired,
    location: LocationType.isRequired,
    match: MatchType.isRequired,
    tokenStatus: PropTypes.string.isRequired,
    userToken: UserTokenType,
}).isRequired;

export default ParticipantProtocolList;

