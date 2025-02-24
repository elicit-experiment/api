import React from 'react';
import ParticipantProtocol from "../participant_app/components/ParticipantProtocol";
import {AnonymousProtocolsType} from "../../types";

const AnonymousParticipantProtocolList = ({ anonymous_protocols }) => {
    if (!anonymous_protocols.sync || anonymous_protocols.loading) {
        return (<div><h1>Loading...</h1></div>)
    }

    const protocols = anonymous_protocols.data.map((protocol_def) => (
        <div className="row col-12" key={protocol_def.id}>
            <ParticipantProtocol 
                protocol={protocol_def}
                study={protocol_def.study_definition}
                users={[]}
                key={protocol_def.id}
            />
        </div>
    ));

    return (
        <section className="row">
            <p className={"row"}>You are eligible to take {protocols.length} anonymous experiments.</p>
            {protocols}
        </section>
    );
};

AnonymousParticipantProtocolList.propTypes = {
    anonymous_protocols: AnonymousProtocolsType,
};

export default AnonymousParticipantProtocolList;

