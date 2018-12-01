import React from 'react'
import PropTypes from 'prop-types';

export default class DropDown extends React.Component {
   static propTypes = {
        id: PropTypes.string.isRequired,
        options: PropTypes.array.isRequired,
        value: PropTypes.oneOfType(
            [
                PropTypes.number,
                PropTypes.string
            ]
        ),
        valueField: PropTypes.string,
        labelField: PropTypes.string,
        onChange: PropTypes.func
    };

    getDefaultProps() {
        return {
            value: null,
            valueField: 'value',
            labelField: 'label',
            onChange: null
        };
    }

    getInitialState() {
        var selected = this.getSelectedFromProps(this.props);
        return {
            selected: selected
        }
    }
    
    componentWillReceiveProps(nextProps) {
        var selected = this.getSelectedFromProps(nextProps);
        this.setState({
           selected: selected
        });
    }
    
    getSelectedFromProps(props) {
        var selected;
        if (props.value === null && props.options.length !== 0) {
            selected = props.options[0][props.valueField];
        } else {
            selected = props.value;
        }
        return selected;
    }

    render() {
        var self = this;
        var options = self.props.options.map(function(option) {
            return (
                <option key={option[self.props.valueField]} value={option[self.props.valueField]}>
                    {option[self.props.labelField]}
                </option>
            )
        });
        return (
            <select id={this.props.id} 
                    className={this.props.className + ' '}
                    value={this.state.selected} 
                    onChange={this.handleChange}>
                {options}
            </select>
        )
    }

    handleChange(e) {
        if (this.props.onChange) {
            var change = {
              oldValue: this.state.selected,
              newValue: e.target.value
            };
            this.props.onChange(change);
        }
        this.setState({selected: e.target.value});
    }

};
