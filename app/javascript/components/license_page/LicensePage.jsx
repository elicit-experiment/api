import React from 'react';
import markdown from '../../../../LICENSE.md';

const LicensePage = () => {
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
