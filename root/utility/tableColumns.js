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

import InstrumentRelTypes from '../components/InstrumentRelTypes';
import RatingStars from '../components/RatingStars';
import ReleaseCatnoList from '../components/ReleaseCatnoList';
import ReleaseLabelList from '../components/ReleaseLabelList';
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
import ReleaseEvents
  from '../static/scripts/common/components/ReleaseEvents';
import TaggerIcon from '../static/scripts/common/components/TaggerIcon';
import formatDate from '../static/scripts/common/utility/formatDate';
import formatEndDate from '../static/scripts/common/utility/formatEndDate';
import expand2react from '../static/scripts/common/i18n/expand2react';
import yesNo from '../static/scripts/common/utility/yesNo';

export function defineActionsColumn(
  actions: $ReadOnlyArray<[string, string]>,
): ColumnOptions<CoreEntityT | CollectionT, number> {
  return {
    Cell: ({row: {original}}) => (
      <>
        {actions.map((actionPair, index) => (
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
    accessor: 'id',
    className: 'actions',
    id: 'actions',
  };
}

export function defineArtistCreditColumn<D>(
  getArtistCredit: (D) => ArtistCreditT,
  columnName: string,
  title: string,
  order?: string = '',
  sortable?: boolean = false,
): ColumnOptions<D, string> {
  return {
    Cell: ({row: {original}}) => {
      const artistCredit = getArtistCredit(original);
      return (artistCredit
        ? <ArtistCreditLink artistCredit={artistCredit} />
        : null);
    },
    Header: (sortable
      ? (
        <SortableTableHeader
          label={title}
          name={columnName}
          order={order}
        />
      )
      : title),
    accessor: row => getArtistCredit(row)?.names[0].name ?? '',
    id: columnName,
  };
}

export function defineArtistRolesColumn<D>(
  getRoles: (D) => $ReadOnlyArray<{
    +entity: ArtistT,
    +roles: $ReadOnlyArray<string>,
  }>,
  columnName: string,
  title: string,
): ColumnOptions<D, $ReadOnlyArray<{
      +entity: ArtistT,
      +roles: $ReadOnlyArray<string>,
}>> {
  return {
    Cell: ({row: {original}}) => (
      <ArtistRoles relations={getRoles(original)} />
    ),
    Header: title,
    accessor: row => getRoles(row) ?? [],
    id: columnName,
  };
}

export function defineBeginDateColumn(
  order?: string = '',
  sortable?: boolean = false,
): ColumnOptions<{+begin_date: PartialDateT, ...}, PartialDateT> {
  return {
    Cell: ({cell: {value}}) => formatDate(value),
    Header: (sortable
      ? (
        <SortableTableHeader
          label={l('Begin')}
          name="begin_date"
          order={order}
        />
      )
      : l('Begin')),
    accessor: 'begin_date',
    id: 'begin_date',
  };
}

export function defineCheckboxColumn<T>(
  name: string,
): ColumnOptions<EntityRoleT<T>, number> {
  return {
    Cell: ({cell: {value}}) => (
      <input
        name={name}
        type="checkbox"
        value={value}
      />
    ),
    Header: <input type="checkbox" />,
    accessor: 'id',
    className: 'checkbox-cell',
    id: 'checkbox',
  };
}

export function defineEndDateColumn(
  order?: string = '',
  sortable?: boolean = false,
): ColumnOptions<{...DatePeriodRoleT, ...}, PartialDateT> {
  return {
    Cell: ({row: {original}}) => formatEndDate(original),
    Header: (sortable
      ? (
        <SortableTableHeader
          label={l('End')}
          name="end_date"
          order={order}
        />
      )
      : l('End')),
    accessor: 'end_date',
    id: 'end_date',
  };
}

export function defineEntityColumn<D>(
  getEntity: (D) => CoreEntityT,
  columnName: string,
  title: string,
  order?: string = '',
  sortable?: boolean = false,
): ColumnOptions<D, string> {
  return {
    Cell: ({row: {original}}) => {
      const entity = getEntity(original);
      return (entity
        ? <DescriptiveLink entity={entity} />
        : null);
    },
    Header: (sortable
      ? (
        <SortableTableHeader
          label={title}
          name={columnName}
          order={order}
        />
      )
      : title),
    accessor: row => getEntity(row)?.name ?? '',
    id: columnName,
  };
}

export function defineInstrumentUsageColumn(
  instrumentCreditsAndRelTypes?:
    {+[entityGid: string]: $ReadOnlyArray<string>},
): ColumnOptions<ArtistT | RecordingT | ReleaseT, number> {
  return {
    Cell: ({row: {original}}) => (
      <InstrumentRelTypes
        entity={original}
        instrumentCreditsAndRelTypes={instrumentCreditsAndRelTypes}
      />
    ),
    Header: l('Relationship Types'),
    accessor: 'id',
    id: 'instrument-usage',
  };
}

export function defineNameColumn<T: CoreEntityT | CollectionT>(
  title: string,
  order?: string = '',
  sortable?: boolean = false,
  descriptive?: boolean = true,
): ColumnOptions<T, string> {
  return {
    Cell: ({row: {original}}) => (
      descriptive
        ? <DescriptiveLink entity={original} />
        : <EntityLink entity={original} />
    ),
    Header: (sortable
      ? (
        <SortableTableHeader
          label={title}
          name="name"
          order={order}
        />
      )
      : title),
    accessor: 'name',
    id: 'name',
  };
}

export function defineReleaseCatnosColumn<D>(
  getLabels: (D) => $ReadOnlyArray<ReleaseLabelT>,
  order?: string = '',
  sortable?: boolean = false,
): ColumnOptions<D, $ReadOnlyArray<ReleaseLabelT>> {
  return {
    Cell: ({row: {original}}) => (
      <ReleaseCatnoList labels={getLabels(original)} />
    ),
    Header: (sortable
      ? (
        <SortableTableHeader
          label={l('Catalog#')}
          name="catno"
          order={order}
        />
      )
      : l('Catalog#')),
    id: 'catno',
  };
}

export function defineReleaseEventsColumn(
  order?: string = '',
  sortable?: boolean = false,
): ColumnOptions<ReleaseT, $ReadOnlyArray<ReleaseEventT>> {
  return {
    Cell: ({cell: {value}}) => <ReleaseEvents events={value} />,
    Header: (sortable
      ? (
        <>
          <SortableTableHeader
            label={l('Country')}
            name="country"
            order={order}
          />
          {lp('/', 'and')}
          <SortableTableHeader
            label={l('Date')}
            name="date"
            order={order}
          />
        </>
      )
      : l('Country') + lp('/', 'and') + l('Date')
    ),
    accessor: 'events',
    id: 'events',
  };
}

export function defineReleaseLabelsColumn(
  order?: string = '',
  sortable?: boolean = false,
): ColumnOptions<ReleaseT, $ReadOnlyArray<ReleaseLabelT>> {
  return {
    Cell: ({cell: {value}}) => <ReleaseLabelList labels={value} />,
    Header: (sortable
      ? (
        <SortableTableHeader
          label={l('Label')}
          name="label"
          order={order}
        />
      )
      : l('Label')
    ),
    accessor: 'labels',
    id: 'labels',
  };
}

export function defineSeriesNumberColumn(
  seriesItemNumbers: {+[entityId: number]: string},
): ColumnOptions<CoreEntityT, number> {
  return {
    Cell: ({cell: {value}}) => seriesItemNumbers[value],
    Header: l('#'),
    accessor: 'id',
    className: 'number-column',
    id: 'series-number',
  };
}

export function defineTextColumn<D>(
  getText: (D) => string,
  columnName: string,
  title: string,
  order?: string = '',
  sortable?: boolean = false,
  className?: string,
): ColumnOptions<D, StrOrNum> {
  return {
    Cell: ({row: {original}}) => getText(original),
    Header: (sortable
      ? (
        <SortableTableHeader
          label={title}
          name={columnName}
          order={order}
        />
      )
      : title),
    accessor: row => getText(row) ?? '',
    className: className || null,
    id: columnName,
  };
}

export function defineTypeColumn(
  typeContext: string,
  order?: string = '',
  sortable?: boolean = false,
): ColumnOptions<{+typeName: string, ...}, string> {
  return {
    Cell: ({cell: {value}}) => (value
      ? lp_attributes(value, typeContext)
      : null),
    Header: (sortable
      ? (
        <SortableTableHeader
          label={l('Type')}
          name="type"
          order={order}
        />
      )
      : l('Type')),
    accessor: 'typeName',
    id: 'type',
  };
}


export const attributesColumn:
  ColumnOptions<WorkT, $ReadOnlyArray<WorkAttributeT>> = {
    Cell: ({row: {original}}) => <AttributeList entity={original} />,
    Header: N_l('Attributes'),
    accessor: 'attributes',
  };

export const instrumentDescriptionColumn:
  ColumnOptions<{+description?: string, ...}, string> = {
    Cell: ({cell: {value}}) => (value
      ? expand2react(l_instrument_descriptions(value))
      : null),
    Header: N_l('Description'),
    accessor: 'description',
  };

export const iswcsColumn:
  ColumnOptions<{
    +iswcs: $ReadOnlyArray<IswcT>,
    ...,
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
    accessor: 'iswcs',
  };

export const ratingsColumn:
  ColumnOptions<{...RatableRoleT, ...}, number> = {
    Cell: ({row: {original}}) => <RatingStars entity={original} />,
    Header: N_l('Rating'),
    accessor: 'rating',
  };

export const seriesOrderingTypeColumn:
  ColumnOptions<{+orderingTypeID?: number, ...}, number> = {
    Cell: ({cell: {value}}) => {
      const orderingType = linkedEntities.series_ordering_type[value];
      return orderingType
        ? lp_attributes(orderingType.name, 'series_ordering_type')
        : null;
    },
    Header: N_l('Ordering Type'),
    accessor: 'orderingTypeID',
  };


export const subscriptionColumn:
  ColumnOptions<{+subscribed: boolean, ...}, boolean> = {
    Cell: ({cell: {value}}) => yesNo(value),
    Header: N_l('Subscribed'),
    accessor: 'subscribed',
  };

export const taggerColumn:
  ColumnOptions<RecordingT | ReleaseT, void> = {
    Cell: ({row: {original}}) => <TaggerIcon entity={original} />,
    Header: N_l('Tagger'),
    id: 'tagger',
  };

export const workArtistsColumn:
  ColumnOptions<WorkT, $ReadOnlyArray<ArtistCreditT>> = {
    Cell: ({cell: {value}}) => (
      <ul>
        {value.map((artistCredit, i) => (
          <li key={i}>
            <ArtistCreditLink artistCredit={artistCredit} />
          </li>
        ))}
      </ul>
    ),
    Header: N_l('Artists'),
    accessor: 'artists',
  };

export const workLanguagesColumn:
  ColumnOptions<WorkT, $ReadOnlyArray<WorkLanguageT>> = {
    Cell: ({cell: {value}}) => (
      <ul>
        {value.map(language => (
          <li key={language.language.id}>
            <abbr title={l_languages(language.language.name)}>
              {language.language.iso_code_3}
            </abbr>
          </li>
        ))}
      </ul>
    ),
    Header: N_l('Lyrics Languages'),
    accessor: 'languages',
  };
