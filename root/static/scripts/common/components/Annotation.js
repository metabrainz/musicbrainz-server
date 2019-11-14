/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import mutate from 'mutate-cow';

import {withCatalystContext} from '../../../../context';
import formatUserDate from '../../../../utility/formatUserDate';
import hydrate from '../../../../utility/hydrate';
import sanitizedEditor from '../../../../utility/sanitizedEditor';
import entityHref from '../utility/entityHref';

import Collapsible from './Collapsible';
import EditorLink from './EditorLink';

type MinimalAnnotatedEntityT = $ReadOnly<{
  ...MinimalCoreEntityT,
  +latest_annotation?: AnnotationT,
  ...,
}>;

type Props = {
  +$c: CatalystContextT | SanitizedCatalystContextT,
  +annotation: ?$ReadOnly<{
    ...AnnotationT,
    +editor: EditorT | SanitizedEditorT | null,
    ...,
  }>,
  +collapse?: boolean,
  +entity: MinimalAnnotatedEntityT,
  +numberOfRevisions: number,
  +showChangeLog?: boolean,
};

type WritableProps = {
  annotation: ?{
    ...AnnotationT,
    editor: EditorT | SanitizedEditorT | null,
    ...,
  },
  entity: MinimalAnnotatedEntityT,
  ...,
};

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
        ? (
          <Collapsible
            className="annotation"
            html={annotation.html}
          />
        ) : (
          <div
            className="annotation-body"
            dangerouslySetInnerHTML={{__html: annotation.html}}
          />
        )}

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
              {exp.l('Annotation last modified by {user} on {date}.', {
                date: formatUserDate($c, annotation.creation_date),
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
            exp.l(
              `This is an {history|old revision} of this annotation,
               as edited by {user} on {date}.
               {current|View current revision}.`,
              {
                current: entityHref(entity, '/annotation'),
                date: formatUserDate($c, annotation.creation_date),
                history: entityHref(entity, '/annotations'),
                user: <EditorLink editor={annotation.editor} />,
              },
            )
          )
        ) : (
          texp.l('Annotation last modified on {date}.', {
            date: formatUserDate($c, annotation.creation_date),
          })
        )}
      </div>
    </>
  );
};

export default withCatalystContext(
  hydrate<Props>('div.annotation', Annotation, function (props) {
    const entity = props.entity;

    return mutate<WritableProps, Props>(props, newProps => {
      const annotation = newProps.annotation;

      // editor data is usually missing on mirror server
      if (annotation && annotation.editor) {
        annotation.editor = sanitizedEditor(annotation.editor);
      }

      newProps.entity = {
        entityType: entity.entityType,
        gid: entity.gid,
        latest_annotation: entity.latest_annotation,
      };
    });
  }),
);
