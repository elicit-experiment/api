import React, {useEffect} from 'react'
import PropTypes from "prop-types";

const StudyFilterBar = (props) => {
  const onKeyUp = ({key, target}) => {
    console.log(key);
    console.log(target.value)
    if (key === "Enter") {
      props.onSearch(target.value)
    }
  };

  return (
    <div className="container">
      <div className="row height d-flex justify-content-center align-items-center">
        <div className="col-md-6">
          <div className="study-filter-bar">
            <i className="fa fa-search"></i>
            <input type="text" className="form-control form-input" placeholder="Search anything..." onKeyUp={onKeyUp}/>
              <span className="left-pan"><i className="fa fa-microphone"></i></span>
          </div>
        </div>
      </div>
      <row>
        <div className="p-3"></div>
      </row>
    </div>
  )
}

StudyFilterBar.propTypes = {
  onSearch: PropTypes.func,
}

export default StudyFilterBar;
