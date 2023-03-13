/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const TagLookupNagSection = (): React$Element<'div'> => (
  <div className="nagpanel">
    <p>
      {l('The users make MusicBrainz happen and we appreciate your help!')}
    </p>
    <p>
      {exp.l(
        `However, we still have to pay the bills and hosting this site costs
         {finances|more than $1000 per month}. We need our users to help us
         make ends meet and hopefully have money left over to sponsor more
         development. The {metabrainz_foundation|MetaBrainz Foundation}, a
         California based 501(c)3 tax-exempt non-profit, operates the
         MusicBrainz project which makes all donations
         <strong>tax deductible</strong> for US taxpayers.
         And it's simply good karma everywhere else!`,
        {
          finances: 'https://metabrainz.org/finances',
          metabrainz_foundation: 'https://metabrainz.org',
        },
      )}
    </p>
    <p>
      {exp.l(
        `If you donate <strong>$4</strong> you will not get this nag text for 
         a <strong>month</strong>. We encourage people to donate $12 to make
         the nag screen disappear for 3 months. Or even better, sign up for a
         recurring donation every three months to not have to think about or
         see this nag again.`,
      )}
    </p>
    <p className="naglinkpanel">
      <a className="naglink" href="https://metabrainz.org/donate">
        {l('Make a donation now!')}
      </a>
      <br />
      <a href="/account/donation">
        {l('I just donated! Why am I seeing this?')}
      </a>
    </p>
  </div>
);

export default TagLookupNagSection;
