SELECT DISTINCT snum AS NUM, sname AS NAME \
FROM student s \
WHERE year >= 3 \
AND snum in ( SELECT r1.snum \
              FROM mark r1, mark r2 \
              WHERE r1.snum = s.snum \
              AND r2.snum = s.snum \
              AND r1.cnum = 'CS240' \
              AND r2.cnum = 'CS245' \
              AND r1.grade >= 85 \
              AND r2.grade >= 85 \
            )

SELECT pnum AS NUM, pname AS NAME \
FROM professor p \
WHERE dept != 'PM' \
AND NOT EXISTS  ( SELECT pnum \
                  FROM class c \
                  WHERE c.pnum = p.pnum \
                  AND cnum = 'CS245' \
                  AND term != 'F2017' \
               ) \
AND EXISTS ( SELECT * \
             FROM class d \
             WHERE d.pnum = p.pnum \
             AND cnum = 'CS245' \
             AND term = 'F2017' )

SELECT snum AS NUM, sname AS NAME, year AS YEAR \
FROM student s \
WHERE snum in ( SELECT snum \
                FROM mark \
                WHERE cnum = 'CS240' \
                ORDER BY grade DESC \
                LIMIT 3 )

SELECT snum AS Num, sname AS Name \
FROM student s \
WHERE year > 2 \
AND NOT EXISTS ( SELECT * \
                 FROM mark m \
                 WHERE s.snum = m.snum \
                 AND left(cnum, 2) = 'CS' \
                 AND grade < 85 ) \
AND NOT EXISTS ( SELECT * \
                 FROM enrollment e \
                 WHERE e.snum = s.snum \
                 AND EXISTS ( SELECT * \
                              FROM class c \
                              WHERE c.cnum = e.cnum \
                              AND c.term = e.cnum \
                              AND c.section = e.section \
                              AND EXISTS ( SELECT * \
                                           FROM professor p \
                                           WHERE p.pnum = c.pnum \
                                           AND p.dept != 'CS' ) \
                            ) \
               )

SELECT DISTINCT dept AS Department \
FROM professor p \
WHERE EXISTS ( SELECT * \
               FROM class c \
               WHERE c.pnum = p.pnum \
               AND term = 'F2017' \
               AND EXISTS ( SELECT * \
                            FROM schedule sc \
                            WHERE sc.cnum = c.cnum \
                            AND sc.term = c.term \
                            AND sc.section = c.section \
                            AND sc.day = 'Monday' \
                            AND left(sc.time, 2) < '12' ) ) \
AND EXISTS ( SELECT * \
               FROM class d \
               WHERE d.pnum = p.pnum \
               AND term = 'F2017' \
               AND EXISTS ( SELECT * \
                            FROM schedule sc \
                            WHERE sc.cnum = d.cnum \
                            AND sc.term = d.term \
                            AND sc.section = d.section \
                            AND sc.day = 'Friday' \
                            AND left(sc.time, 2) > '12' ) )

SELECT count(p1.pnum)/count(p2.pnum) AS Ratio \
FROM ( SELECT * \
       FROM professor \
       WHERE dept = 'PM' ) p1, \
     ( SELECT * \
       FROM professor \
       WHERE dept = 'AM' ) p2 \
WHERE EXISTS ( SELECT * \
               FROM class c \
               WHERE c.pnum = p1.pnum \
               AND EXISTS ( SELECT AVG(grade) \
                            FROM mark m \
                            WHERE c.cnum = m.cnum \
                            AND c.term = m.term \
                            AND c.section = m.section \
                            HAVING AVG(grade) > 77 ) ) \
AND EXISTS ( SELECT * \
               FROM class c \
               WHERE c.pnum = p2.pnum \
               AND EXISTS ( SELECT AVG(grade) \
                            FROM mark m \
                            WHERE c.cnum = m.cnum \
                            AND c.term = m.term \
                            AND c.section = m.section \
                            HAVING AVG(grade) > 77 ) )

SELECT DISTINCT c1.cnum AS CourseNum, c1.term AS Term, \
		c1.pnum AS Prof1Num, c2.pnum AS Prof2Num, \
		count(e1.snum) AS Prof1Enroll, count(e2.snum) AS Prof2Enroll, \
		avg(m1.grade) AS Prof1Avg, avg(m2.grade) AS Prof2Avg \
FROM class c1, class c2, \
	enrollment e1, enrollment e2, \
	mark m1, mark m2 \
WHERE c1.cnum = c2.cnum \
AND c1.term = c2.term \
AND c1.pnum != c2.pnum \
AND c1.cnum = e1.cnum  \
AND c1.term = e1.term \
AND c1.section = e1.section \
AND c2.cnum = e2.cnum \
AND c2.term = e2.term \
AND c2.section = e2.section \
AND c1.cnum = m1.cnum \
AND c1.term = m1.term \
AND c1.section = m1.section \
AND c2.cnum = m2.cnum \
AND c2.term = m2.term \
AND c2.section = m2.section \
GROUP BY c1.cnum, c1.term, c1.pnum, c2.pnum

SELECT term as Term, count( \
	(SELECT ee.snum \
	FROM enrollment ee \
	WHERE ee.cnum NOT IN (SELECT c.cnum \
				 		FROM class c, professor p \
				 		WHERE c.pnum = p.pnum \
				 		AND ( p.dept = 'CO' \
				 	   		OR p.dept = 'CS' ) ) \
	AND ee.term = e.term ) )*100/count(*) \
FROM enrollment e \
GROUP BY e.term \
ORDER BY right(e.term, 4), left(e.term, 1) DESC

SELECT DISTINCT p.pnum AS ProfNum, p.pname AS ProfName, \
		c.cnum AS ClassNum, c.term AS Term, c.section AS Section, \
		min(m.grade) AS MinGrade, max(m.grade) AS MaxGrade \
FROM mark m, professor p, class c, schedule s \
WHERE c.cnum = s.cnum \
AND c.term = s.term \
AND c.section = s.section \
AND s.day = 'Monday' \
AND s.day = 'Friday' \
AND c.pnum = p.pnum \
AND p.dept = 'CS' \
AND c.cnum = m.cnum \
AND c.term = m.term \
AND c.section = m.section \
GROUP BY p.pnum, p.pname, c.cnum, c.term, c.section 

SELECT count(exe.pnum)/count(ampm.pnum)*100 AS Percentage \
FROM (SELECT * \
	  FROM professor \
	  WHERE dept = 'AM' \
	  OR dept = 'PM') ampm, \
	 (SELECT * \
	  FROM professor \
	  WHERE dept = 'AM' \
	  OR dept = 'PM') exe \
WHERE exe.pnum NOT IN (SELECT c1.pnum \
					   FROM class c1, class c2 \
					   WHERE c1.pnum = c2.pnum \
					   AND c1.term = c2.term \
					   AND c1.cnum != c2.cnum)
          
