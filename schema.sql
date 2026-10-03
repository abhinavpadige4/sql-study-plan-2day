-- ============================================================================
-- schema.sql
-- Sample schema used by every solution in this repo.
-- Standard SQL (ANSI SQL-92 / SQL:2003). Tested on PostgreSQL 14+.
--
-- Tables:
--   departments  - one row per department
--   employees    - one row per employee (self-referencing manager_id)
--   projects     - one row per project
--   assignments  - many-to-many between employees and projects
--   salaries     - historical salary records per employee
-- ============================================================================

-- Clean slate (idempotent) ---------------------------------------------------
DROP TABLE IF EXISTS assignments;
DROP TABLE IF EXISTS salaries;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- Departments ----------------------------------------------------------------
CREATE TABLE departments (
    department_id   INTEGER PRIMARY KEY,
    department_name VARCHAR(64) NOT NULL UNIQUE
);

INSERT INTO departments (department_id, department_name) VALUES
    (1, 'Engineering'),
    (2, 'Sales'),
    (3, 'Marketing'),
    (4, 'Finance'),
    (5, 'HR');

-- Employees (self-referencing manager_id) -----------------------------------
CREATE TABLE employees (
    employee_id   INTEGER PRIMARY KEY,
    first_name    VARCHAR(64) NOT NULL,
    last_name     VARCHAR(64) NOT NULL,
    email         VARCHAR(128) UNIQUE,
    department_id INTEGER REFERENCES departments(department_id),
    manager_id    INTEGER REFERENCES employees(employee_id),
    hire_date     DATE NOT NULL,
    salary        NUMERIC(12, 2) NOT NULL
);

INSERT INTO employees
    (employee_id, first_name, last_name, email, department_id, manager_id, hire_date, salary)
VALUES
    -- Engineering (dept 1)
    (101, 'Alice',   'Nguyen',  'alice@co.com',   1, NULL, '2018-03-15', 140000),
    (102, 'Bob',     'Smith',   'bob@co.com',     1, 101,  '2019-07-01', 110000),
    (103, 'Carol',   'Diaz',    'carol@co.com',   1, 101,  '2020-01-20', 120000),
    (104, 'David',   'Kim',     'david@co.com',   1, 102,  '2021-05-10',  95000),
    (105, 'Eve',     'Brown',   'eve@co.com',     1, 102,  '2022-09-01',  98000),
    -- Sales (dept 2)
    (201, 'Frank',   'Lee',     'frank@co.com',   2, NULL, '2017-11-01', 130000),
    (202, 'Grace',   'Patel',   'grace@co.com',   2, 201,  '2019-04-15', 105000),
    (203, 'Henry',   'Wang',    'henry@co.com',   2, 201,  '2020-08-22', 108000),
    -- Marketing (dept 3)
    (301, 'Ivy',     'Garcia',  'ivy@co.com',     3, NULL, '2018-06-10', 125000),
    (302, 'Jack',    'Miller',  'jack@co.com',    3, 301,  '2021-02-14',  92000),
    -- Finance (dept 4)
    (401, 'Karen',   'Chen',    'karen@co.com',   4, NULL, '2016-09-05', 135000),
    (402, 'Leo',     'Rossi',   'leo@co.com',     4, 401,  '2020-11-30', 100000),
    -- HR (dept 5) - intentionally empty of employees for anti-join demos
    -- (no rows inserted for dept 5)

-- Projects -------------------------------------------------------------------
CREATE TABLE projects (
    project_id   INTEGER PRIMARY KEY,
    project_name VARCHAR(128) NOT NULL,
    start_date   DATE NOT NULL,
    end_date     DATE
);

INSERT INTO projects (project_id, project_name, start_date, end_date) VALUES
    (1, 'Apollo',     '2023-01-10', '2023-12-31'),
    (2, 'Borealis',   '2023-06-01', NULL),
    (3, 'Cascade',    '2024-02-15', NULL),
    (4, 'Delta',      '2022-04-01', '2022-10-31');

-- Assignments (many-to-many) -------------------------------------------------
CREATE TABLE assignments (
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id),
    project_id  INTEGER NOT NULL REFERENCES projects(project_id),
    role        VARCHAR(64) NOT NULL DEFAULT 'member',
    PRIMARY KEY (employee_id, project_id)
);

INSERT INTO assignments (employee_id, project_id, role) VALUES
    (101, 1, 'lead'),
    (102, 1, 'member'),
    (103, 2, 'lead'),
    (104, 2, 'member'),
    (201, 3, 'lead'),
    (202, 3, 'member'),
    (301, 4, 'lead'),
    (401, 1, 'member');

-- Salaries (historical) ------------------------------------------------------
CREATE TABLE salaries (
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id),
    effective_date DATE NOT NULL,
    salary        NUMERIC(12, 2) NOT NULL,
    PRIMARY KEY (employee_id, effective_date)
);

INSERT INTO salaries (employee_id, effective_date, salary) VALUES
    (101, '2018-03-15', 120000),
    (101, '2020-03-15', 130000),
    (101, '2022-03-15', 140000),
    (102, '2019-07-01',  95000),
    (102, '2021-07-01', 105000),
    (102, '2023-07-01', 110000),
    (201, '2017-11-01', 115000),
    (201, '2020-11-01', 125000),
    (201, '2023-11-01', 130000);
