import React from 'react'
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

export { Fade as Fade }