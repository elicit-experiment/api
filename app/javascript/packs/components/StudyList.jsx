import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import StudyStore from '../store/StudyStore'
import TransitionGroup from 'react-transition-group/TransitionGroup'
import Transition from 'react-transition-group/Transition';
import CSSTransition from 'react-transition-group/CSSTransition';
import InlineEdit from 'react-edit-inline';
import update from 'react-addons-update'

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
  constructor(props){
    super(props);
    this.titleChanged = this.titleChanged.bind(this)
    this.deleteStudy = this.deleteItem.bind(this)
    this.state = {
        title: this.props.study.title
    }
  }

  titleChanged(data) {
      const newData = update(this.props.study, {
        title: {$set: data.title},
      });
      StudyStore.updateItem(newData)
      console.log(data)
      this.setState({...data})
  }

  validateTitle(text) {
    return (text.length > 0 && text.length < 64);
  }

  render() {
    return (
      <div className='study-wrapper' key={this.props.study.id}>
        <div className='well study show' data-studyId={this.props.study.id}>
          <p><b>Title:</b>
            <InlineEdit
              validate={this.customValidateTitle}
              activeClassName="editing"
              text={this.state.title}
              paramName="title"
              change={this.titleChanged}
              style={{
                minWidth: 150,
                display: 'inline-block',
                margin: 0,
                padding: 0,
                fontSize: 15,
                outline: 0,
                border: 0
              }}
            />
          </p>
          <p><b>PI:</b>{this.props.study.principal_investigator_name}</p>
          <button className='remove-study' onClick={this.deleteStudy}> &times; </button>
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
        <Fade key={study.id} appear={true} >
        <div>
        <Study study={study} key={study.id}> </Study>
        </div>
        </Fade>
      )
    })

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
    let studies = {studies: StudyStore.getList().list }
    this.setState(studies)
  }
}

export default StudyList;

