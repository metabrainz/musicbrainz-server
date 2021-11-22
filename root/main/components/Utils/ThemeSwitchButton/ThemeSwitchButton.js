/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from "react";

function ThemeSwitchButton(props) {
    let active, buttonClassName;
    if (props.dark) {
        active = "dark";
        buttonClassName = "SwitchBtn SwitchBtn-Active";
    } else {
        active = "light";
        buttonClassName = "SwitchBtn";
    }

    let activeDayIcon = `../../../../static/images/${active}-theme/icon-day.svg`;
    let activeNightIcon = `../../../../static/images/${active}-theme/icon-night.svg`;

    return (
        <div className="DarkThemeSwitchBtn-wrapper">
            <picture className="ThemeIndicator-Icon">
                <img src={activeDayIcon} alt="icon for lite theme" />
            </picture>
            <div className="SwitchBtn-Track" onClick={props.changeTheme}>
                <button className={buttonClassName}/>
            </div>
            <picture className="ThemeIndicator-Icon">
                <img src={activeNightIcon} alt="icon for dark theme" />
            </picture>
        </div>
    );
}

export default ThemeSwitchButton;
