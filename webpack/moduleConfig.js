/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const CleanCSSPlugin = require('less-plugin-clean-css');

const ignore = require('./babel-ignored');
const {PRODUCTION_MODE} = require('./constants');

const lessOptions = {};

if (PRODUCTION_MODE) {
  lessOptions.plugins = [
    new CleanCSSPlugin(),
  ];
}

module.exports = {
  noParse: /^(jquery|knockout)$/,

  rules: [
    {
      exclude: ignore,
      test: /\.js$/,
      use: {
        loader: 'babel-loader',
        options: {
          cacheDirectory: true,
        },
      },
    },
    {
      test: /\.(png|svg|jpg|gif)$/,
      use: [
        {
          loader: 'file-loader',
          options: {
            name: (
              PRODUCTION_MODE
                ? '[name]-[hash:7].[ext]'
                : '[name].[ext]'
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
              PRODUCTION_MODE
                ? '[name]-[hash:7].css'
                : '[name].css'
            ),
          },
        },
        {
          loader: 'less-loader',
          options: {lessOptions},
        },
      ],
    },
    {
      test: /leaflet\.markercluster/,
      use: [
        {
          loader: 'imports-loader',
          options: {
            imports: [
              {
                moduleName: 'leaflet/dist/leaflet-src',
                name: 'L',
                syntax: 'single',
              },
            ],
            type: 'commonjs',
          },
        },
      ],
    },
  ],
};
