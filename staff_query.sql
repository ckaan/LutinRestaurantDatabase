-- =====================================================================
-- CSC 370 Group 47 - Restaurant Management Database (Sprint 2)
-- staff_query.sql: Staff and Labour queries
-- =====================================================================

USE restaurant_ops;

-- Q1: Active staff of a restaurant with their role and department
-- RA: π[staff_id, name, role_name, department](σ[restaurant_id = 1 ∧ is_active = TRUE](Staff ⋈ Role))
SELECT s.staff_id, s.name, s.role_name, r.department
FROM Staff AS s
JOIN Role AS r ON (s.restaurant_id = r.restaurant_id AND s.role_name = r.role_name)
WHERE s.restaurant_id = 1 AND s.is_active = TRUE
ORDER BY r.department, s.name;



-- Q2: Active staff with no shift scheduled next week
-- RA: A ← σ[restaurant_id = 1 ∧ is_active = TRUE](Staff); π[staff_id, name](A) ∖ π[staff_id, name](A ⋈ σ[start_at ≥ '2026-11-09' ∧ start_at < '2026-11-16'](Shift))
SELECT s.staff_id, s.name
FROM Staff AS s
WHERE s.restaurant_id = 1 AND s.is_active = TRUE
  AND NOT EXISTS (
      SELECT *
      FROM Shift AS sh
      WHERE sh.staff_id = s.staff_id
        AND sh.start_at >= '2026-11-09' AND sh.start_at < '2026-11-16'
  );

-- Q3: One staff member's shifts for the coming week, earliest first
-- RA: τ[start_at](π[shift_id, start_at, end_at, notes](σ[staff_id = 2 ∧ start_at ≥ '2026-11-09' ∧ start_at < '2026-11-16'](Shift)))
SELECT shift_id, start_at, end_at, notes
FROM Shift
WHERE staff_id = 2
  AND start_at >= '2026-11-09' AND start_at < '2026-11-16'
ORDER BY start_at;

-- Q4: Pending swap requests with the shift, who offered it, and who covers it
-- RA: π[swap_id, start_at, end_at, owner.name, cover.name](σ[status = 'PENDING'](SwapRequest ⋈ Shift) ⋈[Shift.staff_id = owner.staff_id] ρ[owner](Staff) ⟕[cover_staff_id = cover.staff_id] ρ[cover](Staff))
SELECT sw.swap_id, sh.start_at, sh.end_at,
       owner.name AS offered_by, cover.name AS covered_by
FROM SwapRequest AS sw
JOIN Shift AS sh ON (sw.shift_id = sh.shift_id)
JOIN Staff AS owner ON (sh.staff_id = owner.staff_id)
LEFT JOIN Staff AS cover ON (sw.cover_staff_id = cover.staff_id)
WHERE sw.status = 'PENDING'
ORDER BY sw.created_at;

-- Q5: Pending time-off requests, oldest first
-- RA: τ[created_at](π[request_id, name, start_date, end_date, hours, created_at](σ[status = 'PENDING'](TimeOffRequest) ⋈ Staff))
SELECT t.request_id, s.name, t.start_date, t.end_date, t.hours, t.created_at
FROM TimeOffRequest AS t
JOIN Staff AS s ON (t.staff_id = s.staff_id)
WHERE t.status = 'PENDING'
ORDER BY t.created_at;

-- Q6: Pay of each hourly staff member for a pay period
-- RA: π[staff_id, name, hours_worked, rate_snapshot, bonus, deductions, hours_worked × rate_snapshot + bonus − deductions → pay](σ[restaurant_id = 1 ∧ period_start = '2026-10-01'](PayRecord ⋈ HourlyStaff ⋈ Staff))
SELECT s.staff_id, s.name, p.hours_worked, p.rate_snapshot, p.bonus, p.deductions,
       p.hours_worked * p.rate_snapshot + p.bonus - p.deductions AS pay
FROM PayRecord AS p
JOIN HourlyStaff AS h ON (p.staff_id = h.staff_id)
JOIN Staff AS s ON (p.staff_id = s.staff_id)
WHERE s.restaurant_id = 1 AND p.period_start = '2026-10-01'
ORDER BY s.name;

-- Q7: Time slots on a date with fewer staff scheduled than needed
-- RA: C ← Shift ⋈ Staff ⋈ Role; σ[scheduled < required_count](γ[requirement_id, department, start_time, end_time, required_count, COUNT(shift_id) → scheduled](σ[restaurant_id = 1 ∧ work_date = '2026-11-09'](StaffingRequirement) ⟕[restaurant_id = C.restaurant_id ∧ department = C.department ∧ C.start_at ≤ work_date + start_time ∧ C.end_at ≥ work_date + end_time] C))
SELECT r.requirement_id, r.department, r.start_time, r.end_time, r.required_count,
       COUNT(sh.shift_id) AS scheduled
