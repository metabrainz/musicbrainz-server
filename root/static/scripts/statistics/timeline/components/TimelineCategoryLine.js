// @flow

import * as React from 'react';

import type {
  ActionT,
  CategoryLineT,
} from '../types';

type PropsT = {
  +dispatch: (ActionT) => void,
  +line: CategoryLineT,
};

const TimelineCategoryLine = (React.memo<PropsT>(({
  dispatch,
  line,
}: PropsT): React.MixedElement => (
  <div
    className={'graph-control' + (line.loading ? ' loading' : '')}
    id={'graph-control-' + line.name}
    key={line.name}
  >
    <label>
      <input
        checked={line.enabled}
        disabled={line.loading}
        id={'graph-control-checker' + line.name}
        onChange={(event) => {
          dispatch({
            enabled: event.target.checked,
            line,
            type: 'toggle-category-line',
          });
        }}
        type="checkbox"
      />
      <div
        className="graph-color-swatch"
        style={{backgroundColor: line.color}}
      />
      {line.label}
    </label>
  </div>
)): React.AbstractComponent<PropsT>);

export default TimelineCategoryLine;
