import React from 'react'
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import FrontPage from "./FrontPage.jsx"
import {currentUser} from "../../reducers/selector";
import connect from "react-redux/es/connect/connect";
import elicitApi from "../../api/elicit-api";
import PropTypes from "prop-types";
import {AnonymousProtocolsType, CurrentUserType} from "types";

class FrontPageContainer extends React.Component {
    constructor(props) {
        super(props);
        //props.syncCurrentUser();
        if (!props.anonymous_protocols || (!props.anonymous_protocols.sync && !props.anonymous_protocols.loading)) {
            props.loadAnonymousProtocols();
        }
    }

    render() {
        return (
            <div>
                <HeaderContainer></HeaderContainer>
                <FrontPage current_user_role={this.props.current_user.data.role}
                           current_username={this.props.current_user.data.username}
                           current_user_email={this.props.current_user.data.email}
                           anonymous_protocols={this.props.anonymous_protocols}
                           loadAnonymousProtocols={this.props.loadAnonymousProtocols}
                />
                <FooterContainer></FooterContainer>
            </div>
        )
    }
}

FrontPageContainer.propTypes = {
    syncCurrentUser: PropTypes.func,
    loadAnonymousProtocols: PropTypes.func,
    anonymous_protocols: AnonymousProtocolsType,
    current_user: CurrentUserType,
};

FrontPageContainer.defaultProps = {
    syncCurrentUser: () => {
    },
    loadAnonymousProtocols: () => {
    },
};

const mapStateToProps = (state) => ({
    anonymous_protocols: state.anonymous_protocols,
    current_user: currentUser(state),
});

const mapDispatchToProps = (dispatch) => ({
    syncCurrentUser: () => dispatch(elicitApi.actions.current_user.sync()),
    loadAnonymousProtocols: () => dispatch(elicitApi.actions.anonymous_protocols()),
});

export default connect(
    mapStateToProps,
    mapDispatchToProps,
)(FrontPageContainer);
