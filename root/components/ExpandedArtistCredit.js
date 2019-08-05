import React from 'react';

import ArtistCreditLink from '../static/scripts/common/components/ArtistCreditLink';
import DescriptiveLink from '../static/scripts/common/components/DescriptiveLink';
import commaOnlyList from '../static/scripts/common/i18n/commaOnlyList';

const ExpandedArtistCredit = ({ac}) => {
  if (ac) {
    const run = ac.name !== ac.names[0].artist.name || ac.names.length > 1 || ac.names[0].artist.comment;
    let showList = false;
    const artistList = [];
    if (run) {
      ac.names.forEach((name) => {
        if (name.artist.name === name.name) {
          artistList.push(<DescriptiveLink entity={name.artist} />);
          if (name.artist.comment) {
            showList = true;
          }
        } else {
          artistList.push(exp.l('{artist} as {name}', {
            artist: <DescriptiveLink entity={name.artist} />,
            name: name.name,
          }));
          showList = true;
        }
      });
    }
    return (
      <>
        <ArtistCreditLink artistCredit={ac} />
        {showList ? <span className="expanded-ac-list">{commaOnlyList(artistList)}</span> : null}
      </>
    );
  }
  return null;
};

export default ExpandedArtistCredit;
