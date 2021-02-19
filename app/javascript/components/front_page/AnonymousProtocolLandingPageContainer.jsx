import React from 'react';
import {connect} from 'react-redux';
import elicitApi from '../../api/elicit-api';
import PropTypes from 'prop-types';
import {
  GenerateApiResultPropTypeFor,
  AnonymousProtocolsType,
  MatchType, ProtocolUserType,
} from '../../types';
import AnonymousProtocolLandingPage from './AnonymousProtocolLandingPage';

class AnonymousProtocolLandingPageContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      protocolId: parseInt(this.props.match.params.protocol_id),
    };
  }

  render() {
    if ((!this.props.anonymous_protocol.sync &&
      this.props.anonymous_protocol.loading)) {
      return <div>Loading Protocol {this.state.protocolId} information</div>;
    }


    if (this.props.take_protocol &&
        !this.props.take_protocol.loading &&
       ('error' in this.props.take_protocol) &&
        this.props.take_protocol.error) {
      console.dir(this.props.take_protocol.error);
      if (this.props.take_protocol.error.status === 404) {
        return <div>Sorry, this protocol has already enough participants.</div>
      } else {
        return <div>Sorry, this protocol cannot be taken.</div>
      }
    }

    let protocol = this.getProtocol();
    console.dir(`Rendering protocol ${this.state.protocolId} with ${protocol}`);
    console.dir(protocol);
    if (protocol) {
      const protocol_info = <AnonymousProtocolLandingPage protocol={protocol} takeProtocol={this.props.takeProtocol}></AnonymousProtocolLandingPage>;
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

  getProtocol() {
    const protocols = this.props.anonymous_protocol.data.filter((p) => p.id === this.state.protocolId );
    return protocols.length > 0 ? protocols[0] : null;
  }

  ensureProtocolDefinitionLoaded() {
    if ((!this.props.anonymous_protocol.sync &&
        !this.props.anonymous_protocol.loading) ||
        (!this.getProtocol())) {
      this.props.loadAnonymousProtocol(this.state.protocolId);
    }
  }

  componentDidMount() {
    this.ensureProtocolDefinitionLoaded();
  }
}

AnonymousProtocolLandingPageContainer.propTypes = {
  anonymous_protocol: GenerateApiResultPropTypeFor(PropTypes.arrayOf(AnonymousProtocolsType).isRequired),
  current_user_email: PropTypes.string,
  current_user_role: PropTypes.string,
  loadAnonymousProtocol: PropTypes.func.isRequired,
  match: MatchType,
  takeProtocol: PropTypes.func.isRequired,
  take_protocol: GenerateApiResultPropTypeFor(PropTypes.arrayOf(ProtocolUserType).isRequired),
}

AnonymousProtocolLandingPageContainer.defaultProps = {
  current_user_role: undefined,
  current_user_email: undefined,
};

const mapStateToProps = (state) => ({
  anonymous_protocol: state.anonymous_protocol,
  take_protocol: state.take_protocol,
});

const mapDispatchToProps = (dispatch) => ({
  loadAnonymousProtocol: (id) => dispatch(elicitApi.actions.anonymous_protocol({id, public: true})),
  takeProtocol: (s) => { dispatch(elicitApi.actions.take_protocol(s)) },
});

export default connect(mapStateToProps, mapDispatchToProps)(
    AnonymousProtocolLandingPageContainer);
