SET client_min_messages TO 'warning';

INSERT INTO editor (id, name, privs, password, ha1)
    VALUES (1, 'normal_editor', 0, '{CLEARTEXT}password', 'aa550c5b01407ef1f3f0d16daf9ec3c8'),
           (2, 'autoeditor', 1, '{CLEARTEXT}password', 'aa550c5b01407ef1f3f0d16daf9ec3c8'),
           (3, 'bot', 2, '{CLEARTEXT}password', 'aa550c5b01407ef1f3f0d16daf9ec3c8'),
           -- Reminder: Editor #4 is ModBot
           (5, 'relationship_editor', 1+8, '{CLEARTEXT}password', 'aa550c5b01407ef1f3f0d16daf9ec3c8'),
           (6, 'admin', 1+8+32+128+256+512, '{CLEARTEXT}password', 'aa550c5b01407ef1f3f0d16daf9ec3c8'),
           (7, 'autoeditor_bot', 1+2, '{CLEARTEXT}password', 'aa550c5b01407ef1f3f0d16daf9ec3c8');
