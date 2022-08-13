/*
 * @flow
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ENTITIES from '../../entities.mjs';
import {SanitizedCatalystContext} from '../context.mjs';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import DiffSide from '../static/scripts/edit/components/edit/DiffSide.js';
import {INSERT, DELETE} from '../static/scripts/edit/utility/editDiff.js';
import chooseLayoutComponent from '../utility/chooseLayoutComponent.js';
import formatUserDate from '../utility/formatUserDate.js';

type AnnotationComparisonProps = {
  +entity: AnnotatedEntityT,
  +newAnnotation: AnnotationT,
  +numberOfRevisions: number,
  +oldAnnotation: AnnotationT,
};

const AnnotationComparison = ({
  entity,
  newAnnotation,
  numberOfRevisions,
  oldAnnotation,
}: AnnotationComparisonProps): React.MixedElement => {
  const $c = React.useContext(SanitizedCatalystContext);
  const entityType = entity.entityType;
  const entityUrlFragment = ENTITIES[entityType].url;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent
      entity={entity}
      fullWidth
      page="annotation-comparison"
      title={l('Annotation comparison')}
    >
      <h2>{l('Annotation comparison')}</h2>

      <div className="annotation">
        <div className="annotation-diff">
          <h3>{l('Old annotation')}</h3>
          <p>
            <DiffSide
              filter={DELETE}
              newText={newAnnotation.text ?? ''}
              oldText={oldAnnotation.text ?? ''}
              split="\s+"
            />
          </p>
          <h3>{l('New annotation')}</h3>
          <p>
            <DiffSide
              filter={INSERT}
              newText={newAnnotation.text ?? ''}
              oldText={oldAnnotation.text ?? ''}
              split="\s+"
            />
          </p>
        </div>

        <div className="annotation-details">
          {exp.l(
            `Comparing revision by {user_old} on {date_old}
             with revision by {user_new} on {date_new}.`,
            {
              date_new: formatUserDate($c, newAnnotation.creation_date),
              date_old: formatUserDate($c, oldAnnotation.creation_date),
              user_new: <EditorLink editor={newAnnotation.editor} />,
              user_old: <EditorLink editor={oldAnnotation.editor} />,
            },
          )}

          {numberOfRevisions > 1 ? (
            <>
              {' '}
              <a
                href={`/${entityUrlFragment}/${entity.gid}/annotations`}
              >
                {l('View annotation history.')}
              </a>
            </>
          ) : null}
        </div>
      </div>
    </LayoutComponent>
  );
};

export default AnnotationComparison;
