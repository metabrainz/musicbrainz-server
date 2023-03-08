/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as Sentry from '@sentry/browser';
import * as React from 'react';

type Props = {
  +children: React$Node,
};

type State = {
  errorMessage: string,
};

export default class ErrorBoundary extends React.Component<Props, State> {
  static getDerivedStateFromError(error: Error): {+errorMessage: string} {
    return {errorMessage: error.message ?? String(error)};
  }

  constructor(props: Props) {
    super(props);
    this.state = {errorMessage: ''};
  }

  componentDidCatch(error: Error, info: {componentStack: string, ...}) {
    Sentry.withScope(function (scope) {
      scope.setExtra('componentStack', info.componentStack);
      Sentry.captureException(error);
    });
  }

  render(): React$Node {
    const errorMessage = this.state.errorMessage;
    if (errorMessage) {
      return <div className="error">{errorMessage}</div>;
    }
    return this.props.children;
  }
}
