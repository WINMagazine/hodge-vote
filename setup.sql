-- ============================================
-- Dan Hodge Trophy Live Vote System
-- Supabase Database Setup
-- ============================================

-- 1a. Create candidates table
CREATE TABLE candidates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  school text NOT NULL,
  weight_class text,
  record text,
  color text NOT NULL,
  display_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_select_candidates" ON candidates FOR SELECT TO anon USING (true);

-- 1b. Create votes table
CREATE TABLE votes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name text NOT NULL,
  last_name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  candidate_id uuid NOT NULL REFERENCES candidates(id),
  consent_texts boolean NOT NULL DEFAULT true,
  consent_emails boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE votes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_select_votes" ON votes FOR SELECT TO anon USING (true);

-- 1c. Enable realtime on votes
ALTER PUBLICATION supabase_realtime ADD TABLE votes;

-- 1d. Create vote_counts view
CREATE OR REPLACE VIEW vote_counts AS
SELECT c.id, c.name, c.school, c.weight_class, c.record, c.color, c.display_order,
       COUNT(v.id)::int AS vote_count
FROM candidates c LEFT JOIN votes v ON v.candidate_id = c.id
GROUP BY c.id ORDER BY c.display_order;

GRANT SELECT ON vote_counts TO anon;

-- 1e. Seed 6 placeholder candidates
INSERT INTO candidates (name, school, weight_class, record, color, display_order) VALUES
  ('Penn State Wrestler',   'Penn State',      '157 lbs', '25-0', '#041E42', 1),
  ('Iowa Wrestler',         'Iowa',            '165 lbs', '23-1', '#FFCD00', 2),
  ('Cornell Wrestler',      'Cornell',         '141 lbs', '22-2', '#B31B1B', 3),
  ('Oklahoma State Wrestler','Oklahoma State', '174 lbs', '24-1', '#FF7300', 4),
  ('Missouri Wrestler',     'Missouri',        '184 lbs', '21-3', '#F1B82D', 5),
  ('Arizona State Wrestler','Arizona State',   '197 lbs', '20-2', '#8C1D40', 6);
