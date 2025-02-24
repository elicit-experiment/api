import React from 'react'
import FrontPage from "./FrontPage.jsx"
import {CurrentUserProvider} from "../../contexts/CurrentUserContext";

const FrontPageContainer = () => (
  <CurrentUserProvider>
      <FrontPage/>
  </CurrentUserProvider>
)

export default FrontPageContainer;