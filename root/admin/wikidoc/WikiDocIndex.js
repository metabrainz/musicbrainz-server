/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {CellRenderProps} from 'react-table';

import {SanitizedCatalystContext} from '../../context.mjs';
import useTable from '../../hooks/useTable.js';
import Layout from '../../layout/index.js';
import bracketed from '../../static/scripts/common/utility/bracketed.js';
import {isWikiTranscluder}
  from '../../static/scripts/common/utility/privileges.js';

import type {WikiDocT} from './types.js';

type PropsT = {
  +pages: $ReadOnlyArray<WikiDocT>,
  +updatesRequired: boolean,
  +wikiIsUnreachable: boolean,
  +wikiServer: string,
};

const WikiDocTable = ({
  pages,
  updatesRequired,
  wikiServer,
}: PropsT) => {
  const $c = React.useContext(SanitizedCatalystContext);
  const columns = React.useMemo(
    () => {
      const nameColumn = {
        accessor: (x: WikiDocT) => x.id,
        Cell: ({cell: {value}}: CellRenderProps<WikiDocT, string>) => (
          <a href={'/doc/' + encodeURIComponent(value)}>{value}</a>
        ),
        cellProps: {className: 'title'},
        Header: 'Page name',
        id: 'name',
      };
      const transcludedVersionColumn = {
        accessor: (x: WikiDocT) => x.version,
        cellProps: {
          className: 'c transcluded-version',
          style: (updatesRequired && isWikiTranscluder($c.user))
            ? {textAlign: 'right'}
            : null,
        },
        Header: 'Transcluded version',
        headerProps: {className: 'c'},
        id: 'transcluded-version',
      };
      const wikiVersionColumn = {
        accessor: (x: WikiDocT) => x.wiki_version,
        Cell: ({row: {original}}: CellRenderProps<WikiDocT, number>) => (
          <>
            {original.wiki_version === original.version ? null : (
              <>
                <span
                  className="wiki-version"
                  style={{color: 'red'}}
                >
                  {original.wiki_version === 0
                    ? 'Error!'
                    : original.wiki_version}
                </span>
                {original.wiki_version ? (
                  <>
                    {' '}
                    {bracketed(
                      <a
                        href={'//' + wikiServer +
                              '/' + encodeURIComponent(original.id) +
                              '?diff=' + original.wiki_version +
                              '&oldid=' + original.version}
                      >
                        {'diff'}
                      </a>,
                    )}
                  </>
                ) : null}
              </>
            )}
          </>
        ),
        Header: 'Wiki version',
        headerProps: {className: 'c'},
        id: 'wiki-version',
      };
      const actionsColumn = {
        accessor: (x: WikiDocT) => x.id,
        Cell: ({row: {original}}: CellRenderProps<WikiDocT, string>) => (
          <>
            <a href={'/admin/wikidoc/edit' +
                     '?page=' + encodeURIComponent(original.id) +
                     '&new_version=' + original.wiki_version}
            >
              {'Update'}
            </a>
            {' | '}
            <a href={'/admin/wikidoc/delete' +
                     '?page=' + encodeURIComponent(original.id)}
            >
              {'Remove'}
            </a>
            {' | '}
            <a href={'//' + wikiServer +
                     '/' + encodeURIComponent(original.id)}
            >
              {'View on wiki'}
            </a>
          </>
        ),
        cellProps: {className: 'actions c'},
        Header: 'Actions',
        headerProps: {className: 'c'},
        id: 'actions',
      };

      return [
        nameColumn,
        transcludedVersionColumn,
        wikiVersionColumn,
        ...(isWikiTranscluder($c.user) ? [actionsColumn] : []),
      ];
    },
    [
      $c.user,
      updatesRequired,
      wikiServer,
    ],
  );

  return useTable<WikiDocT>({
    className: 'wiki-pages',
    columns,
    data: pages,
  });
};

const WikiDocIndex = (props: PropsT): React$Element<typeof Layout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <Layout fullWidth title="Transclusion table">
      <div className="content">
        <h1>{'Transclusion table'}</h1>
        <p>
          {exp.l_admin(
            `Read the {doc|WikiDocs} documentation for an overview of how
             transclusion works.`,
            {doc: '/doc/WikiDocs'},
          )}
        </p>
        {isWikiTranscluder($c.user) ? (
          <>
            <ul>
              <li key="create">
                <a href="/admin/wikidoc/create">
                  {'Add a new entry'}
                </a>
              </li>
              <li key="history">
                <a href="/admin/wikidoc/history">
                  {'View transclusion history'}
                </a>
              </li>
            </ul>
            <p>
              {exp.l_admin(`<strong>Note:</strong> MediaWiki does not check to
                            see if the version number matches the page name,
                            it will take the version number and provide
                            whatever page is associated with it. Make sure to
                            double check your work when updating a page!`)}
            </p>
          </>
        ) : null}

        {props.wikiIsUnreachable ? (
          <p style={{color: 'red', fontWeight: 'bold'}}>
            {'There was a problem accessing the wiki API.'}
          </p>
        ) : null}
      </div>

      <WikiDocTable {...props} />
    </Layout>
  );
};

export default WikiDocIndex;
