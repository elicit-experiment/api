//Import React and Dependencies
import React from 'react'
import ReactDOM from 'react-dom'
import { connect } from 'react-redux';
import { Redirect } from 'react-router-dom'

// Import Components
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import ProfilePage from "./ProfilePage.jsx"

// Import Selector
import { tokenStatus } from '../../reducers/selector';

// Import API
import elicitApi from "../../api/elicit-api.js";

class ProfilePageContainer extends React.Component {
  constructor(props){
    super(props);

    this.state = {
      loading_user: !this.props.current_user.sync
    }

    this.timeoutLoading = this.timeoutLoading.bind(this)
  }

  timeoutLoading() {
    if (!this.props.current_user.sync) {
      this.setState({ loading_user: false });
    }
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.current_user.sync) {
        this.setState({ loading_user: false });
    }
  }

  render() {
    if (this.props.tokenStatus != 'user') {
      return <Redirect to='/login'></Redirect>
    }

    if (this.state.loading_user) {
      return <div>Loading...</div>
    }

    if (!this.props.current_user.sync) {
      return <Redirect to='/login'></Redirect>
    }

    return(
        <div>
          <HeaderContainer></HeaderContainer>
          <ProfilePage current_user={this.props.current_user.data}/>
          <FooterContainer></FooterContainer>
        </div>
    )
  }

  componentWillMount() {
    if (!this.props.current_user.sync) {
      this.setState({ loading_user: true });
      this.props.syncCurrentUser()
      console.log("No current user!")
      this.userLoadingTimeout = window.setTimeout(this.timeoutLoading, 5000)
    }
  }

  componentWillUnmount() {
    if (this.userLoadingTimeout) {
      this.userLoadingTimeout = window.clearTimeout(this.userLoadingTimeout)
      this.userLoadingTimeout = undefined
    }
  }
}

const mapStateToProps = (state) => ({
  current_user: state.current_user,
  userToken: state.tokens.userToken,
  tokenStatus: tokenStatus(state),
});

const mapDispatchToProps = (dispatch) => ({
  syncCurrentUser: () => dispatch(elicitApi.actions.current_user.sync())
});

const ConnectedProfilePageContainer = connect(mapStateToProps, mapDispatchToProps)(ProfilePageContainer)
export default ConnectedProfilePageContainer;
