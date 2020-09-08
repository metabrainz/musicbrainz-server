// @flow

/* eslint-disable multiline-comment-style */

import * as d3array from 'd3-array';
import * as d3axis from 'd3-axis';
import * as d3fetch from 'd3-fetch';
import * as d3format from 'd3-format';
import * as d3shape from 'd3-shape';
import * as d3scale from 'd3-scale';
import * as d3selection from 'd3-selection';
import * as React from 'react';

import StatisticsLayoutContent
  from '../../../../../statistics/StatisticsLayoutContent';
import stats, {buildTypeStats, getStat}
  from '../../../../../statistics/stats';
import {performHydrate} from '../../../../../utility/hydrate';
import {
  DEFAULT_LINES,
  EMPTY_EXTENT,
  GRAPH_WIDTH,
  GRAPH_HEIGHT,
  GRAPH_MARGIN_TOP,
  GRAPH_MARGIN_LEFT,
  GRAPH_MARGIN_BOTTOM,
  GRAPH_MARGIN_RIGHT,
} from '../constants';
import reducer from '../reducer';
import type {
  InstanceT,
  PropsT,
  StateT,
  WritableCategoryT,
} from '../types';

import TimelineSidebar from './TimelineSidebar';

function createInitialState({$c, instanceRef}): StateT {
  const categoryMap = new Map<string, WritableCategoryT>();
  return {
    categories: getInitialLines($c).reduce((accum, name) => {
      const newLine: {
        category: string,
        color: string,
        description: string,
        hide?: boolean,
        label: string,
      } = (getStat(name): any);

      const categoryName = newLine.category;
      let category = categoryMap.get(categoryName);
      if (!category) {
        const statsCategory = stats.category[categoryName];
        category = {
          ...statsCategory,
          enabled: !statsCategory.hide,
          index: accum.length,
          lines: [],
          name: categoryName,
        };
        categoryMap.set(categoryName, category);
        accum.push(category);
      }

      const enabled = !newLine.hide;
      category.lines.push({
        ...newLine,
        data: null,
        dataExtentX: EMPTY_EXTENT,
        dataExtentY: EMPTY_EXTENT,
        enabled,
        index: category.lines.length,
        invertedData: null,
        loading: false,
        name,
      });
      return accum;
    }, []),
    events: [],
    eventsEnabled: true,
    instanceRef,
    rateOfChangeGraphEnabled: false,
    zoom: {
      xaxis: {max: null, min: null},
      yaxis: {max: null, min: null},
    },
  };
}

function* allLines(categories) {
  for (const category of categories) {
    if (category.enabled) {
      for (const line of category.lines) {
        if (line.enabled && line.data) {
          yield line;
        }
      }
    }
  }
}

const formatNumber = d3format.format(',.0f');
const getDate = d => d[0];
const getCount = d => d[1];
const getJsDate = e => e.jsDate;

