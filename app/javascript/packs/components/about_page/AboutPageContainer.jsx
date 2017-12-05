import React from 'react'
import ReactDOM from 'react-dom'
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import AboutPage from "./AboutPage"

export default class AboutPageContainer extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
    return(
        <div>
          <HeaderContainer></HeaderContainer>
          <AboutPage/>
          <FooterContainer></FooterContainer>
        </div>
    )
  }
}
