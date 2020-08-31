// @flow

import type {ExtentT} from './types';

export const DEFAULT_LINES: $ReadOnlyArray<string> = Object.freeze([
  'count.area',
  'count.artist',
  'count.coverart',
  'count.edit',
  'count.edit.open',
  'count.edit.perday',
  'count.edit.perweek',
  'count.editor',
  'count.editor.activelastweek',
  'count.editor.deleted',
  'count.editor.editlastweek',
  'count.editor.valid',
  'count.editor.valid.active',
  'count.editor.votelastweek',
  'count.event',
  'count.instrument',
  'count.label',
  'count.medium',
  'count.place',
  'count.recording',
  'count.release',
  'count.release.has_caa',
  'count.releasegroup',
  'count.series',
  'count.vote',
  'count.vote.perday',
  'count.vote.perweek',
  'count.work',
]);

export const EMPTY_EXTENT: ExtentT =
  Object.freeze([undefined, undefined]);

export const GRAPH_WIDTH = 1000;
export const GRAPH_HEIGHT = 400;
export const GRAPH_MARGIN_TOP = 5;
export const GRAPH_MARGIN_LEFT = 75;
export const GRAPH_MARGIN_BOTTOM = 25;
export const GRAPH_MARGIN_RIGHT = 50;
