/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptions} from 'react-table';

import {CatalystContext} from '../context';
import ENTITIES from '../../entities';
import InstrumentRelTypes from '../components/InstrumentRelTypes';
import RatingStars from '../components/RatingStars';
import ReleaseCatnoList from '../components/ReleaseCatnoList';
import ReleaseLabelList from '../components/ReleaseLabelList';
import ReleaseLanguageScript from '../components/ReleaseLanguageScript';
import SortableTableHeader from '../components/SortableTableHeader';
import linkedEntities from '../static/scripts/common/linkedEntities';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';
import ArtistRoles
  from '../static/scripts/common/components/ArtistRoles';
import AttributeList from '../static/scripts/common/components/AttributeList';
import CodeLink from '../static/scripts/common/components/CodeLink';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
import EntityLink from '../static/scripts/common/components/EntityLink';
import EventLocations
  from '../static/scripts/common/components/EventLocations';
import ExpandedArtistCredit
  from '../static/scripts/common/components/ExpandedArtistCredit';
import ReleaseEvents
  from '../static/scripts/common/components/ReleaseEvents';
import TaggerIcon from '../static/scripts/common/components/TaggerIcon';
import WorkArtists
  from '../static/scripts/common/components/WorkArtists';
import formatDate from '../static/scripts/common/utility/formatDate';
import formatDatePeriod
  from '../static/scripts/common/utility/formatDatePeriod';
import {formatCount} from '../statistics/utilities';
import formatEndDate from '../static/scripts/common/utility/formatEndDate';
import renderMergeCheckboxElement
  from '../static/scripts/common/utility/renderMergeCheckboxElement';
import expand2react from '../static/scripts/common/i18n/expand2react';
import yesNo from '../static/scripts/common/utility/yesNo';

import {returnToCurrentPage} from './returnUri';

type OrderableProps = {
  +order?: string,
  +sortable?: boolean,
};

export function defineActionsColumn(
  props: {+actions: $ReadOnlyArray<[string, string]>},
): ColumnOptions<CoreEntityT | CollectionT, number> {
  return {
    Cell: ({row: {original}}) => (
      <>
        {props.actions.map((actionPair, index) => (
          <React.Fragment key={actionPair[1] + (index === 0 ? '-first' : '')}>
            {index === 0 ? null : ' | '}
            <EntityLink
              content={actionPair[0]}
              entity={original}
              subPath={actionPair[1]}
            />
          </React.Fragment>
        ))}
      </>
    ),
    Header: l('Actions'),
    accessor: x => x.id,
    cellProps: {className: 'actions'},
    headerProps: {className: 'actions'},
    id: 'actions',
  };
}

export function defineArtistCreditColumn<D>(
  props: {
    ...OrderableProps,
    +columnName: string,
    +getArtistCredit: (D) => ArtistCreditT,
    +showExpandedArtistCredits?: boolean,
    +title: string,
  },
): ColumnOptions<D, string> {
  return {
    Cell: ({row: {original}}) => {
      const artistCredit = props.getArtistCredit(original);
      return (artistCredit
        ? props.showExpandedArtistCredits
          ? <ExpandedArtistCredit artistCredit={artistCredit} />
          : <ArtistCreditLink artistCredit={artistCredit} />
        : null
      );
    },
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={props.title}
          name={props.columnName}
          order={props.order ?? ''}
        />
      )
      : props.title),
    accessor: row => props.getArtistCredit(row)?.names[0].name ?? '',
    headerProps: {className: 'artist'},
    id: props.columnName,
  };
}

export function defineArtistRolesColumn<D>(
  props: {
    +columnName: string,
    +getRoles: (D) => $ReadOnlyArray<{
      +credit: string,
      +entity: ArtistT,
      +roles: $ReadOnlyArray<string>,
    }>,
    +title: string,
  },
): ColumnOptions<D, $ReadOnlyArray<{
      +credit: string,
      +entity: ArtistT,
      +roles: $ReadOnlyArray<string>,
}>> {
  return {
    Cell: ({row: {original}}) => (
      <ArtistRoles relations={props.getRoles(original)} />
    ),
    Header: props.title,
    accessor: row => props.getRoles(row) ?? [],
    id: props.columnName,
  };
}

export function defineBeginDateColumn(
  props: OrderableProps,
): ColumnOptions<{+begin_date: PartialDateT, ...}, PartialDateT> {
  return {
    Cell: ({cell: {value}}) => formatDate(value),
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={l('Begin')}
          name="begin_date"
          order={props.order ?? ''}
        />
      )
      : l('Begin')),
    accessor: x => x.begin_date,
    id: 'begin_date',
  };
}

