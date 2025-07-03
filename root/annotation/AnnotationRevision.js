/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import LayoutComponent from '../components/LayoutComponent.js';
import manifest from '../static/manifest.mjs';
import Annotation from '../static/scripts/common/components/Annotation.js';

component AnnotationRevision(
  annotation: AnnotationT | null,
  entity: AnnotatedEntityT,
  numberOfRevisions: number,
) {
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
      {manifest('common/components/Annotation', {async: true})}
    </LayoutComponent>
  );
}

export default AnnotationRevision;
