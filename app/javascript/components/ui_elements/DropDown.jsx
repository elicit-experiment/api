import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

const DropDown = ({
  id,
  options,
  value = null,
  valueField = 'value',
  labelField = 'label',
  className = '',
  onChange = null,
}) => {
  const getSelectedValue = () => {
    if (value === null && options.length !== 0) {
      return options[0][valueField];
    }
    return value;
  };

  const [selected, setSelected] = useState(getSelectedValue());

  useEffect(() => {
    setSelected(getSelectedValue());
  }, [value, options, valueField]);

  const handleChange = (e) => {
    const newValue = e.target.value;
    if (onChange) {
      onChange({
        oldValue: selected,
        newValue: newValue,
      });
    }
    setSelected(newValue);
  };

  return (
    <select
      id={id}
      className={className + ' '}
      value={selected}
      onChange={handleChange}
    >
      {options.map(option => (
        <option key={option[valueField]} value={option[valueField]}>
          {option[labelField]}
        </option>
      ))}
    </select>
  );
};

DropDown.propTypes = {
  id: PropTypes.string.isRequired,
  options: PropTypes.array.isRequired,
  value: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
  ]),
  valueField: PropTypes.string,
  labelField: PropTypes.string,
  className: PropTypes.string,
  onChange: PropTypes.func,
};

export default DropDown;
