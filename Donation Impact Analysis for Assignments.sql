/* List the top five assignments based on total value of donations, categorized by donor type. */
WITH donation_totals AS (
    SELECT
        a.assignment_name,
        a.region,
        dn.donor_type,
        SUM(d.amount) AS total_donation_amount
    FROM assignments AS a
    INNER JOIN donations AS d ON a.assignment_id = d.assignment_id
    INNER JOIN donors AS dn ON d.donor_id = dn.donor_id
    GROUP BY a.assignment_name, a.region, dn.donor_type
),

rnk AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY donor_type
               ORDER BY total_donation_amount DESC) AS rnk
    FROM donation_totals)
	
SELECT
    assignment_name,
    region,
    ROUND(total_donation_amount, 2) AS rounded_total_donation_amount,
    donor_type
FROM ranked AS highest_donation_assignments
WHERE rnk <= 5;


/* Identify the assignment with the highest impact score in each region, 
ensuring that each listed assignment has received at least one donation. */

-- top_regional_impact_assignments
WITH tot_donations_assignment AS (
    SELECT 
        a.assignment_id,
        a.assignment_name, 
        a.region, 
        a.impact_score,
        COUNT(d.donation_id) AS num_total_donations
    FROM assignments a
    JOIN donations d ON a.assignment_id = d.assignment_id
    GROUP BY a.assignment_id, a.assignment_name, a.region, a.impact_score
),

ranked_assignments AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY impact_score DESC) AS rnk
    FROM tot_donations_assignment
)

SELECT 
    assignment_name, 
    region, 
    impact_score, 
    num_total_donations
FROM ranked_assignments
WHERE rnk = 1
ORDER BY region ASC;