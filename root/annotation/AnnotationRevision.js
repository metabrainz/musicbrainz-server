/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Annotation from '../static/scripts/common/components/Annotation.js';
import chooseLayoutComponent from '../utility/chooseLayoutComponent.js';

type AnnotationRevisionProps = {
  +annotation: AnnotationT | null,
  +entity: AnnotatedEntityT,
  +numberOfRevisions: number,
};

const AnnotationRevision = ({
  annotation,
  entity,
  numberOfRevisions,
}: AnnotationRevisionProps): React.MixedElement => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent
      entity={entity}
      fullWidth
      page="annotation"
      title={l('Annotation')}
    >
      <Annotation
        annotation={annotation}
        entity={entity}
        numberOfRevisions={numberOfRevisions}
        showChangeLog
        showEmpty
      />
    </LayoutComponent>
  );
};

export default AnnotationRevision;
