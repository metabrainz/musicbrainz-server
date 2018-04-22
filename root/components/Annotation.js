/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../context';
import EditorLink from '../static/scripts/common/components/EditorLink';
import {l} from '../static/scripts/common/i18n';
import entityHref from '../static/scripts/common/utility/entityHref';
import formatUserDate from '../utility/formatUserDate';

import Frag from './Frag';

type Props = {|
  +$c: CatalystContextT,
  +annotation: ?AnnotationT,
  +collapse?: boolean,
  +entity: CoreEntityT,
  +numberOfRevisions: number,
  +showChangeLog?: boolean,
|};

const Annotation = ({
  $c,
  annotation,
  collapse = false,
  entity,
  numberOfRevisions,
  showChangeLog = false,
}: Props) => {
  if (!annotation || !annotation.text || entity.entityType === 'url') {
    return null;
  }
  const latestAnnotation = entity.latest_annotation;
  return (
    <Frag>
      <h2 className="annotation">{l('Annotation')}</h2>

      <div className="annotation">
        <div
          className={'annotation-body' + (collapse ? ' annotation-collapse' : '')}
          dangerouslySetInnerHTML={{__html: annotation.formatted_wikitext}}
        />

        {showChangeLog ? (
          <p>
            <strong>{l('Changelog:')}</strong>
            {' '}
            {annotation.changelog || l('(no changelog)')}
          </p>
        ) : null}

        <div className="annotation-details">
          {$c.user_exists ? (
            latestAnnotation && (annotation.id === latestAnnotation.id) ? (
              <Frag>
                {l('Annotation last modified by {user} on {date}.', {
                  __react: true,
                  date: formatUserDate($c.user, annotation.creation_date),
                  user: <EditorLink editor={annotation.editor} />,
                })}
                {numberOfRevisions && numberOfRevisions > 1 ? (
                  <Frag>
                    {' '}
                    <a href={entityHref(entity, '/annotations')}>
                      {l('View annotation history')}
                    </a>
                  </Frag>
                ) : null}
              </Frag>
            ) : (
              l('This is an {history|old revision} of this annotation, as edited by {user} on {date}. {current|View current revision}.', {
                __react: true,
                current: entityHref(entity, '/annotation'),
                date: formatUserDate($c.user, annotation.creation_date),
                history: entityHref(entity, '/annotations'),
                user: <EditorLink editor={annotation.editor} />,
              })
            )
          ) : (
            l('Annotation last modified on {date}.', {
              date: formatUserDate($c.user, annotation.creation_date),
            })
          )}
        </div>
      </div>
    </Frag>
  );
};

export default withCatalystContext(Annotation);
