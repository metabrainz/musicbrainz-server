/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';

type EditTypePropertyProps = {
  +className?: 'even',
  +label: string,
  +property: string,
};

type EditTypeIndexProps = {
  +editType: {
    +canBeApproved: boolean,
    +defaultAutoEdit: boolean,
    +editCategory: string,
    +editName: string,
  },
  +page?: DocPageT,
};

const EditTypeProperty = ({
  className,
  label,
  property,
}: EditTypePropertyProps): React$Element<'tr'> => (
  <tr className={className}>
    <th>{label}</th>
    <td>{property}</td>
  </tr>
);

const EditTypeIndex = ({
  editType,
  page,
}: EditTypeIndexProps): React$Element<typeof Layout> => (
  <Layout fullWidth noIcons title={editType.editName}>
    <h1>{editType.editName}</h1>

    <p>
      <a href="/doc/Edit_Types">{lp('Edit types', 'noun')}</a>
      {' > '}
      {editType.editCategory}
      {' > '}
      {editType.editName}
    </p>

    {page ? (
      <>
        <h2>{l('Description')}</h2>
        <div dangerouslySetInnerHTML={{__html: page.content}} />
      </>
    ) : null}


    <h2>{l('Details')}</h2>
    <table className="tbl edit-type">
      <tbody>
        <EditTypeProperty
          label={l('Can be applied automatically')}
          property={editType.defaultAutoEdit
            ? l('By any editor')
            : editType.canBeApproved
              ? l('By auto-editors only')
              : l('Never')
          }
        />
      </tbody>
    </table>
  </Layout>
);

export default EditTypeIndex;
