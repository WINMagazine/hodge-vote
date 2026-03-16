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

-- 1e. Seed Hodge Trophy candidates
INSERT INTO candidates (name, school, weight_class, record, color, display_order) VALUES
  ('Mitchell Mesenbrink', 'Penn State', 'Jr.', '22-0 | 8 Pins, 8 TF, 5 MD, 1 F/Def | 100%', '#041E42', 1),
  ('Josh Barr',           'Penn State', 'So.', '19-0 | 5 Pins, 10 TF, 4 MD, 0 F/Def | 100%', '#041E42', 2),
  ('Jax Forrest',         'OK State',   'Fr.', '13-0 | 2 Pins, 9 TF, 1 MD, 0 F/Def | 92.3%', '#FF7300', 3),
  ('Jesse Mendez',        'Ohio State',  'Sr.', '22-0 | 6 Pins, 10 TF, 3 MD, 0 F/Def | 86.4%', '#BB0000', 4),
  ('Isaac Trumble',       'NC State',    'Sr.', '16-0 | 4 Pins, 3 TF, 5 MD, 1 F/Def | 81.3%', '#CC0000', 5),
  ('Shayne Van Ness',     'Penn State',  'Jr.', '21-0 | 5 Pins, 8 TF, 4 MD, 0 F/Def | 81.0%', '#041E42', 6),
  ('Levi Haines',         'Penn State',  'Sr.', '21-0 | 5 Pins, 10 TF, 2 MD, 0 F/Def | 81.0%', '#041E42', 7),
  ('Yonger Bastida',      'Iowa State',  'Sr.', '25-0 | 2 Pins, 15 TF, 1 MD, 0 F/Def | 72.0%', '#C8102E', 8),
  ('Luke Lilledahl',      'Penn State',  'So.', '20-0 | 1 Pin, 8 TF, 3 MD, 1 F/Def | 65.0%', '#041E42', 9);