export function defineCheckboxColumn(
  props: {
    +mergeForm?: MergeFormT,
    +name?: string,
  },
): ColumnOptions<CoreEntityT, number> {
  return {
    Cell: ({row: {index, original}}) => props.mergeForm
      ? renderMergeCheckboxElement(original, props.mergeForm, index)
      : (
        <input
          name={props.name}
          type="checkbox"
          value={original.id}
        />
      ),
    Header: props.mergeForm ? '' : <input type="checkbox" />,
    headerProps: {className: 'checkbox-cell'},
    id: 'checkbox',
  };
}

export function defineCountColumn<D>(
  props: {
    ...OrderableProps,
    +columnName: string,
    +getCount: (D) => number,
    +title: string,
  },
): ColumnOptions<D, number> {
  return {
    Cell: ({cell: {value}}) => (
      <CatalystContext.Consumer>
        {($c: CatalystContextT) => formatCount($c, value)}
      </CatalystContext.Consumer>
    ),
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={props.title}
          name={props.columnName}
          order={props.order ?? ''}
        />
      )
      : props.title),
    accessor: row => props.getCount(row),
    cellProps: {className: 'c'},
    headerProps: {className: 'count c'},
    id: props.columnName,
  };
}

export function defineDatePeriodColumn(
  props: OrderableProps,
): ColumnOptions<{...DatePeriodRoleT, ...}, string> {
  return {
    Cell: ({row: {original}}) => formatDatePeriod(original),
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={l('Date')}
          name="date"
          order={props.order ?? ''}
        />
      )
      : l('Date')),
    id: 'date',
  };
}

export function defineEndDateColumn(
  props: OrderableProps,
): ColumnOptions<{...DatePeriodRoleT, ...}, PartialDateT | null> {
  return {
    Cell: ({row: {original}}) => formatEndDate(original),
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={l('End')}
          name="end_date"
          order={props.order ?? ''}
        />
      )
      : l('End')),
    id: 'end_date',
  };
}

export function defineEntityColumn<D>(
  props: {
    ...OrderableProps,
    +columnName: string,
    +getEntity: (D) => CoreEntityT | null,
    +title: string,
  },
): ColumnOptions<D, string> {
  return {
    Cell: ({row: {original}}) => {
      const entity = props.getEntity(original);
      return (entity
        ? <DescriptiveLink entity={entity} />
        : null);
    },
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={props.title}
          name={props.columnName}
          order={props.order ?? ''}
        />
      )
      : props.title),
    accessor: row => props.getEntity(row)?.name ?? '',
    id: props.columnName,
  };
}

export function defineInstrumentUsageColumn(
  props: {
    +instrumentCreditsAndRelTypes?:
      {+[entityGid: string]: $ReadOnlyArray<string>},
  },
): ColumnOptions<ArtistT | RecordingT | ReleaseT, number> {
  return {
    Cell: ({row: {original}}) => (
      <InstrumentRelTypes
        entity={original}
        instrumentCreditsAndRelTypes={props.instrumentCreditsAndRelTypes}
      />
    ),
    Header: l('Relationship Types'),
    accessor: x => x.id,
    id: 'instrument-usage',
  };
}

export function defineNameColumn<T: CoreEntityT | CollectionT>(
  props: {
    ...OrderableProps,
    +descriptive?: boolean,
    +showCaaPresence?: boolean,
    +title: string,
  },
): ColumnOptions<T, string> {
  const descriptive =
    hasOwnProp(props, 'descriptive')
      ? props.descriptive
      : true;
  return {
    Cell: ({row: {original}}) => (
      descriptive
        ? <DescriptiveLink entity={original} />
        : (
          <EntityLink
            entity={original}
            // Event lists show date in its own column
            showCaaPresence={props.showCaaPresence}
            showEventDate={false}
          />
        )
    ),
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={props.title}
          name="name"
          order={props.order ?? ''}
        />
      )
      : props.title),
    accessor: x => x.name,
    id: 'name',
  };
}

export function defineReleaseCatnosColumn<D>(
  props: {
    ...OrderableProps,
    getLabels: (D) => $ReadOnlyArray<ReleaseLabelT>,
  },
): ColumnOptions<D, $ReadOnlyArray<ReleaseLabelT>> {
  return {
    Cell: ({row: {original}}) => (
      <ReleaseCatnoList labels={props.getLabels(original)} />
    ),
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={l('Catalog#')}
          name="catno"
          order={props.order ?? ''}
        />
      )
      : l('Catalog#')),
    id: 'catno',
  };
}

export function defineReleaseEventsColumn(
  props: OrderableProps,
): ColumnOptions<ReleaseT, ?$ReadOnlyArray<ReleaseEventT>> {
  return {
    Cell: ({cell: {value}}) => <ReleaseEvents events={value} />,
    Header: (props.sortable
      ? (
        <>
          <SortableTableHeader
            label={l('Country')}
            name="country"
            order={props.order ?? ''}
          />
          {lp('/', 'and')}
          <SortableTableHeader
            label={l('Date')}
            name="date"
            order={props.order ?? ''}
          />
        </>
      )
      : l('Country') + lp('/', 'and') + l('Date')
    ),
    accessor: x => x.events,
    id: 'events',
  };
}

