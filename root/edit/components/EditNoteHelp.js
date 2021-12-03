/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type Props = {
  +children?: React$Node,
};

const EditNoteHelp = ({
  children,
}: Props): React$Element<'div'> => (
  <div className="edit-note-help">
    <p>
      {exp.l(
        `Edit notes support
        {doc_formatting|a limited set of wiki formatting options}.
        Please do always keep the {doc_coc|Code of Conduct} in mind
        when writing edit notes!`,
        {
          doc_coc: {href: '/doc/Code_of_Conduct', target: '_blank'},
          doc_formatting: {href: '/doc/Edit_Note', target: '_blank'},
        },
      )}
    </p>
    {children}
  </div>
);

export default EditNoteHelp;