function drawTimeline(instance, state) {
  const allLinesArray = Array.from(allLines(state.categories));

  const xExtent = d3array.extent(
    allLinesArray.flatMap(line => line.dataExtentX),
  );
  const yExtent = d3array.extent(
    allLinesArray.flatMap(line => line.dataExtentY),
  );

  const xScale = d3scale
    .scaleTime()
    .rangeRound([GRAPH_MARGIN_LEFT, GRAPH_WIDTH - GRAPH_MARGIN_RIGHT])
    .domain(xExtent);

  const yScale = d3scale
    .scaleLinear()
    .rangeRound([GRAPH_HEIGHT - GRAPH_MARGIN_BOTTOM, GRAPH_MARGIN_TOP])
    .domain(yExtent);

  const xAxis = d3axis
    .axisBottom(xScale);

  const yAxis = d3axis
    .axisLeft(yScale)
    .ticks(7, formatNumber);

  const svgGraph = d3selection
    .select('#graph-svg')
    .attr('width', GRAPH_WIDTH)
    .attr('height', GRAPH_HEIGHT);

  svgGraph
    .selectAll('*')
    .remove();

  svgGraph
    .append('g')
    .attr('transform', `translate(${GRAPH_MARGIN_LEFT},0)`)
    .call(yAxis);

  svgGraph
    .append('g')
    .attr('transform', `translate(0,${GRAPH_HEIGHT - GRAPH_MARGIN_BOTTOM})`)
    .call(xAxis);

  // Draw events
  if (state.eventsEnabled) {
    for (const event of state.events) {
      const scaledX = xScale(event.jsDate);
      if (Number.isNaN(scaledX) || scaledX < GRAPH_MARGIN_LEFT) {
        continue;
      }
      svgGraph
        .append('line')
        .attr('x1', scaledX)
        .attr('y1', GRAPH_MARGIN_TOP)
        .attr('x2', scaledX)
        .attr('y2', GRAPH_HEIGHT - GRAPH_MARGIN_BOTTOM)
        .attr('stroke-width', 1)
        .attr('stroke', 'rgba(170, 0, 0, 0.20)');
    }
  }

  const highlightedEventLine = svgGraph
    .append('line')
    .attr('x1', 0)
    .attr('y1', GRAPH_MARGIN_TOP)
    .attr('x2', 0)
    .attr('y2', GRAPH_HEIGHT - GRAPH_MARGIN_BOTTOM)
    .attr('stroke-width', 1)
    .attr('stroke', 'rgb(170, 0, 0)')
    .style('opacity', '0');

  const lineGenerator = d3shape.line()
    .x(d => xScale(d[0]))
    .y(d => yScale(d[1]));

  const tooltip = instance.tooltipRef;

  // Draw lines
  for (const line of allLines(state.categories)) {
    let data = line.data;
    /* flow-include
    // XXX This is already checked by `allLines`.
    if (!data) throw 'not possible';
    */
    /*
     * Reduce the number of points used in the line if its greater than
     * the width of the graph in pixels divided by two.
     */
    const reductionFactor = Math.round(
      data.length /
      (GRAPH_WIDTH - GRAPH_MARGIN_LEFT - GRAPH_MARGIN_RIGHT) *
      2,
    );
    if (reductionFactor > 1) {
      data = data.reduce((accum, x, i) => {
        if (i % reductionFactor === 0) {
          accum.push(x);
        }
        return accum;
      }, []);
    }
    svgGraph
      .append('path')
      .datum(data)
      .attr('d', lineGenerator)
      .attr('stroke', line.color)
      .attr('stroke-width', 2.5)
      .attr('fill', 'none');
  }

  const cursor = svgGraph
    .append('g')
    .append('circle')
    .style('fill', 'black')
    .attr('stroke', 'none')
    .attr('r', 5)
    .style('opacity', 0);

  svgGraph
    .style('pointer-events', 'all')
    .on('mousemove', function (event) {
      const pointerCoords = d3selection.pointer(event);
      const domainX = xScale.invert(pointerCoords[0]);
      const domainY = yScale.invert(pointerCoords[1]);
      const graphRect = svgGraph.node().getBoundingClientRect();
      const graphXOffset = (window.scrollX + graphRect.left) / 2;
      const graphYOffset = (window.scrollY + graphRect.top) / 2;
      let bestLineMatch = null;

      for (const line of allLines(state.categories)) {
        const lineData = line.data;
        /* flow-include if (!lineData) throw 'not possible'; */
        // Find the closest point on the line to the current pointer X value.
        const dataIndex = d3array
          .bisector(getDate)
          .center(lineData, domainX);
        let point = lineData[dataIndex];
        let scaledX = xScale(point[0]);
        let scaledY = yScale(point[1]);
        let distance = Math.sqrt(
          Math.pow(scaledX - pointerCoords[0], 2) +
          Math.pow(scaledY - pointerCoords[1], 2),
        );

        if (distance > 1) {
          /*
           * In cases where the slope of the line is close to undefined, we
           * may need to use the Y-axis instead via `invertedData`. Note that
           * the curve can technically pass through this Y value multiple
           * times, but this doesn't seem to happen in practice in our
           * 'counts' data.
           */
          const invertedDataIndex = d3array
            .bisector(getCount)
            .center(line.invertedData, domainY);
          const point2 = lineData[invertedDataIndex];
          const scaledX2 = xScale(point2[0]);
          const scaledY2 = yScale(point2[1]);
          const distance2 = Math.sqrt(
            Math.pow(scaledX2 - pointerCoords[0], 2) +
            Math.pow(scaledY2 - pointerCoords[1], 2),
          );
          if (distance2 < distance) {
            point = point2;
            scaledX = scaledX2;
            scaledY = scaledY2;
            distance = distance2;
          }
        }

        if (distance > 10 ||
          (bestLineMatch && distance >= bestLineMatch.distance)) {
          continue;
        }

        bestLineMatch = {
          color: line.color,
          distance,
          domainY: point[1],
          scaledX,
          scaledY,
        };

        if (distance <= 1) {
          break;
        }
      }

      let scaledX = 0;
      let scaledY = 0;
      let tooltipText = '';

      if (bestLineMatch) {
        scaledX = bestLineMatch.scaledX;
        scaledY = bestLineMatch.scaledY;
        tooltipText = formatNumber(bestLineMatch.domainY);
        cursor
          .attr('cx', scaledX)
          .attr('cy', scaledY)
          .style('fill', bestLineMatch.color)
          .style('opacity', '1');
        highlightedEventLine.style('opacity', '0');
      } else {
        cursor.style('opacity', '0');

        if (state.eventsEnabled && state.events.length) {
          const eventIndex = d3array
            .bisector(getJsDate)
            .center(state.events, domainX);
          const event = state.events[eventIndex];
          scaledX = xScale(event.jsDate);
          if (scaledX >= GRAPH_MARGIN_LEFT) {
            const distance = Math.abs(scaledX - pointerCoords[0]);
            if (distance <= 5) {
              scaledY = pointerCoords[1];
              tooltipText = event.title;
              highlightedEventLine
                .attr('x1', scaledX)
                .attr('x2', scaledX)
                .style('opacity', '1');
            }
          }
        }
      }

      const tooltipSelector = d3selection
        .select(tooltip)
        .html(tooltipText);

      if (tooltipText) {
        const tooltipPageX = scaledX + graphXOffset + 10;
        const tooltipPageY = scaledY + graphYOffset + 10;
        tooltipSelector
          .style('left', tooltipPageX + 'px')
          .style('top', tooltipPageY + 'px')
          .style('opacity', '1');
      } else {
        tooltipSelector.style('opacity', '0');
      }
    });
}