export function defineReleaseLabelsColumn(
  props: OrderableProps,
): ColumnOptions<ReleaseT, ?$ReadOnlyArray<ReleaseLabelT>> {
  return {
    Cell: ({cell: {value}}) => <ReleaseLabelList labels={value} />,
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={l('Label')}
          name="label"
          order={props.order ?? ''}
        />
      )
      : l('Label')
    ),
    accessor: x => x.labels,
    id: 'labels',
  };
}

export function defineSeriesNumberColumn(
  props: {
    +seriesItemNumbers: $ReadOnlyArray<string>,
  },
): ColumnOptions<CoreEntityT, number> {
  return {
    Cell: ({row: {index}}) => props.seriesItemNumbers[index],
    Header: l('#'),
    accessor: x => x.id,
    cellProps: {className: 'number-column'},
    headerProps: {className: 'number-column'},
    id: 'series-number',
  };
}

export function defineTextColumn<D>(
  props: {
    ...OrderableProps,
    +cellProps?: {className: string, ...},
    +columnName: string,
    +getText: (D) => string,
    +headerProps?: {className: string, ...},
    +title: string,
  },
): ColumnOptions<D, StrOrNum> {
  return {
    Cell: ({row: {original}}) => props.getText(original),
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={props.title}
          name={props.columnName}
          order={props.order ?? ''}
        />
      )
      : props.title),
    accessor: row => props.getText(row) ?? '',
    cellProps: props.cellProps,
    headerProps: props.headerProps,
    id: props.columnName,
  };
}

export function defineTypeColumn(
  props: {
    ...OrderableProps,
    +typeContext: string,
  },
): ColumnOptions<{+typeName: string, ...}, string> {
  return {
    Cell: ({cell: {value}}) => (value
      ? lp_attributes(value, props.typeContext)
      : null),
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={l('Type')}
          name="type"
          order={props.order ?? ''}
        />
      )
      : l('Type')),
    accessor: x => x.typeName,
    id: 'type',
  };
}

export const attributesColumn:
  ColumnOptions<WorkT, $ReadOnlyArray<WorkAttributeT>> = {
    Cell: ({row: {original}}) => <AttributeList entity={original} />,
    Header: N_l('Attributes'),
    accessor: x => x.attributes,
    id: 'attributes',
  };

export const instrumentDescriptionColumn:
  ColumnOptions<{+description?: string, ...}, string> = {
    Cell: ({cell: {value}}) => (value
      ? expand2react(l_instrument_descriptions(value))
      : null),
    Header: N_l('Description'),
    accessor: x => x.description ?? '',
    id: 'instrument-description',
  };

export const isrcsColumn:
  ColumnOptions<{
    +isrcs: $ReadOnlyArray<IsrcT>,
    ...
  }, $ReadOnlyArray<IsrcT>> = {
    Cell: ({cell: {value}}) => (
      <ul>
        {value.map((isrc) => (
          <li key={isrc.isrc}>
            <CodeLink code={isrc} />
          </li>
        ))}
      </ul>
    ),
    Header: N_l('ISRCs'),
    accessor: x => x.isrcs,
    id: 'isrcs',
  };

type AcoustIdTrackT = {
  +disabled?: boolean,
  +id: string,
};

const AcoustIdCell = ({
  isLoading,
  tracks,
}: {
  +isLoading: boolean,
  +tracks: ?$ReadOnlyArray<AcoustIdTrackT>,
}): React.Element<typeof React.Fragment> => (
  <>
    {isLoading ? (
      <p className="loading-message">
        {l('Loading...')}
      </p>
    ) : (
      tracks?.length ? (
        <ul>
          {tracks.map((track) => (
            <li key={track.id}>
              <code>
                <a
                  className={'external' +
                    (track.disabled ? ' disabled-acoustid' : '')}
                  href={`//acoustid.org/track/${track.id}`}
                >
                  {track.id.slice(0, 6) + '…'}
                </a>
              </code>
            </li>
          ))}
        </ul>
      ) : null
    )}
  </>
);

