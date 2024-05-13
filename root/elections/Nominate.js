/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ConfirmLayout from '../components/ConfirmLayout.js';
import EditorLink from '../static/scripts/common/components/EditorLink.js';

component Nominate(candidate: EditorT, form: SecureConfirmFormT) {
  return (
    <ConfirmLayout
      form={form}
      question={exp.l(
        `Are you sure you want to nominate the editor {editor}
         for auto-editor status?`,
        {editor: <EditorLink editor={candidate} key="editor" />},
      )}
      title={l('Nominate a candidate for auto-editor')}
    />
  );
}

export default Nominate;
