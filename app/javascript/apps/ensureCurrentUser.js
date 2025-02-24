import {useDispatch, useSelector} from "react-redux";
import {tokenStatus} from "../reducers/selector";
import React, {useEffect} from "react";
import elicitApi from "../api/elicit-api";
import {Navigate} from "react-router-dom";

export default function ensureCurrentUser(callback) {
  const currentUser = useSelector(state => state.current_user);
  const dispatch = useDispatch();

  let currentTokenStatus = useSelector(state => tokenStatus(state));

  useEffect(() => {
    if (currentTokenStatus !== 'user') { return }

    if (!currentUser) { return }

    if (currentUser.sync) { return }

    if (!currentUser?.loading) {
      console.log("No current user!");
      dispatch(elicitApi.actions.current_user());
    }
  }, [currentTokenStatus, currentUser, currentUser?.sync, currentUser?.loading]);

  if (currentTokenStatus !== 'user') {
    return <Navigate to='/login' />;
  }

  if (currentUser.error) {
    console.log(`No current user: ${JSON.stringify(currentUser.error)}`);
    // TODO: all 400 errors too?
    if (currentUser.error.status === 401) {
      return <Navigate to='/logout'></Navigate>
    }
  }

  if (!currentUser.sync) {
    return <div>Loading...</div>;
  }

  return callback(currentUser);
}