export const useAcoustIdsColumn = (
  recordings: $ReadOnlyArray<RecordingT>,
  showAcoustIds: boolean,
): ColumnOptions<{+gid?: string, ...}, string> | null => {
  const [data, setData] = React.useState<{
    +[recordingMbid: string]: $ReadOnlyArray<AcoustIdTrackT>,
  } | null>(null);
  const [isLoading, setLoading] = React.useState(showAcoustIds);

  React.useEffect(() => {
    if (showAcoustIds) {
      const url = '//api.acoustid.org/v2/track/list_by_mbid' +
        '?format=json&disabled=1&batch=1' +
        recordings.map(x => '&mbid=' + x.gid).join('');

      fetch(url)
        .then(
          resp => resp.json(),
        )
        .then((reqData) => {
          setData(reqData.mbids.reduce((result, x) => {
            result[x.mbid] = x.tracks;
            return result;
          }, {}));
        })
        .finally(() => {
          setLoading(false);
        });
    }
  }, [recordings, showAcoustIds]);

  if (!showAcoustIds) {
    return null;
  }

  return {
    Cell: ({cell: {value}}) => (
      <AcoustIdCell
        isLoading={isLoading}
        tracks={data?.[value] ?? null}
      />
    ),
    Header: N_l('AcoustIDs'),
    accessor: x => x.gid ?? '',
    id: 'acoustid',
  };
};

export const iswcsColumn:
  ColumnOptions<{
    +iswcs: $ReadOnlyArray<IswcT>,
    ...
  }, $ReadOnlyArray<IswcT>> = {
    Cell: ({cell: {value}}) => (
      <ul>
        {value.map((iswc) => (
          <li key={iswc.iswc}>
            <CodeLink code={iswc} />
          </li>
        ))}
      </ul>
    ),
    Header: N_l('ISWC'),
    accessor: x => x.iswcs,
    cellProps: {className: 'iswc'},
    id: 'iswcs',
  };

export const locationColumn:
  ColumnOptions<EventT, number> = {
    Cell: ({row: {original}}) => <EventLocations event={original} />,
    Header: N_l('Location'),
    id: 'location',
  };

export const ratingsColumn:
  ColumnOptions<RatableT, number> = {
    Cell: ({row: {original}}) => <RatingStars entity={original} />,
    Header: N_l('Rating'),
    cellProps: {className: 'c'},
    headerProps: {className: 'rating c'},
    id: 'rating',
  };

export const removeFromMergeColumn:
  ColumnOptions<ArtistT | RecordingT | ReleaseT, number> = {
    Cell: ({row: {original}}) => {
      const url = ENTITIES[original.entityType].url;
      return (
        <CatalystContext.Consumer>
          {($c: CatalystContextT) => (
            <a
              href={
                `/${url}/merge?remove=${original.id}&submit=remove&` +
                returnToCurrentPage($c)
              }
            >
              <button
                className="remove-item icon"
                title={l('Remove from merge')}
                type="button"
              />
            </a>
          )}
        </CatalystContext.Consumer>
      );
    },
    Header: '',
    headerProps: {
      'aria-label': l('Remove from merge'),
      'style': {width: '1em'},
    },
    id: 'remove-from-merge',
  };

export const releaseLanguageColumn:
  ColumnOptions<ReleaseT, void> = {
    Cell: ({row: {original}}) => <ReleaseLanguageScript release={original} />,
    Header: N_l('Language'),
    id: 'release_language',
  };

export const seriesOrderingTypeColumn:
  ColumnOptions<{+orderingTypeID?: number, ...}, ?number> = {
    Cell: ({cell: {value}}) => {
      const orderingType = value ?
        linkedEntities.series_ordering_type[value]
        : null;
      return orderingType
        ? lp_attributes(orderingType.name, 'series_ordering_type')
        : null;
    },
    Header: N_l('Ordering Type'),
    accessor: x => x.orderingTypeID,
    id: 'ordering-type',
  };

export const subscriptionColumn:
  ColumnOptions<{+subscribed: boolean, ...}, boolean> = {
    Cell: ({cell: {value}}) => yesNo(value),
    Header: N_l('Subscribed'),
    accessor: x => x.subscribed,
    id: 'subscribed',
  };

export const taggerColumn:
  ColumnOptions<RecordingT | ReleaseT, void> = {
    Cell: ({row: {original}}) => <TaggerIcon entity={original} />,
    Header: N_l('Tagger'),
    id: 'tagger',
  };

export const workArtistsColumn:
  ColumnOptions<WorkT, $ReadOnlyArray<ArtistCreditT>> = {
    Cell: ({cell: {value}}) => <WorkArtists artists={value} />,
    Header: N_l('Artists'),
    accessor: x => x.artists,
    id: 'work-artists',
  };

export const workLanguagesColumn:
  ColumnOptions<WorkT, $ReadOnlyArray<WorkLanguageT>> = {
    Cell: ({cell: {value}}) => (
      <ul>
        {value.map(language => (
          <li
            data-iso-639-3={language.language.iso_code_3}
            key={language.language.id}
          >
            {l_languages(language.language.name)}
          </li>
        ))}
      </ul>
    ),
    Header: N_l('Lyrics Languages'),
    accessor: x => x.languages,
    id: 'lyrics-languages',
  };
