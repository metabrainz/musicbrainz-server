// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

const TopMenu = require('./TopMenu');
const BottomMenu = require('./BottomMenu');

const Header = (props) => (
  <div className="header">
    <a href="/" className="logo" title="MusicBrainz">
      <img src="/static/images/layout/header-logo.svg" className="logo" />
    </a>
    <div className="right">
      <TopMenu {...props} />
      <BottomMenu {...props} />
    </div>
  </div>
);

module.exports = Header;
