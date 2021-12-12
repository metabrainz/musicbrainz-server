/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

function ThemeSwitchButton(props) {
  let active; let buttonClassName;
  if (props.dark) {
    active = 'dark';
    buttonClassName = 'SwitchBtn SwitchBtn-Active';
  } else {
    active = 'light';
    buttonClassName = 'SwitchBtn';
  }

  const activeDayIcon = `../../../../static/images/${active}-theme/icon-day.svg`;
  const activeNightIcon = `../../../../static/images/${active}-theme/icon-night.svg`;

  return (
    <div className="DarkThemeSwitchBtn-wrapper">
      <picture className="ThemeIndicator-Icon">
        <img alt="icon for lite theme" src={activeDayIcon} />
      </picture>
      <div className="SwitchBtn-Track" onClick={props.changeTheme}>
        <button className={buttonClassName} />
      </div>
      <picture className="ThemeIndicator-Icon">
        <img alt="icon for dark theme" src={activeNightIcon} />
      </picture>
    </div>
  );
}

export default ThemeSwitchButton;
