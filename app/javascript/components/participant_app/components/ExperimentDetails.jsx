import React from "react";
import FormattedDate from "../../ui_elements/FormattedDate.jsx";
import {ExperimentType} from "../../../types";

export function ExperimentDetails(props) {
  const exp = props.experiment;

  if (!exp) {
    return (
      <div>
        <div className="row">
          <b className="col-2">Status:</b>
          <div className="col-10">Not Started</div>
        </div>
      </div>
    );
  }

  if (exp.completed_at) {
    return (
      <div>
        <div className="row">
          <b className="col-2">Status:</b>
          <div className="col-10">
            <div>
              You already participated in this experiment. Thank you!. (You can&apos;t change your answers or take it
              again).
            </div>
            <div>
              Started on <FormattedDate date={exp.started_at || exp.created_at}/>
            </div>
            <div>
              {" "}
              Completed on <FormattedDate date={exp.completed_at}/>{" "}
            </div>
          </div>
        </div>
      </div>
    );
  }

  let current_stage_status = "None";
  if (exp.current_stage) {
    current_stage_status = (
      <div>
        <div className="started-experiment">
          Started on <FormattedDate date={exp.current_stage.started_at || exp.current_stage.created_at}/>
        </div>
        <div>
          <p>Completed {exp.current_stage.last_completed_trial === undefined ? 0 : 1} / {exp.current_stage.num_trials || 0} slides. </p>
        </div>
      </div>
    );
  }

  return (
    <div>
      <div className="row">
        <b className="col-2">Status:</b>
        <div className="col-10">
          Started on <FormattedDate date={exp.started_at}/>{" "}
        </div>
      </div>
      <div className="row">
        <b className="col-2">Stages:</b>
        <div className="col-10">
          <p>{exp.num_stages_completed || "0"} Completed {exp.num_stages_remaining || "0"} Remaining </p>
        </div>
      </div>
      <div className="row">
        <b className="col-2">Current Stage:</b>
        <div className="col-10">{current_stage_status}</div>
      </div>
    </div>
  );
}

ExperimentDetails.propTypes = {
  experiment: ExperimentType.isRequired,
}
