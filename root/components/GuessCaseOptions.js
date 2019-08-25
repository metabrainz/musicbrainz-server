import React, {useState} from 'react';

import * as modes from '../static/scripts/guess-case/modes';
import expand2react from '../static/scripts/common/i18n/expand2react';

const GuessCaseOptions = () => {
  const [state, setState] = useState({
    keepUpperCase: true,
    selected: 'English',
    upperCaseRoman: true,
  });
  return (
    <table>
      <tbody>
        <tr>
          <td>
            <select
            // eslint-disable-next-line react/jsx-no-bind
              onChange={(e) => setState({selected: e.target.value})}
              value={state.selected}
            >
              <option value="English">{l('English')}</option>
              <option value="Sentence">{l('Sentence')}</option>
              <option value="French">{l('French')}</option>
              <option value="Turkish">{l('Turkish')}</option>
            </select>
            <br />
            <label>
              <input
                checked
                // eslint-disable-next-line react/jsx-no-bind
                onChange={(e) => {
                  return setState({...state, keepUpperCase: e.target.value});
                }}
                type="checkbox"
                value={state.keepUpperCase}
              />
              {l('Keep all-uppercase words uppercased')}
            </label>
            <br />
            <label>
              <input
                // eslint-disable-next-line react/jsx-no-bind
                onChange={(e) => {
                  return setState({...state, upperCaseRoman: e.target.value})
                }}
                type="checkbox"
                value={state.upperCaseRoman}
              />
              {l('Uppercase roman numerals')}
            </label>
          </td>
          <td>
            <span>
              {expand2react(modes[state.selected].description)}
            </span>
          </td>
        </tr>
      </tbody>
    </table>
  );
};

export default GuessCaseOptions;
