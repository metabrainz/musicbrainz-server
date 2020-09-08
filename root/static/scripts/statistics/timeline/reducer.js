// @flow

import * as d3array from 'd3-array';
import * as d3fetch from 'd3-fetch';
import mutate from 'mutate-cow';

import parseDate from './../../common/utility/parseDate';
import type {
  ActionT,
  LineDataT,
  StateT,
  WritableStateT,
} from './types';

function applyLocationHashFromState(state) {
  const optionParts = [];
  if (state.rateOfChangeGraphEnabled) {
    optionParts.push('r');
  }
  if (!state.eventsEnabled) {
    optionParts.push('-v');
  }
  const {xaxis, yaxis} = state.zoom;
  if (
    (xaxis.min || xaxis.max) ||
    (yaxis.min || yaxis.max)
  ) {
    optionParts.push(
      'g-' +
      String(xaxis.min) + '/' +
      String(xaxis.max) + '/' +
      String(yaxis.min) + '/' +
      String(yaxis.max),
    );
  }
  const categoryParts = state.categories
    .reduce(accumCategoryHashPart, [])
    .sort();
  // Change without triggering a hashchange event.
  history.replaceState(
    null,
    '',
    window.location.pathname + '#' +
      optionParts.concat(categoryParts).join('+'),
  );
}

function accumCategoryHashPart(accum, category) {
  const enabledByDefault = !category.hide;
  if (category.enabled !== enabledByDefault) {
    accum.push((category.enabled ? '' : '-') + getCategoryHashId(category));
  }
  if (category.enabled) {
    accum.push(
      ...category.lines.reduce(accumCategoryHashLinePart, []),
    );
  }
  return accum;
}

function accumCategoryHashLinePart(accum, line) {
  const enabledByDefault = !line.hide;
  if (line.enabled !== enabledByDefault) {
    accum.push((line.enabled ? '' : '-') + getLineHashId(line));
  }
  return accum;
}

function getCategoryHashId(category) {
  return 'c-' + category.name;
}

function getLineHashId(line) {
  return line.name.replace(/^count\./, '');
}

function applyLocationHashToState(state: WritableStateT) {
  // XXX: reset to defaults when preference is not expressed
  const parts = window.location.hash.replace(/^#/, '')
    .split('+')
    .filter(Boolean);

  for (const part of parts) {
    let match;
    if ((match = part.match(/^(-)?([rv])-?$/))) { // trailing - for backwards-compatibility
      const enabled = match[1] !== '-';
      switch (match[2]) {
        case 'r':
          state.rateOfChangeGraphEnabled = enabled;
          break;
        case 'v':
          state.eventsEnabled = enabled;
          break;
      }
    } else if ((match = part.match(/^(-)?c-(.*)$/))) {
      const categoryName = match[2];
      const category = state.categories.find(x => x.name === categoryName);
      if (category) {
        category.enabled = match[1] !== '-';
      }
    } else if (/^g\/.*$/.test(part)) {
      const axes = part.split('/').slice(1).map(zoomItemFix);
      const zoomState = state.zoom;
      zoomState.xaxis.min = axes[0];
      zoomState.xaxis.max = axes[1];
      if (axes.length > 2) {
        zoomState.yaxis.min = axes[2];
        zoomState.yaxis.max = axes[3];
      }
    } else if ((match = part.match(/^(-)?(.*)$/))) {
      outer:
      for (const category of state.categories) {
        for (const line of category.lines) {
          if (getLineHashId(line) === match[2]) {
            line.enabled = match[1] !== '-';
            break outer;
          }
        }
      }
    }
  }
}

function findLine(state, line) {
  const category = state.categories.find(
    x => x.name === line.category,
  );
  return (category?.lines[line.index]) ?? null;
}

const sortByDate = (a, b) => a[0] - b[0];

function loadLineData(line, dispatch) {
  return d3fetch.json('/statistics/dataset/' + line.name)
    .then((responseData) => {
      const data: LineDataT = responseData.data;

      const serial = [];
      for (const key in data) {
        serial.push([parseJsDate(key), data[key]]);
      }

      serial.sort(sortByDate);
      dispatch({
        data: serial,
        line,
        type: 'set-line-data',
      });
    });
}

function parseJsDate(dateString) {
  const {year, month, day} = parseDate(dateString);
  return new Date(year ?? 0, (month ?? 1) - 1, day ?? 1);
}

function zoomItemFix(item) {
  return item === 'null' ? null : parseFloat(item);
}

function runReducer(
  mutableState: WritableStateT,
  action: ActionT,
  unwrapProxy: <T>(T) => T,
) {
  const instance = unwrapProxy(mutableState.instanceRef.current);
  /* eslint-disable multiline-comment-style */
  /* flow-include
  if (!instance) {
    throw new Error('instance should not be null');
  }
  */

  switch (action.type) {
    case 'apply-location-hash-change':
      applyLocationHashToState(mutableState);
      instance.appliedInitialHash = true;
      break;
    case 'load-line-data': {
      const mutableLine = findLine(mutableState, action.line);
      if (mutableLine) {
        mutableLine.loading = true;
        loadLineData(action.line, instance.dispatch);
      }
      break;
    }
    case 'set-events':
      for (const event of action.events) {
        event.jsDate = parseJsDate(event.date);
      }
      mutableState.events = action.events;
      break;
    case 'set-line-data': {
      const mutableLine = findLine(mutableState, action.line);
      if (mutableLine) {
        mutableLine.data = action.data;
        mutableLine.dataExtentX = d3array.extent(action.data, d => d[0]);
        mutableLine.dataExtentY = d3array.extent(action.data, d => d[1]);
        mutableLine.invertedData = action.data.slice(0).sort((a, b) => a[1] - b[1]);
        mutableLine.loading = false;
      }
      break;
    }
    case 'toggle-category': {
      const category = mutableState.categories.find(
        x => x.name === action.name,
      );
      if (category) {
        category.enabled = action.enabled;
        applyLocationHashFromState(mutableState);
      }
      break;
    }
    case 'toggle-category-line': {
      const mutableLine = findLine(mutableState, action.line);
      if (mutableLine) {
        mutableLine.enabled = action.enabled;
        applyLocationHashFromState(mutableState);
      }
      break;
    }
    case 'toggle-events':
      mutableState.eventsEnabled = action.enabled;
      applyLocationHashFromState(mutableState);
      break;
    case 'toggle-rate-of-change-graph':
      mutableState.rateOfChangeGraphEnabled = action.enabled;
      applyLocationHashFromState(mutableState);
      break;
    /* flow-include
    default:
      // This will cause Flow to error if we've missed a case
      // of ActionT above.
      declare var unreachable: (empty) => void;
      unreachable(action);
    */
  }
  /* eslint-enable multiline-comment-style */
}

export default function reducer(state: StateT, action: ActionT): StateT {
  return mutate<WritableStateT, StateT>(state, (nextState, unwrapProxy) => {
    runReducer(nextState, action, unwrapProxy);
  });
}
