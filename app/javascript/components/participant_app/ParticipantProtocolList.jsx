import React from 'react';
import ParticipantProtocol from "./ParticipantProtocol";


class ParticipantProtocolList extends React.Component {
  render() {
    if (!this.props.eligeable_protocols.sync) {
      if (!this.props.eligeable_protocols.loading) {
        this.props.loadEligeableProtocols()
      }
      return (<div><h1>Loading...</h1></div>)
    }

    var protocols = this.props.eligeable_protocols.data.map((protocol_user) => {
      return (
          <div className="row col-xs-12" key={protocol_user.protocol_definition.id}>
            <ParticipantProtocol protocol={protocol_user.protocol_definition}
                                 study={protocol_user.study_definition}
                                 users={this.props.users}
                                 experiment={protocol_user.experiment}
                                 key={protocol_user.protocol_definition.id}>
            </ParticipantProtocol>
          </div>
      )
    });

    return (
        <div className="row">
          <h1 className={"row"}>You are eligible to take {protocols.length} experiments.</h1>
          {protocols}
        </div>)
  }
}

export default ParticipantProtocolList;

