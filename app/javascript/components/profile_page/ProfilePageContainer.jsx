//Import React and Dependencies
import React from 'react'
import { connect } from 'react-redux';
import {Navigate} from 'react-router-dom'

// Import Components
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import ProfilePage from "./ProfilePage.jsx"

// Import Selector
import { tokenStatus } from '../../reducers/selector';

// Import API
import elicitApi from "../../api/elicit-api.js";
import PropTypes from "prop-types";
import { CurrentUserType, UserTokenType } from "types";

class ProfilePageContainer extends React.Component {
  constructor(props){
    super(props);

    this.state = {
      loading_user: !this.props.current_user.sync,
    };

    this.timeoutLoading = this.timeoutLoading.bind(this)
  }

  timeoutLoading() {
    if (!this.props.current_user.sync) {
      this.setState({ loading_user: false });
    }
  }

  static getDerivedStateFromProps(nextProps) {
    if (nextProps.current_user.sync) {
        return{ loading_user: false };
    }
    return null;
  }

  render() {
    if (this.props.tokenStatus !== 'user') {
      return <Navigate to='/login'></Navigate>
    }

    if (this.state.loading_user) {
      return <div>Loading...</div>
    }

    if (!this.props.current_user.sync) {
      return <Navigate to='/login'></Navigate>
    }

    return(
      <div className="page-wrapper d-flex flex-column">
        <HeaderContainer></HeaderContainer>
        <main id="wrap" className="app-container container flex-fill">
          <ProfilePage current_user={this.props.current_user.data}/>
        </main>
        <FooterContainer></FooterContainer>
      </div>
    )
  }

  componentDidMount() {
    if (!this.props.current_user.sync) {
      this.setState({ loading_user: true });
      this.props.syncCurrentUser();
      console.log("No current user!");
      this.userLoadingTimeout = window.setTimeout(this.timeoutLoading, 5000);
    }
  }

  componentWillUnmount() {
    if (this.userLoadingTimeout) {
      this.userLoadingTimeout = window.clearTimeout(this.userLoadingTimeout);
      this.userLoadingTimeout = undefined;
    }
  }
}

ProfilePageContainer.propTypes = {
	current_user: CurrentUserType,
	tokenStatus: PropTypes.string.isRequired,
	userToken: UserTokenType,
	syncCurrentUser: PropTypes.func.isRequired,
};


const mapStateToProps = (state) => ({
  current_user: state.current_user,
  userToken: state.tokens.userToken,
  tokenStatus: tokenStatus(state),
});

const mapDispatchToProps = (dispatch) => ({
  syncCurrentUser: () => dispatch(elicitApi.actions.current_user.sync()),
});

const ConnectedProfilePageContainer = connect(mapStateToProps, mapDispatchToProps)(ProfilePageContainer);
export default ConnectedProfilePageContainer;
