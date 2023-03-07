/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';
import DBDefs from '../static/scripts/common/DBDefs.mjs';

import DocSearchBox from './components/DocSearchBox.js';

type DocPageT = {
  +content: string,
  +hierarchy: $ReadOnlyArray<string>,
  +title: string,
  +version: number,
};

type Props = {
  +id: string,
  +page: DocPageT,
};

const DocPage = ({
  id,
  page,
}: Props): React$Element<typeof Layout> => {
  let doc = '';
  let lastDoc = '';
  // We check whether we have a Google Custom Search engine
  const useGoogleCustomSearch = !!DBDefs.GOOGLE_CUSTOM_SEARCH;
  const wikiPageUrl = `//${DBDefs.WIKITRANS_SERVER}/${id}`;
  const wikiPage = (
    <a
      className="internal"
      href={wikiPageUrl}
    >
      {page.title}
    </a>
  );
  const wikiVersion = (
    <a
      className="internal"
      href={`//${wikiPageUrl}?oldid=${page.version}`}
    >
      {'#' + page.version}
    </a>
  );
  return (
    <Layout fullWidth noIcons title={page.title}>
      <div className="wikicontent" id="content">
        {useGoogleCustomSearch ? <DocSearchBox /> : null}

        <h1 className="hierarchy-links">
          {page.hierarchy.map((link, index, array) => {
            lastDoc = doc;
            doc = index === 0 ? link : lastDoc + '/' + link;
            const isLast = array.length - 1 === index;
            return (
              <React.Fragment key={index + '-' + link}>
                <a
                  href={'/doc/' + doc.replace(/ /g, '_')}
                  style={{fontWeight: isLast ? 'bold' : ''}}
                >
                  {link}
                </a>
                {isLast ? null : ' / '}
              </React.Fragment>
            );
          })}
        </h1>

        {page.version ? null : (
          <div className="wikidocs-header">
            {exp.l(`This page has not been reviewed by our documentation team
                    ({more_info|more info}).`,
                   {more_info: '/doc/WikiDocs'})}
          </div>
        )}

        <div dangerouslySetInnerHTML={{__html: page.content}} />

        <div className="wikidocs-footer">
          {page.version ? (
            exp.l(`This page is {doc|transcluded} from revision {version}
                    of {title}.`,
                  {
                    doc: '/doc/WikiDocs',
                    title: wikiPage,
                    version: wikiVersion,
                  })
          ) : (
            exp.l('This page is {doc|transcluded} from {title}.',
                  {doc: '/doc/WikiDocs', title: wikiPage})
          )}
        </div>
      </div>
    </Layout>
  );
};

export default DocPage;
