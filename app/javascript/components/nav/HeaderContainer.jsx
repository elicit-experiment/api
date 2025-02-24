//Import React and Dependencies
import React from 'react'
// Import Components
import Header from "./Header.jsx"
import { UserType } from "../../types";

export const HeaderContainer = (props) => {
    return <Header current_user_role={props.current_user.data.role}
                   current_username={props.current_user.data.username}
                   current_user_email={props.current_user.data.email}/>
}

HeaderContainer.propTypes = {
  current_user: UserType.isRequired,
}

export default HeaderContainer;