function getInitialLines($c) {
  let path;
  if (typeof document === 'undefined') {
    const URL = require('url');
    path = URL.parse($c.req.uri).pathname;
  } else {
    path = document.location.pathname;
  }
  const match = path?.match(
    /\/statistics\/timeline\/(.+)$/,
  );
  let lines;
  if (match) {
    lines = (match[1] ?? '').split('+');
  }
  if (!lines || lines.length === 1 && lines[0] === 'main') {
    return DEFAULT_LINES;
  }
  return lines;
}

const Timeline = ({$c}: PropsT): React.MixedElement => {
  const instanceRef = React.useRef<InstanceT | null>(null);

  const [state, dispatch] = React.useReducer(
    reducer,
    {$c, instanceRef},
    createInitialState,
  );

  if (!instanceRef.current) {
    instanceRef.current = {
      appliedInitialHash: false,
      dispatch,
      loadingEvents: false,
      svgGraphRef: null,
      tooltipRef: null,
    };
  }

  const instance = instanceRef.current;

  React.useEffect(() => {
    const handleHashChange = () => {
      dispatch({type: 'apply-location-hash-change'});
    };
    window.addEventListener('hashchange', handleHashChange);

    /*
     * This can't be done in createInitialState, because the initial rendered
     * output after hydration has to exactly match the server's output.
     */
    setTimeout(() => {
      handleHashChange();
    }, 1);

    return () => {
      window.removeEventListener('hashchange', handleHashChange);
    };
  }, []);

  React.useEffect(() => {
    if (!(state.events.length || instance.loadingEvents)) {
      instance.loadingEvents = true;
      d3fetch.json('/ws/js/events').then((data) => {
        dispatch({events: data, type: 'set-events'});
        setTimeout(() => {
          instance.loadingEvents = false;
        }, 1);
      });
    }
  }, [
    state.events.length,
    instance.loadingEvents,
  ]);

  React.useEffect(() => {
    if (!instance.appliedInitialHash) {
      return;
    }
    for (const category of state.categories) {
      if (category.enabled) {
        for (const line of category.lines) {
          if (line.enabled && !line.data && !line.loading) {
            dispatch({line, type: 'load-line-data'});
          }
        }
      }
    }
  }, [
    instance.appliedInitialHash,
    state.categories,
  ]);

  React.useEffect(() => {
    drawTimeline(instance, state);
  }, [instance, state]);

  return (
    <StatisticsLayoutContent
      page="timeline"
      sidebar={<TimelineSidebar dispatch={dispatch} state={state} />}
    >
      <div id="graph-container">
        <svg
          id="graph-svg"
          ref={(node) => {
            // $FlowFixMe
            instance.svgGraphRef = node;
          }}
          style={{height: '400px', width: '100%'}}
        />
      </div>
      <div
        ref={(node) => {
          // $FlowFixMe
          instance.tooltipRef = node;
        }}
        style={{opacity: '0', position: 'absolute'}}
      />
    </StatisticsLayoutContent>
  );
};

export default Timeline;

if (typeof window !== 'undefined') {
  d3fetch.json('./type-data').then((data) => {
    buildTypeStats(data);
    performHydrate('#page', Timeline);
  });
}
