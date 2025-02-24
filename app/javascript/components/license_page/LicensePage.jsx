import React from 'react';

const LicensePage = () => {
  const markdown = require("../../../../LICENSE.md");
  const md = markdown ? <div dangerouslySetInnerHTML={{__html: markdown}}/> : <div></div>;

  return (
    <div id="wrap" className="page-container container">
      <div className="row">
        <div className="offset-xs-1 col-11">
          { md }
        </div>
      </div>
    </div>
  );
};

export default LicensePage;
