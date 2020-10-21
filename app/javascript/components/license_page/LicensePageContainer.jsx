import React from 'react'
import HeaderContainer from "../nav/HeaderContainer"
import FooterContainer from "../nav/FooterContainer"
import LicensePage from "./LicensePage"

export default class LicensePageContainer extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
    return(
        <div>
          <HeaderContainer></HeaderContainer>
          <LicensePage/>
          <FooterContainer></FooterContainer>
        </div>
    )
  }
}
