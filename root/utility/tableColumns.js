/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptions} from 'react-table';

import ENTITIES from '../../entities.mjs';
import InstrumentRelTypes from '../components/InstrumentRelTypes.js';
import ReleaseCatnoList from '../components/ReleaseCatnoList.js';
import ReleaseLabelList from '../components/ReleaseLabelList.js';
import ReleaseLanguageScript from '../components/ReleaseLanguageScript.js';
import SortableTableHeader from '../components/SortableTableHeader.js';
import {CatalystContext} from '../context.mjs';
import type {ReportRelationshipRoleT} from '../report/types.js';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';
import ArtistRoles
  from '../static/scripts/common/components/ArtistRoles.js';
import AttributeList
  from '../static/scripts/common/components/AttributeList.js';
import CDTocLink from '../static/scripts/common/components/CDTocLink.js';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import EventLocations
  from '../static/scripts/common/components/EventLocations.js';
import ExpandedArtistCredit
  from '../static/scripts/common/components/ExpandedArtistCredit.js';
import IsrcList from '../static/scripts/common/components/IsrcList.js';
import IswcList from '../static/scripts/common/components/IswcList.js';
import RatingStars from '../static/scripts/common/components/RatingStars.js';
import ReleaseEvents
  from '../static/scripts/common/components/ReleaseEvents.js';
import TaggerIcon from '../static/scripts/common/components/TaggerIcon.js';
import WorkArtists
  from '../static/scripts/common/components/WorkArtists.js';
import expand2react from '../static/scripts/common/i18n/expand2react.js';
import localizeLanguageName
  from '../static/scripts/common/i18n/localizeLanguageName.js';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import formatDate from '../static/scripts/common/utility/formatDate.js';
import formatDatePeriod
  from '../static/scripts/common/utility/formatDatePeriod.js';
import formatEndDate from '../static/scripts/common/utility/formatEndDate.js';
import renderMergeCheckboxElement
  from '../static/scripts/common/utility/renderMergeCheckboxElement.js';
import yesNo from '../static/scripts/common/utility/yesNo.js';
import {formatCount} from '../statistics/utilities.js';

import {returnToCurrentPage} from './returnUri.js';

type OrderableProps = {
  +order?: string,
  +sortable?: boolean,
};

export function defineActionsColumn(
  props: {+actions: $ReadOnlyArray<[string, string]>},
): ColumnOptions<EditableEntityT | CollectionT, number> {
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
  const {
    showExpandedArtistCredits = false,
    sortable = false,
  } = props;

  return {
    Cell: ({row: {original}}) => {
      const artistCredit = props.getArtistCredit(original);
      return (artistCredit
        ? showExpandedArtistCredits
          ? <ExpandedArtistCredit artistCredit={artistCredit} />
          : <ArtistCreditLink artistCredit={artistCredit} />
        : null
      );
    },
    Header: (sortable
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
): ColumnOptions<
  {+begin_date: PartialDateT | null, ...},
  PartialDateT | null,
> {
  const sortable = props.sortable ?? false;

  return {
    accessor: x => x.begin_date,
    Cell: ({cell: {value}}) => formatDate(value),
    Header: (sortable
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
  const sortable = props.sortable ?? false;

  return {
    Cell: ({row: {original}}) => {
      const cdToc = props.getCDToc(original);
      return (cdToc ? (
        <CDTocLink cdToc={cdToc} />
      ) : null);
    },
    Header: (sortable
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
    +mergeForm?: MergeFormT | MergeReleasesFormT,
    +name?: string,
  },
): ColumnOptions<CollectableEntityT | MergeableEntityT, number> {
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
  const sortable = props.sortable ?? false;

  return {
    accessor: row => props.getCount(row),
    Cell: ({cell: {value}}) => (
      <CatalystContext.Consumer>
        {($c: CatalystContextT) => formatCount($c, value)}
      </CatalystContext.Consumer>
    ),
    cellProps: {className: 'c'},
    Header: (sortable
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
  const sortable = props.sortable ?? false;

  return {
    Cell: ({row: {original}}) => {
      const entity = props.getEntity(original);
      return entity ? formatDatePeriod(entity) : null;
    },
    Header: (sortable
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
): ColumnOptions<$ReadOnly<{...DatePeriodRoleT, ...}>, PartialDateT | null> {
  const sortable = props.sortable ?? false;

  return {
    Cell: ({row: {original}}) => formatEndDate(original),
    Header: (sortable
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
    +getEntity: (D) => RelatableEntityT | null,
    +subPath?: string,
    +title: string,
  },
): ColumnOptions<D, string> {
  const descriptive = props.descriptive ?? true;
  const sortable = props.sortable ?? false;
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
    Header: (sortable
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

export function defineNameColumn<T: NonUrlRelatableEntityT | CollectionT>(
  props: {
    ...OrderableProps,
    +descriptive?: boolean,
    +showCaaPresence?: boolean,
    +title: string,
  },
): ColumnOptions<T, string> {
  const descriptive = props.descriptive ?? true;
  const sortable = props.sortable ?? false;

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
    Header: (sortable
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
  const sortable = props.sortable ?? false;

  return {
    Cell: ({row: {original}}) => (
      <ReleaseCatnoList labels={props.getLabels(original)} />
    ),
    Header: (sortable
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
  const sortable = props.sortable ?? false;

  return {
    accessor: x => x.events,
    Cell: ({cell: {value}}) => <ReleaseEvents events={value} />,
    Header: (sortable
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
  const sortable = props.sortable ?? false;

  return {
    accessor: x => x.labels,
    Cell: ({cell: {value}}) => <ReleaseLabelList labels={value} />,
    Header: (sortable
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
): ColumnOptions<EntityWithSeriesT, number> {
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
  const sortable = props.sortable ?? false;

  return {
    Cell: ({row: {original}}) => props.getText(original),
    cellProps: props.cellProps,
    Header: (sortable
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
  const sortable = props.sortable ?? false;

  return {
    Cell: ({row: {original}}) => (
      <div dangerouslySetInnerHTML={{__html: props.getText(original)}} />
    ),
    cellProps: props.cellProps,
    Header: (sortable
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
): ColumnOptions<{+typeName?: string, ...}, string> {
  const sortable = props.sortable ?? false;

  return {
    accessor: x => x.typeName ?? '',
    Cell: ({cell: {value}}) => (value
      ? lp_attributes(value, props.typeContext)
      : null),
    Header: (sortable
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
        <AttributeList attributes={original.attributes} />
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
      <IsrcList isrcs={value} />
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
      <IswcList iswcs={value} />
    ),
    cellProps: {className: 'iswc'},
    Header: N_l('ISWC'),
    id: 'iswcs',
  };

export const removeFromMergeColumn:
  ColumnOptions<EditableEntityT | CollectionT, number> = {
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
      const orderingType = value == null
        ? null
        : linkedEntities.series_ordering_type[value];
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
