import React from 'react';
import {useEffect} from "react";
import {connect} from 'react-redux';
import {useDispatch, useSelector} from 'react-redux';
import elicitApi from '../../api/elicit-api';
import PropTypes from 'prop-types';
import {
  GenerateApiResultPropTypeFor,
  AnonymousProtocolsType,
  ProtocolUserType,
} from '../../types';
import AnonymousProtocolLandingPage from './AnonymousProtocolLandingPage';

const AnonymousProtocolLandingPageContainer = (props) => {
  const anonymous_protocol = useSelector(state => state.anonymous_protocol)
  const dispatch = useDispatch();

  const protocols = anonymous_protocol.data.filter((p) => p.id === props.protocolId);
  const protocol = protocols.length > 0 ? protocols[0] : null;

  useEffect(() => {
    dispatch(elicitApi.actions.anonymous_protocol({id: props.protocolId, public: true}));
  }, [dispatch, !!protocol]);

  const takeProtocol = () => dispatch(elicitApi.actions.take_protocol({study_definition_id: props.studyId, protocol_definition_id: props.protocolId}));

  if ((!anonymous_protocol.sync && anonymous_protocol.loading)) {
    return <div>Loading Protocol {props.protocolId} information</div>;
  }

  if (props.take_protocol &&
    !props.take_protocol.loading &&
    ('error' in props.take_protocol) &&
    props.take_protocol.error) {
    console.dir(props.take_protocol.error);
    if (props.take_protocol.error.status === 404) {
      return <div>Sorry, this protocol has already enough participants.</div>
    } else {
      return <div>Sorry, this protocol cannot be taken.</div>
    }
  }


  console.dir(`Rendering protocol ${props.protocolId} with ${protocol}`);
  console.dir(protocol);
  if (protocol) {
    const protocol_info = <AnonymousProtocolLandingPage protocol={protocol}
                                                        takeProtocol={takeProtocol}></AnonymousProtocolLandingPage>;
    return (
      <div>
        <h1>Take Survey</h1>
        {protocol_info}
      </div>
    );
  } else {
    return <div>This protocol is not available to be taken anonymously</div>
  }
}

AnonymousProtocolLandingPageContainer.propTypes = {
  anonymous_protocol: GenerateApiResultPropTypeFor(PropTypes.arrayOf(AnonymousProtocolsType).isRequired),
  current_user_email: PropTypes.string,
  current_user_role: PropTypes.string,
  //loadAnonymousProtocol: PropTypes.func.isRequired,
  //takeProtocol: PropTypes.func.isRequired,
  protocolId: PropTypes.number.isRequired,
  take_protocol: GenerateApiResultPropTypeFor(PropTypes.arrayOf(ProtocolUserType).isRequired),
}

AnonymousProtocolLandingPageContainer.defaultProps = {
  current_user_role: undefined,
  current_user_email: undefined,
};

export default AnonymousProtocolLandingPageContainer;

