// @flow

type SerialLineDataT = $ReadOnlyArray<[Date, number]>;

export type LineDataT = {
  +[date: string]: number,
};

export type ExtentT = [number | void, number | void];

type WritableCategoryLineT = {
  +category: string,
  +color: string,
  data: SerialLineDataT | null,
  dataExtentX: ExtentT,
  dataExtentY: ExtentT,
  +description: string,
  enabled: boolean,
  +hide?: boolean,
  +index: number,
  invertedData: SerialLineDataT | null,
  +label: string,
  loading: boolean,
  +name: string,
};

export type CategoryLineT =
  $ReadOnly<WritableCategoryLineT>;

export type WritableCategoryT = {
  enabled: boolean,
  // Used to determine whether the category is enabled by default.
  +hide?: boolean,
  +index: number,
  +label: string,
  lines: Array<WritableCategoryLineT>,
  +name: string,
};

export type CategoryT = $ReadOnly<{
  ...WritableCategoryT,
  +lines: $ReadOnlyArray<CategoryLineT>,
}>;

type TimelineEventT = {
  +date: string,
  +description: string,
  jsDate: Date,
  +link: string,
  +title: string,
};

type WritableZoomAxisT = {
  max: number | null,
  min: number | null,
};

type ZoomAxisT = $ReadOnly<WritableZoomAxisT>;

type WritableZoomSettingsT = {
  xaxis: WritableZoomAxisT,
  yaxis: WritableZoomAxisT,
};

type ZoomSettingsT = {
  +xaxis: ZoomAxisT,
  +yaxis: ZoomAxisT,
};

export type WritableStateT = {
  categories: Array<WritableCategoryT>,
  events: $ReadOnlyArray<TimelineEventT>,
  eventsEnabled: boolean,
  +instanceRef: {current: InstanceT | null},
  rateOfChangeGraphEnabled: boolean,
  zoom: WritableZoomSettingsT,
};

export type PropsT = {
  +$c: CatalystContextT,
};

export type StateT = $ReadOnly<{
  ...WritableStateT,
  +categories: $ReadOnlyArray<CategoryT>,
  +zoom: ZoomSettingsT,
}>;

/*
 * Data which doesn't directly affect the render() output.
 * Stored in a ref rather than state.
 */
export type InstanceT = {
  appliedInitialHash: boolean,
  +dispatch: (ActionT) => void,
  loadingEvents: boolean,
  svgGraphRef: Element | null,
  tooltipRef: HTMLDivElement | null,
};

/* eslint-disable flowtype/sort-keys */
export type ActionT =
  | {+type: 'apply-location-hash-change'}
  | {+type: 'load-line-data', +line: CategoryLineT}
  | {+type: 'set-events', +events: $ReadOnlyArray<TimelineEventT>}
  | {+type: 'set-line-data', +data: SerialLineDataT, +line: CategoryLineT}
  | {+type: 'toggle-category', +name: string, +enabled: boolean}
  | {+type: 'toggle-category-line', +line: CategoryLineT, +enabled: boolean}
  | {+type: 'toggle-events', +enabled: boolean}
  | {+type: 'toggle-rate-of-change-graph', +enabled: boolean};
/* eslint-enable flowtype/sort-keys */
