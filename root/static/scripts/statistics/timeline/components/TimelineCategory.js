// @flow

import * as React from 'react';

import type {ActionT, CategoryT} from '../types';

import TimelineCategoryLine from './TimelineCategoryLine';

type PropsT = {
  +category: CategoryT,
  +dispatch: (ActionT) => void,
};

const TimelineCategory = (React.memo<PropsT>(({
  category,
  dispatch,
}): React.MixedElement => {
  return (
    <>
      <h2 className="toggler">
        <label>
          <input
            checked={category.enabled}
            id={'category-checker-' + category.name}
            onChange={(event) => {
              dispatch({
                enabled: event.target.checked,
                name: category.name,
                type: 'toggle-category',
              });
            }}
            type="checkbox"
          />
          {category.label}
        </label>
      </h2>
      {category.enabled ? (
        <div className="graph-category" id={'category-' + category.name}>
          {category.lines.map((line) => (
            <TimelineCategoryLine
              dispatch={dispatch}
              key={line.name}
              line={line}
            />
          ))}
        </div>
      ) : null}
    </>
  );
}): React.AbstractComponent<PropsT>);

export default TimelineCategory;