FROM StaffingRequirement AS r
LEFT JOIN (Shift AS sh
           JOIN Staff AS s ON (sh.staff_id = s.staff_id)
           JOIN Role AS ro ON (s.restaurant_id = ro.restaurant_id AND s.role_name = ro.role_name))
       ON (s.restaurant_id = r.restaurant_id
           AND ro.department = r.department
           AND sh.start_at <= TIMESTAMP(r.work_date, r.start_time)
           AND sh.end_at   >= TIMESTAMP(r.work_date, r.end_time))
WHERE r.restaurant_id = 1 AND r.work_date = '2026-11-09'
GROUP BY r.requirement_id, r.department, r.start_time, r.end_time, r.required_count
HAVING COUNT(sh.shift_id) < r.required_count;

-- Q8: Hours each staff member actually worked last week
-- RA: γ[staff_id, name, SUM(cout.occurred_at − cin.occurred_at) → hours_worked](ρ[cin](σ[event_type = 'CLOCK_IN' ∧ occurred_at ≥ '2026-11-02' ∧ occurred_at < '2026-11-09'](TimeClockEvent)) ⋈[cin.shift_id = cout.shift_id] ρ[cout](σ[event_type = 'CLOCK_OUT'](TimeClockEvent)) ⋈[cin.staff_id = Staff.staff_id] Staff)
SELECT s.staff_id, s.name,
       ROUND(SUM(TIMESTAMPDIFF(MINUTE, cin.occurred_at, cout.occurred_at)) / 60, 2) AS hours_worked
FROM TimeClockEvent AS cin
JOIN TimeClockEvent AS cout ON (cin.shift_id = cout.shift_id)
JOIN Staff AS s ON (cin.staff_id = s.staff_id)
WHERE cin.event_type = 'CLOCK_IN' AND cout.event_type = 'CLOCK_OUT'
  AND cin.occurred_at >= '2026-11-02' AND cin.occurred_at < '2026-11-09'
GROUP BY s.staff_id, s.name
ORDER BY s.name;

-- Q9: Staff who clocked in more than 10 minutes after their shift started
-- RA: π[name, start_at, occurred_at, occurred_at − start_at → minutes_late](σ[event_type = 'CLOCK_IN' ∧ occurred_at > start_at + 10 min](TimeClockEvent ⋈ Shift ⋈ Staff))
SELECT s.name, sh.start_at, e.occurred_at AS clocked_in,
       TIMESTAMPDIFF(MINUTE, sh.start_at, e.occurred_at) AS minutes_late
FROM TimeClockEvent AS e
JOIN Shift AS sh ON (e.shift_id = sh.shift_id)
JOIN Staff AS s ON (e.staff_id = s.staff_id)
WHERE e.event_type = 'CLOCK_IN'
  AND e.occurred_at > sh.start_at + INTERVAL 10 MINUTE;

-- Q10: Clock-ins that are not linked to any scheduled shift
-- RA: π[event_id, name, occurred_at, note](σ[event_type = 'CLOCK_IN' ∧ shift_id IS NULL](TimeClockEvent) ⋈ Staff)
SELECT e.event_id, s.name, e.occurred_at, e.note
FROM TimeClockEvent AS e
JOIN Staff AS s ON (e.staff_id = s.staff_id)
WHERE e.event_type = 'CLOCK_IN' AND e.shift_id IS NULL;

-- Q11: Staff who must reset their password or have never logged in
-- RA: π[name, username, force_reset, last_login_at](σ[force_reset = TRUE ∨ last_login_at IS NULL](StaffCredential ⋈ Staff))
SELECT s.name, c.username, c.force_reset, c.last_login_at
FROM StaffCredential AS c
JOIN Staff AS s ON (c.staff_id = s.staff_id)
WHERE c.force_reset = TRUE OR c.last_login_at IS NULL;

-- Q12: Active staff without a login account
-- RA: π[staff_id, name, restaurant_id]((π[staff_id](σ[is_active = TRUE](Staff)) ∖ π[staff_id](StaffCredential)) ⋈ Staff)
SELECT s.staff_id, s.name, s.restaurant_id
FROM Staff AS s
WHERE s.is_active = TRUE
  AND s.staff_id NOT IN (SELECT staff_id FROM StaffCredential);

