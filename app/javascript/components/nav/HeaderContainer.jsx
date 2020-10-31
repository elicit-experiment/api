//Import React and Dependencies
import React from 'react'
import {connect} from 'react-redux';
// Import Components
import Header from "./Header.jsx"
// Import Selectors
import {currentUser} from '../../reducers/selector';
// Import Actions
import {logoutUser} from '../../actions/tokens_actions';
import elicitApi from "../../api/elicit-api.js";
import { UserType} from "../../types";

class HeaderContainer extends React.Component {
    constructor(props) {
        super(props);
        //this.props.syncCurrentUser();
    }

    render() {
        return <Header {...this.props}
                       current_user_role={this.props.current_user.data.role}
                       current_username={this.props.current_user.data.username}
                       current_user_email={this.props.current_user.data.email}/>
    }
}

const mapStateToProps = (state) => ({
    current_user: currentUser(state),
});

const mapDispatchToProps = (dispatch) => ({
    logoutUser: () => dispatch(logoutUser()),
    syncCurrentUser: () => dispatch(elicitApi.actions.current_user.sync()),
});

export default connect(
    mapStateToProps,
    mapDispatchToProps,
)(HeaderContainer);

HeaderContainer.propTypes = {
  current_user: UserType.isRequired,
}
