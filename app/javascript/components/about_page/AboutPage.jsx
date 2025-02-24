import React from 'react';
import Page from './About.html';
const htmlDoc = {__html: Page};

const AboutPage  = () => (
  <div id="wrap" className="page-container container">
    <div className="row">
      <div className="offset-xs-1 col-11">
        <div dangerouslySetInnerHTML={htmlDoc}/>
      </div>
    </div>
  </div>
);

export default AboutPage;
