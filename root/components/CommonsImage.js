// @flow
// Copyright (C) 2017 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

const {l} = require('../static/scripts/common/i18n');

type Props = {
  image?: CommonsImageT | null,
};

const CommonsImage = ({image}: Props) => (
  image ? (
    <div className="picture">
      <img src={image.thumb_url} />
      <br />
      <span className="picture-note">
        <a href={image.page_url}>
          {l('Image from Wikimedia Commons')}
        </a>
      </span>
    </div>
  ) : null
);

module.exports = CommonsImage;
