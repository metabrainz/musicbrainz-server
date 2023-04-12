/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {SanitizedCatalystContext} from '../../../../context.mjs';
import formatUserDate from '../../../../utility/formatUserDate.js';
import sanitizedEditor from '../../../../utility/sanitizedEditor.mjs';
import entityHref from '../utility/entityHref.js';

import Collapsible from './Collapsible.js';
import EditorLink from './EditorLink.js';

type MinimalAnnotatedEntityT = {
  +entityType: AnnotatedEntityT['entityType'],
  +gid: string,
  +latest_annotation?: AnnotationT,
};

type Props = {
  +annotation: ?AnnotationT,
  +collapse?: boolean,
  +entity: $ReadOnly<{
    ...MinimalAnnotatedEntityT,
    ...
  }>,
  +numberOfRevisions: number,
  +showChangeLog?: boolean,
  +showEmpty?: boolean,
};

const Annotation = ({
  annotation,
  collapse = false,
  entity,
  numberOfRevisions,
  showChangeLog = false,
  showEmpty = false,
}: Props) => {
  const annotationIsEmpty = empty(annotation?.text);
  if (!annotation || (annotationIsEmpty && !showEmpty)) {
    return null;
  }
  const latestAnnotation = entity.latest_annotation;
  return (
    <>
      <h2 className="annotation">{l('Annotation')}</h2>

      {(showEmpty && annotationIsEmpty) ? (
        <div className="annotation-body small">
          {l('This annotation is blank.')}
        </div>
      ) : collapse ? (
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

      <SanitizedCatalystContext.Consumer>
        {$c => (
          <div className="annotation-details">
            {$c.user ? (
              latestAnnotation && (annotation.id === latestAnnotation.id) ? (
                <>
                  {exp.l('Annotation last modified by {user} on {date}.', {
                    date: formatUserDate($c, annotation.creation_date),
                    user: <EditorLink editor={annotation.editor} />,
                  })}
                  {' '}
                  {numberOfRevisions && numberOfRevisions > 1 ? (
                    <>
                      <a href={entityHref(entity, '/annotations')}>
                        {l('View annotation history')}
                      </a>
                      {' | '}
                    </>
                  ) : null}
                  <a href={entityHref(entity, 'edit_annotation')}>
                    {l('Edit annotation')}
                  </a>
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
        )}
      </SanitizedCatalystContext.Consumer>
    </>
  );
};

export default (hydrate<Props>(
  'div.annotation',
  Annotation,
  function (props) {
    const newProps: {...Props} = {...props};
    const entity = props.entity;
    const annotation = props.annotation;

    // editor data is usually missing on mirror server
    if (annotation && annotation.editor) {
      const newAnnotation = {...annotation};
      newAnnotation.editor = sanitizedEditor(annotation.editor);
      newProps.annotation = newAnnotation;
    }

    const newEntity: {...MinimalAnnotatedEntityT} = {
      entityType: entity.entityType,
      gid: entity.gid,
    };

    const latestAnnotation = entity.latest_annotation;
    if (latestAnnotation && latestAnnotation.editor) {
      newEntity.latest_annotation = ({
        ...latestAnnotation,
        editor: sanitizedEditor(latestAnnotation.editor),
      }: {...AnnotationT});
    }

    newProps.entity = newEntity;
    return newProps;
  },
): React$AbstractComponent<Props, void>);
