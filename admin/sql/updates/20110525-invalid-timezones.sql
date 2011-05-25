BEGIN;

UPDATE editor_preference
SET value = updates.new_value
FROM (VALUES
('Etc/GMT+1', 'Africa/Windhoek'),
('Etc/GMT+10', 'Pacific/Guam'),
('Etc/GMT+2', 'Europe/Uzhgorod'),
('Etc/GMT+3', 'Asia/Baghdad'),
('Etc/GMT+4', 'Asia/Aqtau'),
('Etc/GMT+5', 'Asia/Bishkek'),
('Etc/GMT+6', 'Asia/Dhaka'),
('Etc/GMT+8', 'Asia/Ulaanbaatar'),
('Etc/GMT-0', 'Europe/London'),
('Etc/GMT-10', 'America/Adak'),
('Etc/GMT-3', 'America/Santarem'),
('Etc/GMT-4', 'America/Rio_Branco'),
('Etc/GMT-5', 'America/Resolute'),
('Etc/GMT-6', 'America/North_Dakota/Center'),
('Etc/GMT-7', 'America/Inuvik'),
('Etc/GMT-8', 'Pacific/Pitcairn')
) updates (old_value, new_value)
WHERE updates.old_value = editor_preference.value
AND name = 'timezone';

DELETE FROM editor_preference
WHERE name = 'timezone'
AND value IN ('IDLW12', 'Mideast/Riyadh88', 'SystemV/CST6','SystemV/EST5EDT');

COMMIT;
