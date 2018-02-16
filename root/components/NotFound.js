/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const Layout = require('../layout');

type Props = {|
  title: string,
  children: React.Node,
|};

const NotFound = ({title, children}: Props) => (
  <Layout fullWidth title={title}>
    <h1>{title}</h1>
    {children}
  </Layout>
);

module.exports = NotFound;
