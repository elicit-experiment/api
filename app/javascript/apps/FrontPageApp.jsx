import React from 'react';
import HeaderContainer from "../components/nav/HeaderContainer.jsx";
import FooterContainer from "../components/nav/FooterContainer.jsx";
import AnonymousProtocolLandingPageContainer from "../components/front_page/AnonymousProtocolLandingPageContainer";
import FrontPageContainer from "../components/front_page/FrontPageContainer";
import ParticipatePage from "../components/front_page/ParticipatePage";
import {Route, Routes, useMatch} from "react-router-dom";

const FrontPageApp = (props) => {

  const landingPageUrl = `studies/:study_id/protocols/:protocol_id`;
  const participatePageUrl = `/participate`;
  const landingPageMatch = useMatch(landingPageUrl);

  console.log('FRONTPAGE')

  return (
    <div className="page-wrapper d-flex flex-column">
      <HeaderContainer></HeaderContainer>
      <main id="wrap" className="home-page-app-container app-container container flex-fill">
        <Routes>
          <Route path={landingPageUrl}
                 element={<AnonymousProtocolLandingPageContainer
                   protocolId={parseInt(landingPageMatch?.params?.protocol_id, 10)}
                   studyId={parseInt(landingPageMatch?.params?.study_id, 10)}
                   {...props}
                 />}

          />
          <Route path={participatePageUrl}
                 element={<ParticipatePage/>}/>
          <Route exact path="/"
                 element={<FrontPageContainer/>}/>
        </Routes>
      </main>
      <FooterContainer></FooterContainer>
    </div>
  )
}

export default FrontPageApp;
