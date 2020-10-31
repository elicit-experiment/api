import React from 'react'
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import AboutPage from "./AboutPage"

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
