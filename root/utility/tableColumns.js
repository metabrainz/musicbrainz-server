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
import CDTocLink from '../static/scripts/common/components/CDTocLink';
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
import localizeLanguageName
  from '../static/scripts/common/i18n/localizeLanguageName';
import yesNo from '../static/scripts/common/utility/yesNo';
import type {ReportRelationshipRoleT} from '../report/types';

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
    cellProps: {className: 'actions'},
    Header: l('Actions'),
    headerProps: {className: 'actions'},
    id: 'actions',
  };
}

export function defineArtistCreditColumn<D>(
  props: {
    ...OrderableProps,
    +columnName: string,
    +getArtistCredit: (D) => ArtistCreditT | null,
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
    id: props.columnName,
  };
}

export function defineBeginDateColumn(
  props: OrderableProps,
): ColumnOptions<{+begin_date: PartialDateT, ...}, PartialDateT> {
  return {
    accessor: x => x.begin_date,
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
    id: 'begin_date',
  };
}

export function defineCDTocColumn<D>(
  props: {
    ...OrderableProps,
    +getCDToc: (D) => CDTocT | null,
  },
): ColumnOptions<D, string> {
  return {
    Cell: ({row: {original}}) => {
      const cdToc = props.getCDToc(original);
      return (cdToc ? (
        <CDTocLink
          cdToc={cdToc}
          content={cdToc.discid}
        />
      ) : null);
    },
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={l('Disc ID')}
          name="cd-toc"
          order={props.order ?? ''}
        />
      )
      : l('Disc ID')),
    id: 'cd-toc',
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
    accessor: row => props.getCount(row),
    Cell: ({cell: {value}}) => (
      <CatalystContext.Consumer>
        {($c: CatalystContextT) => formatCount($c, value)}
      </CatalystContext.Consumer>
    ),
    cellProps: {className: 'c'},
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={props.title}
          name={props.columnName}
          order={props.order ?? ''}
        />
      )
      : props.title),
    headerProps: {className: 'count c'},
    id: props.columnName,
  };
}

export function defineDatePeriodColumn<D>(
  props: {
    ...OrderableProps,
    +getEntity: (D) => EventT | null,
  },
): ColumnOptions<D, string> {
  return {
    Cell: ({row: {original}}) => {
      const entity = props.getEntity(original);
      return entity ? formatDatePeriod(entity) : null;
    },
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
    +descriptive?: boolean,
    +getEntity: (D) => CoreEntityT | null,
    +subPath?: string,
    +title: string,
  },
): ColumnOptions<D, string> {
  const descriptive =
    hasOwnProp(props, 'descriptive')
      ? props.descriptive
      : true;
  const subPath =
    hasOwnProp(props, 'subPath')
      ? props.subPath
      : '';
  return {
    Cell: ({row: {original}}) => {
      const entity = props.getEntity(original);
      return (entity
        ? descriptive
          ? <DescriptiveLink entity={entity} subPath={subPath} />
          : (
            <EntityLink
              entity={entity}
              // Event lists show date in its own column
              showEventDate={false}
              subPath={subPath}
            />
          )
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
    id: 'instrument-usage',
  };
}

export function defineLocationColumn<D>(
  props: {
    +getEntity: (D) => EventT | null,
  },
): ColumnOptions<D, string> {
  return {
    Cell: ({row: {original}}) => {
      const entity = props.getEntity(original);
      return entity ? <EventLocations event={entity} /> : null;
    },
    Header: N_l('Location'),
    id: 'location',
  };
}

export function defineLinkColumn<D>(
  props: {
    +columnName: string,
    getContent: (D) => string,
    getHref: (D) => string,
    +title: string,
  },
): ColumnOptions<D, string> {
  return {
    accessor: row => props.getContent(row) ?? '',
    Cell: ({row: {original}}) => (
      <a href={props.getHref(original)}>
        {props.getContent(original)}
      </a>
    ),
    Header: props.title,
    id: props.columnName,
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
    id: 'name',
  };
}

export function defineRatingsColumn<D>(
  props: {
    +getEntity: (D) => RatableT | null,
  },
): ColumnOptions<D, number> {
  return {
    Cell: ({row: {original}}) => {
      const ratableEntity = props.getEntity(original);
      if (ratableEntity == null) {
        return null;
      }
      return (
        <RatingStars entity={ratableEntity} />
      );
    },
    cellProps: {className: 'c'},
    Header: N_l('Rating'),
    headerProps: {className: 'rating c'},
    id: 'rating',
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
    accessor: x => x.events,
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
    id: 'events',
  };
}

export function defineReleaseLabelsColumn(
  props: OrderableProps,
): ColumnOptions<ReleaseT, ?$ReadOnlyArray<ReleaseLabelT>> {
  return {
    accessor: x => x.labels,
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
    id: 'labels',
  };
}

export function defineReleaseLanguageColumn<D>(
  props: {
    +getEntity: (D) => ReleaseT | null,
  },
): ColumnOptions<D, void> {
  return {
    Cell: ({row: {original}}) => {
      const entity = props.getEntity(original);
      return entity ? <ReleaseLanguageScript release={entity} /> : null;
    },
    Header: N_l('Language'),
    id: 'release_language',
  };
}

export function defineSeriesNumberColumn(
  props: {
    +seriesItemNumbers: $ReadOnlyArray<string>,
  },
): ColumnOptions<CoreEntityT, number> {
  return {
    Cell: ({row: {index}}) => props.seriesItemNumbers[index],
    cellProps: {className: 'number-column'},
    Header: l('#'),
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
    cellProps: props.cellProps,
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={props.title}
          name={props.columnName}
          order={props.order ?? ''}
        />
      )
      : props.title),
    headerProps: props.headerProps,
    id: props.columnName,
  };
}

