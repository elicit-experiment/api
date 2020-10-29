import React from 'react';
import ParticipantProtocol from "./ParticipantProtocol";
import { CurrentUserType, EligibleProtocolsType, MatchType, LocationType, UserTokenType } from 'types';
import PropTypes from 'prop-types';

class ParticipantProtocolList extends React.Component {
    render() {
        if (!this.props.eligeable_protocols.sync) {
            if (!this.props.eligeable_protocols.loading) {
                this.props.loadEligeableProtocols()
            }
            return (<div><h1>Loading...</h1></div>)
        }

        const protocols = this.props.eligeable_protocols.data.map((protocol_user) => {
            return (
                    <ParticipantProtocol protocol={protocol_user.protocol_definition}
                                         study={protocol_user.study_definition}
                                         users={this.props.users}
                                         experiment={protocol_user.experiment}
                                         key={protocol_user.protocol_definition.id}>
                    </ParticipantProtocol>
            )
        });

        return (
            <div className="row">
                <h1 className={"row"}>You are eligible to take {protocols.length} experiments.</h1>
                {protocols}
            </div>)
    }
}

ParticipantProtocolList.propTypes = PropTypes.shape({
    current_user: CurrentUserType.isRequired,
    eligeable_protocols: EligibleProtocolsType.isRequired,
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

