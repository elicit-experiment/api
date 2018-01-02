import React from "react";
import ReactDOM from "react-dom";
import PropTypes from "prop-types";
import InlineEdit from "react-edit-inline";
import update from "react-addons-update";
import { Link } from "react-router-dom";
import pathToRegexp from "path-to-regexp";
import elicitApi from "../../api/elicit-api.js";
import { connect } from "react-redux";
import elicitConfig from "../../ElicitConfig.js";
import FormattedDate from "../ui_elements/FormattedDate.jsx";

export class ExperimentDetails extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const exp = this.props.experiment;

    if (!exp) {
      return (
        <div>
          <div className="row">
            <b className="col-xs-2">Status:</b>
            <div className="col-xs-10">Not Started</div>
          </div>
        </div>
      );
    }

    if (exp.completed_at) {
      return (
        <div>
          <div className="row">
            <b className="col-xs-2">Status:</b>
            <div className="col-xs-10">
              <div>
                Started on <FormattedDate date={exp.started_at} />
              </div>
              <div>
                {" "}
                Completed on <FormattedDate date={exp.completed_at} />{" "}
              </div>
            </div>
          </div>
        </div>
      );
    }

    var current_stage_status = "None";
    if (exp.current_stage) {
      current_stage_status = (
        <div>
          <div className="started-experiment">
            Started on <FormattedDate date={exp.current_stage.started_at} />
          </div>
          <div>
            <p>Completed {exp.current_stage.last_completed_trial == undefined ? 0 : 1} / {exp.current_stage.num_trials || 0} slides. </p>
          </div>
        </div>
      );
    }

    return (
      <div>
        <div className="row">
          <b className="col-xs-2">Status:</b>
          <div className="col-xs-10">
            Started on <FormattedDate date={exp.started_at} />{" "}
          </div>
        </div>
        <div className="row">
          <b className="col-xs-2">Stages:</b>
          <div className="col-xs-10">
            <p>{exp.num_stages_completed || "0"} Completed {exp.num_stages_remaining || "0"} Remaining </p>
          </div>
        </div>
        <div className="row">
          <b className="col-xs-2">Current Stage:</b>
          <div className="col-xs-10">{current_stage_status}</div>
        </div>
      </div>
    );
  }
}
