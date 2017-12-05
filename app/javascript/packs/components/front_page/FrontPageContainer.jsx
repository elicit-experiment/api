import React from 'react'
import ReactDOM from 'react-dom'
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import FrontPage from "./FrontPage.jsx"

export default class FrontPageContainer extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
    return(
        <div>
          <HeaderContainer></HeaderContainer>
          <FrontPage/>
          <FooterContainer></FooterContainer>
        </div>
    )
  }
}
