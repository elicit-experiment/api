// Import React and Dependencies
import React, {Component} from 'react';
import {Link} from 'react-router-dom';
// Import components
import PropTypes from "prop-types";
import AnonymousParticipantProtocolList from "../anonymous_participant_protocol_list/AnonymousParticipantProtocolList";
import {AnonymousProtocolsType} from "../../types";
import {currentUser} from "../../reducers/selector";
import elicitApi from "../../api/elicit-api";
import connect from "react-redux/lib/connect/connect";
import {CurrentUserType} from "types";

class ParticipatePage extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        const {anonymous_protocols} = this.props;

      if (!this.props.anonymous_protocols.sync) {
        if (!this.props.anonymous_protocols.loading) {
          this.props.loadAnonymousProtocols()
        }
        return (<div><h1>Loading...</h1></div>)
      }

      let loggedInStudies;
        if (this.props.current_user.data.role === undefined) {
            loggedInStudies =
                <p> Log in using the header button or <Link to="/participant">click here</Link> to login and see the
                    studies you&apos;re eligible for </p>
        } else {
            loggedInStudies = <p>None</p>
        }

        let anonymousStudies;
        if (typeof anonymous_protocols === 'undefined') {
            anonymousStudies = <section>Loading...</section>;
        } else {
            if (this.props.anonymous_protocols.data.length > 0) {
                anonymousStudies = <AnonymousParticipantProtocolList
                        anonymous_protocols={this.props.anonymous_protocols}
                    />;
            } else {
                anonymousStudies = <section><p>There are no anonymous studies available at the moment</p></section>;
            }
        }

        return (
            <div id="wrap" className="admin-app-container container">
                <div className="row">
                    <div className="offset-1 col-11">
                        <h1 className="text-center">Studies You Can Take</h1>

                        <h3>
                            Anonymous Studies
                        </h3>

                        {anonymousStudies}

                        <h3>
                            Logged-in Studies
                        </h3>
                        {loggedInStudies}
                    </div>
                </div>
            </div>
        )
    }
}

ParticipatePage.propTypes = {
  syncCurrentUser: PropTypes.func,
  loadAnonymousProtocols: PropTypes.func,
  anonymous_protocols: AnonymousProtocolsType,
  current_user: CurrentUserType,
};

ParticipatePage.defaultProps = {
  syncCurrentUser: () => {},
  loadAnonymousProtocols: () => {},
};

const mapStateToProps = (state) => ({
  anonymous_protocols: state.anonymous_protocols,
  current_user: currentUser(state),
});

const mapDispatchToProps = (dispatch) => ({
  syncCurrentUser: () => dispatch(elicitApi.actions.current_user.sync()),
  loadAnonymousProtocols: () => dispatch(elicitApi.actions.anonymous_protocols({public: true})),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(ParticipatePage);
