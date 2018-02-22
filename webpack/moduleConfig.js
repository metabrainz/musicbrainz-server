/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const CleanCSSPlugin = require('less-plugin-clean-css');

const DBDefs = require('../root/static/scripts/common/DBDefs');

const lessOptions = {};

if (!DBDefs.DEVELOPMENT_SERVER) {
  lessOptions.plugins = [
    new CleanCSSPlugin(),
  ];
}

module.exports = {
  noParse: /^(jquery|knockout)$/,

  rules: [
    {
      test: /\.js$/,
      exclude: /node_modules/,
      use: 'babel-loader',
    },
    {
      test: /\.(png|svg|jpg|gif)$/,
      use: [
        {
          loader: 'file-loader',
          options: {
            name: (
              DBDefs.DEVELOPMENT_SERVER
                ? '[name].[ext]'
                : '[name]-[hash:7].[ext]'
            ),
          },
        },
      ],
    },
    {
      test: /\.less$/,
      use: [
        {
          loader: 'file-loader',
          options: {
            name: (
              DBDefs.DEVELOPMENT_SERVER
                ? '[name].css'
                : '[name]-[hash:7].css'
            ),
          },
        },
        {
          loader: 'less-loader',
          options: {...lessOptions},
        },
      ],
    },
    {
      test: /leaflet\.markercluster/,
      use: 'imports-loader?L=leaflet/dist/leaflet-src',
    },
  ],
};
