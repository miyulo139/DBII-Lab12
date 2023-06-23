--PREGUNTA 1
CREATE TABLE employees (
  emp_no int,
  birth_date date,
  first_name varchar(14),
  last_name varchar(16),
  gender character(1),
  hire_date date,
  dept_no varchar(5),
  from_date date
);

CREATE TABLE employees1 (
  emp_no int,
  birth_date date,
  first_name varchar(14),
  last_name varchar(16),
  gender character(1),
  hire_date date,
  dept_no varchar(5),
  from_date date
) PARTITION BY LIST (dept_no);

CREATE TABLE employees1_d005 PARTITION OF employees1 FOR VALUES IN ('d005');
CREATE TABLE employees1_d004 PARTITION OF employees1 FOR VALUES IN ('d004');
CREATE TABLE employees1_resto PARTITION OF employees1 default;

explain analyze select * from employees1 where dept_no = 'd007';
explain analyze select * from employees1 where dept_no = 'd004';
explain analyze select * from employees1 where dept_no = 'd005';

explain analyze select * from employees where dept_no = 'd007';
explain analyze select * from employees where dept_no = 'd004';
explain analyze select * from employees where dept_no = 'd005';



--PREGUNTA 2
CREATE TABLE employees2 (
  emp_no int,
  birth_date date,
  first_name varchar(14),
  last_name varchar(16),
  gender character(1),
  hire_date date,
  dept_no varchar(5),
  from_date date
) PARTITION BY RANGE (date_part('year', hire_date));

CREATE TABLE employees2_1 PARTITION OF employees2  FOR VALUES FROM (MINVALUE) TO (1995);
CREATE TABLE employees2_2 PARTITION OF employees2  FOR VALUES FROM (1995) TO (1998);
CREATE TABLE employees2_3 PARTITION OF employees2  FOR VALUES FROM (1998) TO (MAXVALUE);

CREATE INDEX idx_emp2_hire_date1 ON employees2 (hire_date);
CREATE INDEX idx_emp2_hire_date2 ON employees (hire_date);

-- Queries
EXPLAIN ANALYSE SELECT * FROM employees WHERE date_part('year', hire_date) = 1993;
EXPLAIN ANALYSE SELECT * FROM employees WHERE date_part('year', hire_date) = 1996;
EXPLAIN ANALYSE SELECT * FROM employees WHERE date_part('year', hire_date) = 1999;

EXPLAIN ANALYSE SELECT * FROM employees2 WHERE date_part('year', hire_date) = 1993;
EXPLAIN ANALYSE SELECT * FROM employees2 WHERE date_part('year', hire_date) = 1996;
EXPLAIN ANALYSE SELECT * FROM employees2 WHERE date_part('year', hire_date) = 1999;



--PREGUNTA 3
--Se trabajó con data1 (ya que incluye el atributo salary en employees.csv)

CREATE TABLE employees3_v(
    employee_id integer,
    first_name varchar(20),
    last_name varchar(25) NOT NULL,
    email varchar(25) NOT NULL,
    phone_number varchar(20),
    hire_date timestamp NOT NULL,
    job_id varchar(10) NOT NULL,
    salary numeric(8,2),
    commission_pct numeric(2,2),
    manager_id integer,
    department_id integer,
    CONSTRAINT emp_salary_min CHECK (salary > 0)
);

CREATE TABLE employees3(
    employee_id integer,
    first_name varchar(20),
    last_name varchar(25) NOT NULL,
    email varchar(25) NOT NULL,
    phone_number varchar(20),
    hire_date timestamp NOT NULL,
    job_id varchar(10) NOT NULL,
    salary numeric(8,2),
    commission_pct numeric(2,2),
    manager_id integer,
    department_id integer,
    CONSTRAINT emp_salary_min CHECK (salary > 0)
) PARTITION BY RANGE (date_part('year', hire_date));

CREATE TABLE employees3_1 PARTITION OF employees3  FOR VALUES FROM (MINVALUE) TO (1995) PARTITION BY
    RANGE (salary);
CREATE TABLE employees3_2 PARTITION OF employees3  FOR VALUES FROM (1995) TO (1998) PARTITION BY
    RANGE (salary);
CREATE TABLE employees3_3 PARTITION OF employees3  FOR VALUES FROM (1998) TO (MAXVALUE) PARTITION BY
    RANGE (salary);
	
SELECT min(salary) as min_salary, max(salary) as max_salary FROM employees3;

-- Fragments on partition of employees3_1
CREATE TABLE employees3_11 PARTITION OF employees3_1 FOR VALUES FROM (MINVALUE) TO (30000);
CREATE TABLE employees3_12 PARTITION OF employees3_1 FOR VALUES FROM (30000) TO (70000);
CREATE TABLE employees3_13 PARTITION OF employees3_1 FOR VALUES FROM (70000) TO (MAXVALUE);

-- Fragments on partition of employees3_2
CREATE TABLE employees3_21 PARTITION OF employees3_2 FOR VALUES FROM (MINVALUE) TO (30000);
CREATE TABLE employees3_22 PARTITION OF employees3_2 FOR VALUES FROM (30000) TO (70000);
CREATE TABLE employees3_23 PARTITION OF employees3_2 FOR VALUES FROM (70000) TO (MAXVALUE);

-- Fragments on partition of employees3_3
CREATE TABLE employees3_31 PARTITION OF employees3_3 FOR VALUES FROM (MINVALUE) TO (30000);
CREATE TABLE employees3_32 PARTITION OF employees3_3 FOR VALUES FROM (30000) TO (70000);
CREATE TABLE employees3_33 PARTITION OF employees3_3 FOR VALUES FROM (70000) TO (MAXVALUE);

--Queries
EXPLAIN ANALYZE SELECT * FROM employees3_v WHERE date_part('year', hire_date) = 1993 AND salary > 50000;
EXPLAIN ANALYZE SELECT * FROM employees3_v WHERE date_part('year', hire_date) BETWEEN 1995 AND 1997 AND salary BETWEEN 40000 AND 60000;
EXPLAIN ANALYZE SELECT AVG(salary) FROM employees3_v WHERE date_part('year', hire_date) < 1997;

EXPLAIN ANALYZE SELECT * FROM employees3 WHERE date_part('year', hire_date) = 1993 AND salary > 50000;
EXPLAIN ANALYZE SELECT * FROM employees3 WHERE date_part('year', hire_date) BETWEEN 1995 AND 1997 AND salary BETWEEN 40000 AND 60000;
EXPLAIN ANALYZE SELECT AVG(salary) FROM employees3 WHERE date_part('year', hire_date) < 1997;

