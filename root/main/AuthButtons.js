/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faUser } from '@fortawesome/free-solid-svg-icons';

component AuthButtons() {
  return (
    <div className="auth-buttons layout-width">
      <a href="/register?returnto=%2F" id="create-account">
        <FontAwesomeIcon icon={faUser} />
        Create Account
      </a>
      <a href="/login?returnto=%2F">Login</a>
    </div>
  );
}

export default AuthButtons;