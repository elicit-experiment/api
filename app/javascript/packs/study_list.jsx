import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import StudyStore from '../packs/store/StudyStore'
import TransitionGroup from 'react-transition-group/TransitionGroup'
import Transition from 'react-transition-group/Transition';
import CSSTransition from 'react-transition-group/CSSTransition';

const Fade = ({ children, ...props }) => (
 <CSSTransition
   {...props}
   timeout={500}
   classNames="fade"
 >
  {children}
 </CSSTransition>
);


class Study extends React.Component {
  render() {
    var DeleteStudy = this.deleteItem.bind(this)

    return (
      <div className='study-wrapper' key={this.props.study.id}>
        <div className='well study show' data-studyId={this.props.study.id}>
          <p><b>Title:</b>{this.props.study.title}</p>
          <p><b>PI:</b>{this.props.study.principal_investigator_name}</p>
          <button className='remove-study' onClick={DeleteStudy}> &times; </button>
        </div>
      </div>
    )
  }

  deleteItem(itm) {
    StudyStore.removeItem(this.props.study.id)
  }
}

const NewStudy = props => (
    <div className='well new-study study show' onClick={(e) => {
      StudyStore.newItem({title: "New Study", principal_investigator_user_id: 1})
    }
  }>+</div>
)

class StudyList extends React.Component {
  render() {
    if (!this.state || !this.state.studies) {
      return (<div><h1>Loading...</h1></div>)
    }
    var studies = this.state.studies.map( (study, i) => {
      return(
        <Fade key={study.id} appear='true'>
        <div>
        <Study study={study} key={study.id}> </Study>
        </div>
        </Fade>
      )
    })
    console.dir(studies)
    return(
    <div>
      <h1>{studies.length} Studies</h1>
      <TransitionGroup>
        {studies}
      </TransitionGroup>
      <NewStudy></NewStudy>
    </div>)
  }

  componentDidMount() {
    StudyStore.loadItems()
    StudyStore.addListener('change', this.handleChangedEvent, this);
  }

  handleChangedEvent = (event) => {
    console.log("udating studies")
    let studies = {studies: StudyStore.getList().list }
    console.dir(studies)
    this.setState(studies)
  };
}

//<Study study={study} />
 
document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <StudyList/>,
    document.getElementById('study-list'),
  )
})