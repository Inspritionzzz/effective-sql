
/* 表之间的数据匹配 */
CREATE TABLE advancesql.CourseMaster
(course_id   INTEGER PRIMARY KEY,
 course_name VARCHAR(32) NOT NULL);

INSERT INTO advancesql.CourseMaster VALUES(1, '会计入门');
INSERT INTO advancesql.CourseMaster VALUES(2, '财务知识');
INSERT INTO advancesql.CourseMaster VALUES(3, '簿记考试');
INSERT INTO advancesql.CourseMaster VALUES(4, '税务师');

CREATE TABLE advancesql.OpenCourses
(month       INTEGER ,
 course_id   INTEGER ,
    PRIMARY KEY(month, course_id));

INSERT INTO advancesql.OpenCourses VALUES(200706, 1);
INSERT INTO advancesql.OpenCourses VALUES(200706, 3);
INSERT INTO advancesql.OpenCourses VALUES(200706, 4);
INSERT INTO advancesql.OpenCourses VALUES(200707, 4);
INSERT INTO advancesql.OpenCourses VALUES(200708, 2);
INSERT INTO advancesql.OpenCourses VALUES(200708, 4);