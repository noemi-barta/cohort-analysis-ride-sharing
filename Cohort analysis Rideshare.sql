
-- Initial Setup: Defining the 'drivers_rides' CTE to collect essential ride and driver data.
WITH drivers_rides AS (
  SELECT
    m.member_id,
    m.first_name AS member_fname,
    m.last_name AS member_lname,
    m.inscription_date AS member_insc_date,
    r.ride_id,
    r.departure_date AS ride_date,
    -- Calculating income based on contribution per passenger and number of seats
    (r.contribution_per_passenger * r.number_seats) AS income,
    -- Calculating the number of days since the driver's inscription to the ride's departure
    DATEDIFF(r.departure_date, m.inscription_date) AS days_since_inscription
  FROM
    members m
    -- Joining on member_car to link members to their cars and consequently to the rides
    INNER JOIN member_car mc ON m.member_id = mc.member_id
    -- Joining on rides to get the ride information
    INNER JOIN rides r ON r.member_car_id = mc.member_car_id
  -- Ordering by member and ride date to maintain a chronological order for subsequent analysis
  ORDER BY
    m.member_id,
    r.departure_date ASC
),
-- Defining the 'quarterly_cohorts' CTE to segment users by their inscription quarter.
quarterly_cohorts AS (
  SELECT
    m.member_id,
    -- Combining quarter and year to create a cohort label
    CONCAT('Q', QUARTER(m.inscription_date), '-', YEAR(m.inscription_date)) AS cohort_quarter,
    MONTHNAME(m.inscription_date) AS cohort_month,
    MONTH(m.inscription_date) AS month_
  FROM
    members m
  -- No particular ordering needed here since we are only categorizing by cohort
),
-- Defining the 'segment_rides' CTE to categorize rides by the quarter in which they occur.
segment_rides AS (
  SELECT
    r.ride_id,
    CONCAT('Q', QUARTER(r.departure_date), '-', YEAR(r.departure_date)) AS segment_quarter,
    MONTHNAME(r.departure_date) AS segment_month,
    MONTH(r.departure_date) AS segment_month_nb
  FROM
    rides r
  -- Ordering by departure date to organize rides chronologically
  ORDER BY
    r.departure_date
),
-- Filtering 'quarterly_cohorts' to include only drivers (ride owners).
drivers_quarterly_cohorts AS (
  SELECT
    m.member_id,
    CONCAT('Q', QUARTER(m.inscription_date), '-', YEAR(m.inscription_date)) AS cohort_quarter,
    MONTHNAME(m.inscription_date) AS cohort_month,
    MONTH(m.inscription_date) AS month_
  FROM
    members m
  WHERE
    m.is_ride_owner = 1
  -- No ordering here since it's a filtered subset of 'quarterly_cohorts'.
),
-- Calculating active members per cohort.
nb_members_with_ride AS (
  SELECT
    qc.cohort_quarter,
    sr.segment_quarter,
    -- Counting distinct member IDs to ensure we only count each member once per cohort
    COUNT(DISTINCT qc.member_id) AS members_with_ride
  FROM
    segment_rides sr
    INNER JOIN drivers_rides dr ON sr.ride_id = dr.ride_id
    INNER JOIN quarterly_cohorts qc ON qc.member_id = dr.member_id
  GROUP BY
    qc.cohort_quarter,
    sr.segment_quarter
),
-- Counting the number of drivers per cohort.
nb_drivers_per_cohort AS (
  SELECT
    cohort_quarter,
    -- Counting distinct member IDs to get the number of drivers per cohort
    COUNT(DISTINCT(member_id)) AS nb_drivers
  FROM
    drivers_quarterly_cohorts
  GROUP BY
    cohort_quarter
)
-- Final selection combining all the CTEs above to calculate the percentage of active drivers per cohort.
SELECT
  nmr.cohort_quarter,
  sr.segment_quarter,
  ndpc.nb_drivers,
  nmr.members_with_ride,
  -- Calculating the percentage of active drivers and converting it to a readable string with a percentage sign
  CONCAT(ROUND((nmr.members_with_ride / NULLIF(ndpc.nb_drivers, 0) * 100), 2), '%') AS percentage_drivers_active
FROM
  nb_members_with_ride nmr
  INNER JOIN nb_drivers_per_cohort ndpc ON nmr.cohort_quarter = ndpc.cohort_quarter
-- Final ordering to ensure results are sorted by cohort and segment for easy analysis
ORDER BY
  nmr.cohort_quarter,
  sr.segment_quarter;
