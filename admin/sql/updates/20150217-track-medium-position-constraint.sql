ALTER TABLE track
    ADD CONSTRAINT track_uniq_medium_position
    UNIQUE USING INDEX track_idx_medium_position_uniq
    DEFERRABLE INITIALLY IMMEDIATE;
