import React from 'react';
import {useCurrentUser} from "../../contexts/CurrentUserContext";
import {UserType} from "../../types";

const publicClientId = process.env.PUBLIC_CLIENT_ID;
const publicClientSecret = process.env.PUBLIC_CLIENT_SECRET;

const ProfilePage = ({user}) => {
  const currentUser = useCurrentUser();
  const renderUser = user || currentUser;

  const apiSection = (currentUser.data.role === 'investigator' || currentUser.data.role === 'admin') ?
    <section className="card p-2 mb-2">
      <h3>API</h3>
      <div className="offset-3"><span>Client ID: </span><pre>{publicClientId}</pre></div>
      <div className="offset-3"><span>Client SECRET: </span><pre>{publicClientSecret}</pre></div>
    </section>
    : '';

  return (
    <div id="wrap" className="page-container container">
      <div className="row">
        <div className="offset-1 col-11">
          <h2 className="mt-3">Profile for {renderUser.data.email}</h2>

          <section className="card p-2 mb-2">
            <p>Role: <span><b>{renderUser.data.role}</b></span></p>
          </section>

          <section className="card p-2 mb-2">
            <h3>Account</h3>

            <div className='offset-3 col-9 d-flex justify-content-around'>
              <button className='btn btn-primary' disabled={true}>Reset Password</button>
              <button className='btn btn-danger' disabled={true}>Delete Account</button>
            </div>
            <p></p>
          </section>

          {apiSection}

          <section className="card p-2 mb-2">
            <h3>Study Participation</h3>
            <p className="offset-3">Under Construction...</p>
          </section>

        </div>
      </div>
    </div>
  )
}

ProfilePage.propTypes = {
  user: UserType,
};

export default ProfilePage;