-- Q13: A restaurant's labour cost for a month, split into hourly and salaried staff
-- RA: M ← σ[restaurant_id = 1 ∧ period_start = '2026-10-01']; π['HOURLY' → pay_type, labour_cost](γ[SUM(hours_worked × rate_snapshot + bonus − deductions) → labour_cost](M(PayRecord ⋈ HourlyStaff ⋈ Staff))) ∪ π['SALARIED' → pay_type, labour_cost](γ[SUM(rate_snapshot + bonus − deductions) → labour_cost](M(PayRecord ⋈ SalariedStaff ⋈ Staff)))
SELECT 'HOURLY' AS pay_type,
       SUM(p.hours_worked * p.rate_snapshot + p.bonus - p.deductions) AS labour_cost
FROM PayRecord AS p
JOIN HourlyStaff AS h ON (p.staff_id = h.staff_id)
JOIN Staff AS s ON (p.staff_id = s.staff_id)
WHERE s.restaurant_id = 1 AND p.period_start = '2026-10-01'
UNION
SELECT 'SALARIED' AS pay_type,
       SUM(p.rate_snapshot + p.bonus - p.deductions) AS labour_cost
FROM PayRecord AS p
JOIN SalariedStaff AS m ON (p.staff_id = m.staff_id)
JOIN Staff AS s ON (p.staff_id = s.staff_id)
WHERE s.restaurant_id = 1 AND p.period_start = '2026-10-01';

-- Q14: Roles of a restaurant that no staff member holds
-- RA: π[role_name, department]((π[restaurant_id, role_name](σ[restaurant_id = 1](Role)) ∖ π[restaurant_id, role_name](Staff)) ⋈ Role)
SELECT r.role_name, r.department
FROM Role AS r
WHERE r.restaurant_id = 1
  AND (r.restaurant_id, r.role_name) NOT IN (
      SELECT restaurant_id, role_name
      FROM Staff
  );

-- Q15: Pairs of staff whose shifts overlap on the same day
-- RA: τ[s1.start_at](π[a.name, b.name, s1.start_at, s1.end_at, s2.start_at, s2.end_at](σ[a.restaurant_id = 1 ∧ b.restaurant_id = 1 ∧ s1.staff_id ≠ s2.staff_id](ρ[s1](Shift) ⋈[s1.shift_id < s2.shift_id ∧ DATE(s1.start_at) = DATE(s2.start_at) ∧ s1.start_at < s2.end_at ∧ s2.start_at < s1.end_at] ρ[s2](Shift) ⋈[s1.staff_id = a.staff_id] ρ[a](Staff) ⋈[s2.staff_id = b.staff_id] ρ[b](Staff))))
SELECT a.name AS staff_1, b.name AS staff_2,
       s1.start_at AS shift_1_start, s1.end_at AS shift_1_end,
       s2.start_at AS shift_2_start, s2.end_at AS shift_2_end
FROM Shift AS s1
JOIN Shift AS s2 ON (s1.shift_id < s2.shift_id
                     AND DATE(s1.start_at) = DATE(s2.start_at)
                     AND s1.start_at < s2.end_at
                     AND s2.start_at < s1.end_at)
JOIN Staff AS a ON (s1.staff_id = a.staff_id)
JOIN Staff AS b ON (s2.staff_id = b.staff_id)
WHERE a.restaurant_id = 1 AND b.restaurant_id = 1
  AND s1.staff_id <> s2.staff_id
ORDER BY s1.start_at;

-- Q16: Swap requests still waiting for a coworker to cover them
-- RA: π[swap_id, name, start_at, end_at](σ[status = 'PENDING' ∧ cover_staff_id IS NULL](SwapRequest) ⋈ Shift ⋈ Staff)
SELECT sw.swap_id, s.name AS offered_by, sh.start_at, sh.end_at
FROM SwapRequest AS sw
JOIN Shift AS sh ON (sw.shift_id = sh.shift_id)
JOIN Staff AS s ON (sh.staff_id = s.staff_id)
WHERE sw.status = 'PENDING' AND sw.cover_staff_id IS NULL;

-- Q17: The staff member who worked the most hours last month
-- RA: T ← γ[staff_id, name, SUM(hours_worked) → total_hours](σ[restaurant_id = 1 ∧ period_start = '2026-10-01'](PayRecord ⋈ Staff)); T ⋈ γ[MAX(total_hours) → total_hours](T)
SELECT s.staff_id, s.name, SUM(p.hours_worked) AS total_hours
FROM PayRecord AS p
JOIN Staff AS s ON (p.staff_id = s.staff_id)
WHERE s.restaurant_id = 1 AND p.period_start = '2026-10-01'
GROUP BY s.staff_id, s.name
HAVING SUM(p.hours_worked) >= ALL (
    SELECT SUM(p2.hours_worked)
    FROM PayRecord AS p2
    JOIN Staff AS s2 ON (p2.staff_id = s2.staff_id)
    WHERE s2.restaurant_id = 1 AND p2.period_start = '2026-10-01'
    GROUP BY p2.staff_id
);