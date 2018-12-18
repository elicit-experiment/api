// Import React and Dependencies
import React, {Component} from 'react';
import {Link} from 'react-router-dom';
// Import components
import FrontPagePreface from './FrontPagePreface.html';
import PropTypes from "prop-types";
import AnonymousParticipantProtocolList from "../anonymous_participant_protocol_list/AnonymousParticipantProtocolList";
import {AnonymousProtocolsType} from "../../types";

const htmlDoc = {__html: FrontPagePreface};

export default class FrontPage extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        const {anonymous_protocols} = this.props;

        let loggedInStudies;
        if (this.props.current_user_role === undefined) {
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
                    <div className="col-xs-offset-1 col-xs-11" dangerouslySetInnerHTML={htmlDoc}/>
                </div>
                <div className="row">
                    <div className="col-xs-offset-1 col-xs-11">
                        <h2>Studies you can take...</h2>

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

FrontPage.propTypes = {
    current_user_role: PropTypes.string,
    current_user_email: PropTypes.string,
    loadAnonymousProtocols: PropTypes.func,
    anonymous_protocols: AnonymousProtocolsType.isRequired,
};

FrontPage.defaultProps = {
    current_user_role: undefined,
    current_user_email: undefined,
};

