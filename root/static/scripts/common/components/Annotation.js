/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../../../../context';
import formatUserDate from '../../../../utility/formatUserDate';
import hydrate from '../../../../utility/hydrate';
import sanitizedEditor from '../../../../utility/sanitizedEditor';
import {l} from '../i18n';
import entityHref from '../utility/entityHref';
import * as lens from '../utility/lens';

import Collapsible from './Collapsible';
import EditorLink from './EditorLink';

type Props = {|
  +$c: CatalystContextT | SanitizedCatalystContextT,
  +annotation: ?AnnotationT,
  +collapse?: boolean,
  +entity: AnnotatedEntityT,
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
  if (!annotation || !annotation.text) {
    return null;
  }
  const latestAnnotation = entity.latest_annotation;
  return (
    <>
      <h2 className="annotation">{l('Annotation')}</h2>

      {collapse
        ? <Collapsible
            className="annotation"
            html={annotation.html}
          />
        : <div
            className="annotation-body"
            dangerouslySetInnerHTML={{__html: annotation.html}}
          />
      }

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
            <>
              {l('Annotation last modified by {user} on {date}.', {
                date: formatUserDate($c.user, annotation.creation_date),
                user: <EditorLink editor={annotation.editor} />,
              })}
              {numberOfRevisions && numberOfRevisions > 1 ? (
                <>
                  {' '}
                  <a href={entityHref(entity, '/annotations')}>
                    {l('View annotation history')}
                  </a>
                </>
              ) : null}
            </>
          ) : (
            l('This is an {history|old revision} of this annotation, as edited by {user} on {date}. {current|View current revision}.', {
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
    </>
  );
};

const annotationLens = lens.compose2(
  lens.prop('annotation'),
  lens.prop('editor'),
);

const entityLens = lens.prop('entity');

export default withCatalystContext(
  hydrate('annotation', Annotation, function (props) {
    // editor data is usually missing on mirror server
    if (props.annotation && props.annotation.editor) {
      props = lens.set(
        annotationLens,
        sanitizedEditor(props.annotation.editor),
        props,
      );
    }
    const entity = props.entity;
    props = lens.set(entityLens, {
      entityType: entity.entityType,
      gid: entity.gid,
      latest_annotation: entity.latest_annotation,
    }, props);
    return props;
  })
);
