//Import React and Dependencies
import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux';

// Import Components
import Header from "./Header.jsx"

// Import Selectors
import { currentUser } from '../../reducers/selector';

// Import Actions
import { logoutUser } from '../../actions/tokens_actions';
import elicitApi from "../../api/elicit-api.js";

class HeaderContainer extends React.Component {
  render() {
    return <Header {...this.props}
                   current_user_role={this.props.current_user.data.role}
                   current_username={this.props.current_user.data.username}
                   current_user_email={this.props.current_user.data.email}/>
  }
  componentWillMount() {
    this.props.syncCurrentUser()
  }
}

const mapStateToProps = (state) => ( {
  current_user: currentUser(state),
});

const mapDispatchToProps = (dispatch) => ({
  logoutUser: () => dispatch(logoutUser()),
  syncCurrentUser: () => dispatch(elicitApi.actions.current_user.sync()),
});

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(HeaderContainer);
