/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function ThemeSwitchButton(props) {
  let active;
  let buttonClassName;
  if (props.dark) {
    active = 'dark';
    buttonClassName = 'SwitchBtn SwitchBtn-Active';
  } else {
    active = 'light';
    buttonClassName = 'SwitchBtn';
  }

  return (
    <div className="DarkThemeSwitchBtn-wrapper">
      <picture className="ThemeIndicator-Icon">
        <img
          alt="icon for lite theme"
          src={`../../../../static/images/${active}-theme/icon-day.svg`}
        />
      </picture>
      <div
        className="SwitchBtn-Track"
        onClick={props.handleTheme}
      >
        <button
          className={buttonClassName}
          type="button"
        />
      </div>
      <picture className="ThemeIndicator-Icon">
        <img
          alt="icon for dark theme"
          src={`../../../../static/images/${active}-theme/icon-night.svg`}
        />
      </picture>
    </div>
  );
}
