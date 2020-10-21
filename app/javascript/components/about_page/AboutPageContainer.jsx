import React from 'react'
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import AboutPage from "./AboutPage"
import {Route} from "react-router-dom";
import AnonymousProtocolLandingPageContainer from "../front_page/AnonymousProtocolLandingPageContainer";
import ParticipatePage from "../front_page/ParticipatePage";
import FrontPageContainer from "../front_page/FrontPageContainer";

export default class AboutPageContainer extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
    return(
      <div className="page-wrapper d-flex flex-column">
        <HeaderContainer></HeaderContainer>
        <main id="wrap" className="app-container container flex-fill">
          <AboutPage/>
        </main>
        <FooterContainer></FooterContainer>
      </div>
    )
  }
}
