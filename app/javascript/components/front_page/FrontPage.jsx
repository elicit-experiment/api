// Import React and Dependencies
import React, {Component} from 'react';
// Import components
import FrontPagePreface from './FrontPagePreface.html';
import PropTypes from "prop-types";
import {AnonymousProtocolsType} from "../../types";

const htmlDoc = {__html: FrontPagePreface};

export default class FrontPage extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <div id="wrap" className="admin-app-container container">
              <div className="row">
                <div className="mx-auto lead font-wordmark title-wordmark" >E</div>
              </div>
                <div className="row">
                    <div className="col-12 mx-auto text-center text-primary" dangerouslySetInnerHTML={htmlDoc}/>
                </div>
                <div className="row wrap">
                  <div className="col-sm-4">
                  <div className="card p-2">
                    <h5 className="card-title text-primary">About</h5>
                    <p className="card-text" style={{height:'5em'}}>
                      Elicit is a web framework for creating psychological studies.
                    </p>
                    <a className="btn btn-link" href={'/about'}>Learn More</a>
                  </div>
                  </div>
                  <div className="col-sm-4">
                    <div className="card p-2">
                      <h5 className="card-title text-primary">Investigators</h5>
                      <p className="card-text" style={{height:'5em'}}>Investigators can create their own surveys, request participants and analyze the results.</p>
                      <button className="btn btn-link">Request Access</button>
                    </div>
                  </div>
                  <div className="col-sm-4">
                    <div className="card p-2">
                      <h5 className="card-title text-primary">Participants</h5>
                      <p className="card-text" style={{height:'5em'}}>Participate in a study!</p>
                      <a className="btn btn-link" href={'/participate'}>Participate</a>
                    </div>
                  </div>
                </div>
            </div>
        )
    }
}

FrontPage.propTypes = {
    current_user_role: PropTypes.string,
    current_user_email: PropTypes.string,
    loadAnonymousProtocols: PropTypes.func,
    anonymous_protocols: AnonymousProtocolsType.isRequired,
};

FrontPage.defaultProps = {
    current_user_role: undefined,
    current_user_email: undefined,
};

