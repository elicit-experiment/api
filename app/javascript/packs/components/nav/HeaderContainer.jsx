import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from "react-redux";
import Header from "./Header.jsx"

// Import Selectors
import { currentUser } from '../../reducers/selector';

// Import Actions
import { logoutUser } from '../../actions/tokens_actions';


class HeaderContainer extends React.Component {
  render() {
    return <Header {...this.props}
                   current_user_role={this.props.currentUser.data.role}
                   current_user_email={this.props.currentUser.data.email}/>
  }
}

const mapStateToProps = (state) => ( {
  currentUser: currentUser(state),
})

const mapDispatchToProps = (dispatch) => ({
  logoutUser: () => dispatch(logoutUser())
});

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(HeaderContainer);
