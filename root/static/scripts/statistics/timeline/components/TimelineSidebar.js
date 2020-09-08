// @flow

import * as React from 'react';

import type {ActionT, StateT} from '../types';

import TimelineCategory from './TimelineCategory';

type PropsT = {
  +dispatch: (ActionT) => void,
  +state: StateT,
};

const TimelineSidebar = (React.memo<PropsT>(({
  state,
  dispatch,
}: PropsT): React.MixedElement => {
  return (
    <div id="sidebar">
      <h2 id="graph-toggle-header">{l('Legend')}</h2>
      <div id="graph-lines">
        <h2>
          <input
            checked={state.eventsEnabled}
            id="disable-events-checkbox"
            onChange={(event) => {
              dispatch({
                enabled: event.target.checked,
                type: 'toggle-events',
              });
            }}
            type="checkbox"
          />
          <label htmlFor="disable-events-checkbox">
            {l('MusicBrainz Events')}
          </label>
        </h2>
        <h2 className="collapse-top-margin">
          <input
            checked={state.rateOfChangeGraphEnabled}
            id="show-rate-graph"
            onChange={(event) => {
              dispatch({
                enabled: event.target.checked,
                type: 'toggle-rate-of-change-graph',
              });
            }}
            type="checkbox"
          />
          <label htmlFor="show-rate-graph">{l('Rate of Change Graph')}</label>
        </h2>
        {state.categories.map((category) => (
          <TimelineCategory
            category={category}
            dispatch={dispatch}
            key={category.name}
          />
        ))}
      </div>
      <h2>{l('Controls')}</h2>
      <div id="graph-controls">
        <table className="timeline-controls">
          <tbody>
            <tr>
              <th>{l('Zoom:')}</th>
              <td>{l('Draw a rectangle on either graph')}</td>
            </tr>
            <tr>
              <th>{l('Reset:')}</th>
              <td>{l('Click to deselect')}</td>
            </tr>
            <tr>
              <th>{l('Add/remove lines:')}</th>
              <td>{l('Check boxes above')}</td>
            </tr>
            <tr>
              <th>{l('MusicBrainz Events:')}</th>
              <td>{l('Hover and click on vertical lines')}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}): React.AbstractComponent<PropsT>);

export default TimelineSidebar;
