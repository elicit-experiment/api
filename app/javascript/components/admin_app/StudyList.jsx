import React from 'react'
import PropTypes from 'prop-types'
import TransitionGroup from 'react-transition-group/TransitionGroup'
import CSSTransition from 'react-transition-group/CSSTransition';
import Study from './Study'
import {StudyDefinitionType, ProtocolDefinitionType, ApiReturnCollectionOf} from '../../types';
import pluralize from 'pluralize';

const Fade = ({ children, ...props }) => (
 <CSSTransition
   {...props}
   timeout={500}
   classNames="fade"
 >
  {children}
 </CSSTransition>
);

class StudyList extends React.Component {
  render() {
    console.log(JSON.stringify(this.props, null, 2));

    if (!this.props.studies || !this.props.studies.data) {
      return (<div><h1>Loading...</h1></div>)
    }
    const studies = this.props.studies.data.map( (study, i) => {
      return(
        <Fade key={study.id} appear={true} >
          <div>
            <Study study={study} users={this.props.users} protocol_definitions={this.props.protocol_definitions} key={study.id}> </Study>
          </div>
        </Fade>
      )
    });

    return(
    <div>
      <h1>{studies.length} {pluralize('Study', studies.length)} </h1>
      <TransitionGroup>
        {studies}
      </TransitionGroup>
    </div>)
  }

  componentDidMount() {
    console.log("StudyList MOUNT");

    if (!this.props.studies.sync && !this.props.studies.loading) {
      this.props.loadStudies()
    }
  }
}

StudyList.propTypes = {
  protocol_definitions: ApiReturnCollectionOf(ProtocolDefinitionType),
  studies: ApiReturnCollectionOf(StudyDefinitionType),
  loadStudies: PropTypes.func,
};

export default StudyList;

