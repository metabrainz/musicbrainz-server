/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type Props = {
  +applicationName: string,
  +fields: {+[fieldName: string]: string, ...},
  +redirectUri: string,
};

const OAuth2FormPost = ({
  applicationName,
  fields,
  redirectUri,
}: Props): React$Element<'html'> => {
  const title = texp.l('Redirecting to {application}', {
    application: applicationName,
  });
  return (
    <html>
      <head>
        <title>{title}</title>
      </head>
      <body>
        <form action={redirectUri} method="post">
          <h1>{title}</h1>
          <p>
            {l(`If this page doesn’t redirect automatically,
                press “Submit” below.`)}
          </p>
          {Object.entries(fields).map(([fieldName, value]) => (
            <input
              key={fieldName}
              name={fieldName}
              type="hidden"
              value={value}
            />
          ))}
          <input type="submit" value={l('Submit')} />
        </form>
        <script
          /*
           * If for some reason you need to change the script below, you
           * should also update its Content-Security-Policy sha256 in
           * Controller::OAuth2::_send_redirect_response.
           */
          dangerouslySetInnerHTML={{
            __html: 'document.forms[0].submit()',
          }}
        />
      </body>
    </html>
  );
};

export default OAuth2FormPost;