export function defineTextHtmlColumn<D>(
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
    Cell: ({row: {original}}) => (
      <div dangerouslySetInnerHTML={{__html: props.getText(original)}} />
    ),
    cellProps: props.cellProps,
    Header: (props.sortable
      ? (
        <SortableTableHeader
          label={props.title}
          name={props.columnName}
          order={props.order ?? ''}
        />
      )
      : props.title),
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
    accessor: x => x.typeName,
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
    id: 'type',
  };
}

export const attributesColumn:
  ColumnOptions<WorkT, $ReadOnlyArray<WorkAttributeT>> = {
    Cell: ({row: {original}}) => (
      original.attributes ? (
        <ul>
          <AttributeList attributes={original.attributes} />
        </ul>
      ) : null
    ),
    Header: N_l('Attributes'),
    id: 'attributes',
  };

export const instrumentDescriptionColumn:
  ColumnOptions<{+description?: string, ...}, string> = {
    accessor: x => x.description ?? '',
    Cell: ({cell: {value}}) => (value
      ? expand2react(l_instrument_descriptions(value))
      : null),
    Header: N_l('Description'),
    id: 'instrument-description',
  };

export const isrcsColumn:
  ColumnOptions<{
    +isrcs: $ReadOnlyArray<IsrcT>,
    ...
  }, $ReadOnlyArray<IsrcT>> = {
    accessor: x => x.isrcs,
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
    id: 'isrcs',
  };

export const iswcsColumn:
  ColumnOptions<{
    +iswcs: $ReadOnlyArray<IswcT>,
    ...
  }, $ReadOnlyArray<IswcT>> = {
    accessor: x => x.iswcs,
    Cell: ({cell: {value}}) => (
      <ul>
        {value.map((iswc) => (
          <li key={iswc.iswc}>
            <CodeLink code={iswc} />
          </li>
        ))}
      </ul>
    ),
    cellProps: {className: 'iswc'},
    Header: N_l('ISWC'),
    id: 'iswcs',
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

export const relTypeColumn:
  ColumnOptions<$ReadOnly<{...ReportRelationshipRoleT, ...}>, void> = {
    Cell: ({row: {original}}) => (
      <a href={'/relationship/' + encodeURIComponent(original.link_gid)}>
        {l_relationships(original.link_name)}
      </a>
    ),
    Header: N_l('Relationship Type'),
    id: 'relationship_type',
  };

export const seriesOrderingTypeColumn:
  ColumnOptions<{+orderingTypeID?: number, ...}, ?number> = {
    accessor: x => x.orderingTypeID,
    Cell: ({cell: {value}}) => {
      const orderingType = value
        ? linkedEntities.series_ordering_type[value]
        : null;
      return orderingType
        ? lp_attributes(orderingType.name, 'series_ordering_type')
        : null;
    },
    Header: N_l('Ordering Type'),
    id: 'ordering-type',
  };

export const subscriptionColumn:
  ColumnOptions<{+subscribed: boolean, ...}, boolean> = {
    accessor: x => x.subscribed,
    Cell: ({cell: {value}}) => yesNo(value),
    Header: N_l('Subscribed'),
    id: 'subscribed',
  };

export const taggerColumn:
  ColumnOptions<RecordingT | ReleaseT, void> = {
    Cell: ({row: {original}}) => (
      <TaggerIcon entityType={original.entityType} gid={original.gid} />
    ),
    Header: N_l('Tagger'),
    id: 'tagger',
  };

export const trackColumn:
  ColumnOptions<{+track: TrackT, ...}, TrackT> = {
    accessor: x => x.track,
    Cell: ({cell: {value}}) => (
      <a href={'/track/' + value.gid}>
        {value.name}
      </a>
    ),
    Header: N_l('Track'),
    id: 'track',
  };

export const workArtistsColumn:
  ColumnOptions<WorkT, $ReadOnlyArray<ArtistCreditT>> = {
    accessor: x => x.artists,
    Cell: ({cell: {value}}) => <WorkArtists artists={value} />,
    Header: N_l('Artists'),
    id: 'work-artists',
  };

export const workLanguagesColumn:
  ColumnOptions<WorkT, $ReadOnlyArray<WorkLanguageT>> = {
    accessor: x => x.languages,
    Cell: ({cell: {value}}) => (
      <ul>
        {value.map(language => (
          <li
            data-iso-639-3={language.language.iso_code_3}
            key={language.language.id}
          >
            {localizeLanguageName(language.language, true)}
          </li>
        ))}
      </ul>
    ),
    Header: N_l('Lyrics Languages'),
    id: 'lyrics-languages',
  };
