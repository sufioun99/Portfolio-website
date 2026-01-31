----------------------------------------------------------------------------------
-- DATABASE SETUP SCRIPT (33 TABLES)
-- IMPORTANT: Run this script as the MSP user (already created and connected)
-- If the user doesn't exist, connect as sys/sysdba first and execute:
--   CREATE USER msp IDENTIFIED BY msp DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
--   GRANT CONNECT, RESOURCE TO msp;
--------------------------------------------------------------------------------

DROP USER msp CASCADE;



CREATE USER msp IDENTIFIED BY msp
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT CONNECT, RESOURCE TO msp;


CONNECT msp/msp; 

--------------------------------------------------------------------------------
-- 01. COMPANY
--------------------------------------------------------------------------------
CREATE TABLE company (
    company_id          VARCHAR2(50) PRIMARY KEY,
    company_name        VARCHAR2(200) NOT NULL UNIQUE,
    company_proprietor  VARCHAR2(200),
    phone_no            VARCHAR2(50) NOT NULL UNIQUE,
    email               VARCHAR2(200) NOT NULL UNIQUE,
    address             VARCHAR2(300),
    website             VARCHAR2(200) UNIQUE,
    contact_person      VARCHAR2(200),
    cp_designation      VARCHAR2(200),
    cp_phone_no         VARCHAR2(50),
    tag_line            VARCHAR2(300),
    mission_vision      VARCHAR2(1000),
    status              NUMBER,
    cre_by              VARCHAR2(100),
    cre_dt              DATE,
    upd_by              VARCHAR2(100),
    upd_dt              DATE
);

CREATE SEQUENCE company_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_company_bi
BEFORE INSERT OR UPDATE ON company FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate company_id only if null during INSERT
    IF INSERTING AND :NEW.company_id IS NULL THEN
        v_seq := company_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.company_name),1,3));
        :NEW.company_id := NVL(v_code, 'COM') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        -- Always stamp updater to maintain audit integrity
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 02. JOBS
--------------------------------------------------------------------------------
CREATE TABLE jobs (
    job_id       VARCHAR2(50) PRIMARY KEY,
    job_code     VARCHAR2(50),
    job_title    VARCHAR2(150),
    job_grade    VARCHAR2(1),
    min_salary   NUMBER,
    max_salary   NUMBER,
    status       NUMBER,
    cre_by       VARCHAR2(100),
    cre_dt       DATE,
    upd_by       VARCHAR2(100),
    upd_dt       DATE,
    CONSTRAINT chk_job_grade CHECK (job_grade IN ('A','B','C') OR job_grade IS NULL)
);

CREATE SEQUENCE jobs_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_jobs_bi
BEFORE INSERT OR UPDATE ON jobs FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate job_id only if null during INSERT
    IF INSERTING AND :NEW.job_id IS NULL THEN
        v_seq := jobs_seq.NEXTVAL; 
        IF :NEW.job_code IS NOT NULL THEN
            v_code := UPPER(TRIM(:NEW.job_code));
            :NEW.job_id := v_code || TO_CHAR(v_seq);
        ELSE :NEW.job_id := TO_CHAR(v_seq); END IF;
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 03. CUSTOMERS
--------------------------------------------------------------------------------
CREATE TABLE customers (
    customer_id VARCHAR2(50) PRIMARY KEY,
    phone_no      VARCHAR2(50) UNIQUE, 
    customer_name VARCHAR2(150) NOT NULL,
    alt_phone_no  VARCHAR2(50),
    email         VARCHAR2(150),
    address       VARCHAR2(300),
    city          VARCHAR2(100),
    rewards       NUMBER DEFAULT 0,
    remarks       VARCHAR2(1000),
    status        NUMBER,
    cre_by        VARCHAR2(100),
    cre_dt        DATE,
    upd_by        VARCHAR2(100),
    upd_dt        DATE
);

CREATE SEQUENCE customers_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_customers_bi
BEFORE INSERT OR UPDATE ON customers
FOR EACH ROW
DECLARE
    v_seq  NUMBER;
    v_code VARCHAR2(10);
BEGIN
    IF INSERTING AND :NEW.customer_id IS NULL THEN
        IF :NEW.phone_no IS NOT NULL THEN
            :NEW.customer_id := :NEW.phone_no;
        ELSE
            v_seq  := customers_seq.NEXTVAL;
            v_code := UPPER(SUBSTR(TRIM(:NEW.customer_name),1,3));
            :NEW.customer_id := v_code || TO_CHAR(v_seq);
        END IF;
    END IF;

    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/


--------------------------------------------------------------------------------
-- 04. PARTS_CATEGORY
--------------------------------------------------------------------------------
CREATE TABLE parts_category (
    parts_cat_id    VARCHAR2(50) PRIMARY KEY,
    parts_cat_code  VARCHAR2(50),
    parts_cat_name  VARCHAR2(150) ,
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE
);

CREATE SEQUENCE parts_cat_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_parts_cat_bi
BEFORE INSERT OR UPDATE ON parts_category FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate parts_cat_id only if null during INSERT
    IF INSERTING AND :NEW.parts_cat_id IS NULL THEN
        v_seq := parts_cat_seq.NEXTVAL;
        IF :NEW.parts_cat_code IS NOT NULL THEN
            v_code := UPPER(TRIM(:NEW.parts_cat_code));
            :NEW.parts_cat_id := v_code || TO_CHAR(v_seq);
        ELSE :NEW.parts_cat_id := TO_CHAR(v_seq); END IF;
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 05. PRODUCT_CATEGORIES
--------------------------------------------------------------------------------
CREATE TABLE product_categories (
    product_cat_id    VARCHAR2(50) PRIMARY KEY,
    product_cat_name  VARCHAR2(150) ,
    status            NUMBER,
    cre_by            VARCHAR2(100),
    cre_dt            DATE,
    upd_by            VARCHAR2(100),
    upd_dt            DATE
);

CREATE SEQUENCE prod_cat_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_prod_cat_bi
BEFORE INSERT OR UPDATE ON product_categories FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate product_cat_id only if null during INSERT
    IF INSERTING AND :NEW.product_cat_id IS NULL THEN
        v_seq := prod_cat_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.product_cat_name),1,3));
        :NEW.product_cat_id := NVL(v_code, 'CAT') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 06. BRAND
--------------------------------------------------------------------------------
CREATE TABLE brand (
    brand_id      VARCHAR2(50) PRIMARY KEY,
    brand_name    VARCHAR2(150),
    model_name    VARCHAR2(150),
    brand_size    VARCHAR2(30),
    color         VARCHAR2(50),
    status        NUMBER,
    cre_by        VARCHAR2(100),
    cre_dt        DATE,
    upd_by        VARCHAR2(100),
    upd_dt        DATE
);

CREATE SEQUENCE brand_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_brand_bi
BEFORE INSERT OR UPDATE ON brand FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate brand_id only if null during INSERT
    IF INSERTING AND :NEW.brand_id IS NULL THEN
        v_seq := brand_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.brand_name),1,3));
        :NEW.brand_id := NVL(v_code, 'BRD') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 07. SUPPLIERS
--------------------------------------------------------------------------------
CREATE TABLE suppliers (
    supplier_id    VARCHAR2(50) PRIMARY KEY,
    supplier_name  VARCHAR2(150) NOT NULL,
    phone_no       VARCHAR2(30),
    email          VARCHAR2(150),
    address        VARCHAR2(300),
    contact_person VARCHAR2(100),
    cp_designation VARCHAR2(100),
    cp_phone_no    VARCHAR2(30),
    cp_email       VARCHAR2(150),
    purchase_total NUMBER DEFAULT 0,
    pay_total      NUMBER DEFAULT 0,
    due            NUMBER,
    status         NUMBER,
    cre_by         VARCHAR2(100),
    cre_dt         DATE,
    upd_by         VARCHAR2(100),
    upd_dt         DATE
);

CREATE SEQUENCE suppliers_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_suppliers_bi
BEFORE INSERT OR UPDATE ON suppliers FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate supplier_id only if null during INSERT
    IF INSERTING AND :NEW.supplier_id IS NULL THEN
        v_seq := suppliers_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.supplier_name),1,3));
        :NEW.supplier_id := NVL(v_code, 'SUP') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 08. SERVICE_LIST
--------------------------------------------------------------------------------
CREATE TABLE service_list (
    servicelist_id VARCHAR2(50) PRIMARY KEY,
    service_name   VARCHAR2(150) NOT NULL,
    service_desc   VARCHAR2(1000),
    service_cost   NUMBER DEFAULT 0,
    status         NUMBER,
    cre_by         VARCHAR2(100),
    cre_dt         DATE,
    upd_by         VARCHAR2(100),
    upd_dt         DATE
);

CREATE SEQUENCE service_list_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_service_list_bi
BEFORE INSERT OR UPDATE ON service_list FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate servicelist_id only if null during INSERT
    IF INSERTING AND :NEW.servicelist_id IS NULL THEN
        v_seq := service_list_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.service_name),1,3));
        :NEW.servicelist_id := NVL(v_code, 'SRV') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 09. EXPENSE_LIST
--------------------------------------------------------------------------------
CREATE TABLE expense_list (
    expense_type_id VARCHAR2(50) PRIMARY KEY,
    expense_code    VARCHAR2(50),
    type_name       VARCHAR2(200),
    description     VARCHAR2(1000),
    default_amount  NUMBER(15,2),
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE
);

CREATE SEQUENCE exp_list_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_exp_list_bi
BEFORE INSERT OR UPDATE ON expense_list FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate expense_type_id only if null during INSERT
    IF INSERTING AND :NEW.expense_type_id IS NULL THEN
        v_seq := exp_list_seq.NEXTVAL; 
        IF :NEW.expense_code IS NOT NULL THEN
            v_code := UPPER(TRIM(:NEW.expense_code));
            :NEW.expense_type_id := v_code || TO_CHAR(v_seq);
        ELSE :NEW.expense_type_id := TO_CHAR(v_seq); END IF;
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 10. SUB_CATEGORIES
--------------------------------------------------------------------------------
CREATE TABLE sub_categories (
    sub_cat_id       VARCHAR2(50) PRIMARY KEY,
    sub_cat_name     VARCHAR2(150),
    product_cat_id   VARCHAR2(50) NULL,
    status           NUMBER,
    cre_by           VARCHAR2(100),
    cre_dt           DATE,
    upd_by           VARCHAR2(100),
    upd_dt           DATE,
    CONSTRAINT fk_subcat_prodcat FOREIGN KEY (product_cat_id) REFERENCES product_categories(product_cat_id)
);

CREATE SEQUENCE sub_cat_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_sub_cat_bi
BEFORE INSERT OR UPDATE ON sub_categories FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    IF INSERTING AND :NEW.sub_cat_id IS NULL THEN
        v_seq := sub_cat_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.sub_cat_name),1,3));
        :NEW.sub_cat_id := NVL(v_code, 'SUB') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 11. PRODUCTS
--------------------------------------------------------------------------------
CREATE TABLE products (
    product_id      VARCHAR2(50) PRIMARY KEY,
    product_code    VARCHAR2(30) ,
    product_name    VARCHAR2(150) NOT NULL,
    supplier_id     VARCHAR2(50) NULL,
    category_id     VARCHAR2(50) NULL,
    sub_cat_id      VARCHAR2(50) NULL,
    brand_id        VARCHAR2(50) NULL,
    uom             VARCHAR2(20),
    mrp             NUMBER,
    purchase_price  NUMBER,
    warranty        NUMBER, 
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_p_sup FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_p_cat FOREIGN KEY (category_id) REFERENCES product_categories(product_cat_id),
    CONSTRAINT fk_p_sub FOREIGN KEY (sub_cat_id) REFERENCES sub_categories(sub_cat_id),
    CONSTRAINT fk_p_brd FOREIGN KEY (brand_id) REFERENCES brand(brand_id)
);

CREATE SEQUENCE products_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_products_bi
BEFORE INSERT OR UPDATE ON products
FOR EACH ROW
DECLARE
    v_seq  NUMBER;
    v_code VARCHAR2(100);
BEGIN
    IF INSERTING AND :NEW.product_id IS NULL THEN
        v_seq := products_seq.NEXTVAL;
        IF :NEW.product_code IS NOT NULL THEN
            v_code := UPPER(TRIM(:NEW.product_code));
            :NEW.product_id := v_code || TO_CHAR(v_seq);
        ELSE
            :NEW.product_id := TO_CHAR(v_seq);
        END IF;
    END IF;

    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/


--------------------------------------------------------------------------------
-- 12. PARTS
--------------------------------------------------------------------------------
CREATE TABLE parts (
    parts_id       VARCHAR2(50) PRIMARY KEY,
    parts_code     VARCHAR2(50),
    parts_name     VARCHAR2(150),
    purchase_price NUMBER,
    mrp            NUMBER,
    parts_cat_id   VARCHAR2(50) NULL,
    status         NUMBER,
    cre_by         VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_parts_cat FOREIGN KEY (parts_cat_id) REFERENCES parts_category(parts_cat_id)
);

CREATE SEQUENCE parts_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_parts_bi
BEFORE INSERT OR UPDATE ON parts FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    IF INSERTING AND :NEW.parts_id IS NULL THEN
        v_seq := parts_seq.NEXTVAL;
        IF :NEW.parts_code IS NOT NULL THEN
            v_code := UPPER(TRIM(:NEW.parts_code));
            :NEW.parts_id := v_code || TO_CHAR(v_seq);
        ELSE :NEW.parts_id := TO_CHAR(v_seq); END IF;
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 13. DEPARTMENTS
--------------------------------------------------------------------------------
CREATE TABLE departments (
    department_id   VARCHAR2(50) PRIMARY KEY,
    department_name VARCHAR2(100),
    manager_id      VARCHAR2(50), 
    company_id      VARCHAR2(50) NULL,
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_dept_company FOREIGN KEY (company_id) REFERENCES company(company_id)
);

CREATE SEQUENCE departments_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

--------------------------------------------------------------------------------
-- 14. EMPLOYEES
--------------------------------------------------------------------------------
CREATE TABLE employees (
    employee_id   VARCHAR2(50) PRIMARY KEY,
    first_name    VARCHAR2(50),
    last_name     VARCHAR2(50) NOT NULL,
    email         VARCHAR2(150),
    phone_no      VARCHAR2(30),
    address       VARCHAR2(4000),
    hire_date     DATE,
    salary        NUMBER,
    job_id        VARCHAR2(50) NULL,
    manager_id    VARCHAR2(50), 
    department_id VARCHAR2(50) NULL,
    photo         BLOB,
    status        NUMBER,
    cre_by        VARCHAR2(100),
    cre_dt        DATE,
    upd_by        VARCHAR2(100),
    upd_dt        DATE,
    CONSTRAINT fk_emp_job  FOREIGN KEY (job_id) REFERENCES jobs(job_id),
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE SEQUENCE employees_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

ALTER TABLE employees ADD CONSTRAINT fk_emp_mgr
FOREIGN KEY (manager_id)
REFERENCES employees(employee_id)
DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE departments ADD CONSTRAINT fk_dept_mgr FOREIGN KEY (manager_id) REFERENCES employees(employee_id) DEFERRABLE INITIALLY DEFERRED;

CREATE OR REPLACE TRIGGER trg_departments_bi
BEFORE INSERT OR UPDATE ON departments FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate department_id only if null during INSERT
    IF INSERTING AND :NEW.department_id IS NULL THEN
        v_seq := departments_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.department_name),1,3));
        :NEW.department_id := NVL(v_code, 'DEP') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_employees_bi
BEFORE INSERT OR UPDATE ON employees FOR EACH ROW
DECLARE v_seq NUMBER; v_code VARCHAR2(100);
BEGIN
    -- Generate employee_id only if null during INSERT
    IF INSERTING AND :NEW.employee_id IS NULL THEN
        v_seq := employees_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.last_name),1,3));
        :NEW.employee_id := NVL(v_code, 'EMP') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 15. SALES_MASTER
--------------------------------------------------------------------------------
CREATE TABLE sales_master (
    invoice_id     VARCHAR2(50) PRIMARY KEY,
    invoice_date   DATE DEFAULT SYSDATE,
    discount       NUMBER DEFAULT 0,
    vat            NUMBER DEFAULT 0,
    adjust_ref     VARCHAR2(50),
    total_amount  NUMBER(20,4)DEFAULT 0,
    adjust_amount  NUMBER(20,4)DEFAULT 0,
 --total_amount    NUMBER(20,4)DEFAULT 0,
    grand_total    NUMBER(20,4)DEFAULT 0,
    customer_id    VARCHAR2(50) NULL,
    sales_by       VARCHAR2(50) NULL,
    status         NUMBER,
    cre_by         VARCHAR2(100),
    cre_dt         DATE,
    upd_by         VARCHAR2(100),
    upd_dt         DATE,
    CONSTRAINT fk_sales_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_sales_emp  FOREIGN KEY (sales_by) REFERENCES employees(employee_id)
);

CREATE SEQUENCE sales_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_sales_master_bi
BEFORE INSERT OR UPDATE ON sales_master
FOR EACH ROW
BEGIN
    IF INSERTING AND :NEW.invoice_id IS NULL THEN
        :NEW.invoice_id := 'INV' || TO_CHAR(sales_seq.NEXTVAL);
    END IF;

    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/


--------------------------------------------------------------------------------
-- 16. SALES_RETURN_MASTER
--------------------------------------------------------------------------------
CREATE TABLE sales_return_master (
    sales_return_id VARCHAR2(50) PRIMARY KEY,
    invoice_id      VARCHAR2(50) NULL, 
    customer_id  VARCHAR2(50) NULL,
    return_date     DATE DEFAULT SYSDATE,
    total_amount    NUMBER(20,4)DEFAULT 0,
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_srm_inv   FOREIGN KEY (invoice_id) REFERENCES sales_master(invoice_id),
    CONSTRAINT fk_srm_cust  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE SEQUENCE sales_ret_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_sales_ret_bi
BEFORE INSERT OR UPDATE ON sales_return_master FOR EACH ROW
BEGIN
    -- Generate sales_return_id only if null during INSERT
    IF INSERTING AND :NEW.sales_return_id IS NULL THEN
        :NEW.sales_return_id := 'SRT' || TO_CHAR(sales_ret_seq.NEXTVAL);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

ALTER TABLE sales_master ADD CONSTRAINT fk_sales_adjust FOREIGN KEY (adjust_ref) REFERENCES sales_return_master(sales_return_id);

--------------------------------------------------------------------------------
-- 17. SERVICE_MASTER
--------------------------------------------------------------------------------
CREATE TABLE service_master (
    service_id          VARCHAR2(50) PRIMARY KEY,
    service_date        DATE DEFAULT SYSDATE,
    customer_id         VARCHAR2(50) NULL,
    invoice_id          VARCHAR2(50) NULL,
    invoice_date        DATE, 
    warranty_applicable CHAR(1),
    service_by          VARCHAR2(50) NULL,
    service_charge_total     NUMBER DEFAULT 0,
    total_price         NUMBER(20,4)DEFAULT 0,
    vat                 NUMBER(20,4)DEFAULT 0,
    grand_total         NUMBER(20,4)DEFAULT 0,
    status              NUMBER,
    cre_by              VARCHAR2(100),
    cre_dt              DATE,
    upd_by              VARCHAR2(100),
    upd_dt              DATE,
    CONSTRAINT fk_sm_cust FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_sm_emp  FOREIGN KEY (service_by) REFERENCES employees(employee_id),
    CONSTRAINT fk_sm_inv  FOREIGN KEY (invoice_id) REFERENCES sales_master(invoice_id)
);

CREATE SEQUENCE service_master_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

--------------------------------------------------------------------------------
-- 18. PRODUCT_ORDER_MASTER 
--------------------------------------------------------------------------------
CREATE TABLE product_order_master (
    order_id      VARCHAR2(50) PRIMARY KEY,
    order_date    DATE DEFAULT SYSDATE,
    supplier_id   VARCHAR2(50) NULL,
    expected_delivery_date DATE,
    order_by      VARCHAR2(50) NULL, 
    total_amount  NUMBER(20,4)DEFAULT 0,
    Vat           NUMBER(20,4)DEFAULT 0,
    Grand_total   NUMBER(20,4)DEFAULT 0,
    status        NUMBER,
    cre_by        VARCHAR2(100),
    cre_dt        DATE,
    upd_by        VARCHAR2(100),
    upd_dt        DATE,
    CONSTRAINT fk_pom_sup  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_pom_emp  FOREIGN KEY (order_by) REFERENCES employees(employee_id)
);

CREATE SEQUENCE order_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_prod_order_bi
BEFORE INSERT OR UPDATE ON product_order_master FOR EACH ROW
BEGIN
    -- Generate order_id only if null during INSERT
    IF INSERTING AND :NEW.order_id IS NULL THEN
        :NEW.order_id := 'ORD' || TO_CHAR(order_seq.NEXTVAL);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 19. PRODUCT_RECEIVE_MASTER 
--------------------------------------------------------------------------------
CREATE TABLE product_receive_master (
    receive_id      VARCHAR2(50) PRIMARY KEY,
    receive_date    DATE DEFAULT SYSDATE,
    order_id        VARCHAR2(50) NULL,
    sup_invoice_id  VARCHAR2(50) UNIQUE,
    supplier_id     VARCHAR2(50) NULL, 
    received_by     VARCHAR2(50) NULL, 
    total_amount    NUMBER(20,4)DEFAULT 0,
    vat             NUMBER(20,4)DEFAULT 0, 
    grand_total     NUMBER(20,4)DEFAULT 0,   
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_pr_emp FOREIGN KEY (received_by) REFERENCES employees(employee_id),
    CONSTRAINT fk_pr_sup FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_pr_order FOREIGN KEY (order_id) REFERENCES product_order_master(order_id)
);

CREATE SEQUENCE receive_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_prod_recv_bi
BEFORE INSERT OR UPDATE ON product_receive_master FOR EACH ROW
DECLARE
    v_seq NUMBER;
    v_latest_order VARCHAR2(50);
BEGIN
    -- Generate receive_id only if null during INSERT
    IF INSERTING AND :NEW.receive_id IS NULL THEN
        v_seq := receive_seq.NEXTVAL;
        :NEW.receive_id := 'RCV' || TO_CHAR(v_seq);
        -- Auto-generate supplier invoice ID if not provided
        IF :NEW.sup_invoice_id IS NULL THEN
            :NEW.sup_invoice_id := 'SINV' || TO_CHAR(v_seq);
        END IF;
    END IF;
    
    -- Auto-populate order_id if null and supplier is provided
    -- This finds the most recent order from this supplier
    IF :NEW.order_id IS NULL AND :NEW.supplier_id IS NOT NULL THEN
        BEGIN
            SELECT order_id INTO v_latest_order
            FROM (
                SELECT order_id 
                FROM product_order_master
                WHERE supplier_id = :NEW.supplier_id
                ORDER BY order_date DESC, order_id DESC
            )
            WHERE ROWNUM = 1;
            
            :NEW.order_id := v_latest_order;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL; -- Leave order_id as NULL if no orders found
        END;
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 20. PRODUCT_RETURN_MASTER 
--------------------------------------------------------------------------------
CREATE TABLE product_return_master (
    return_id       VARCHAR2(50) PRIMARY KEY,
    supplier_id     VARCHAR2(50) NULL,
    receive_id      VARCHAR2(50) NULL,
    order_id        VARCHAR2(50) NULL,
    return_date     DATE DEFAULT SYSDATE,
    return_by       VARCHAR2(50) NULL, 
    total_amount    NUMBER(20,4)DEFAULT 0,
    adjusted_vat    NUMBER(20,4)DEFAULT 0, 
    grand_total     NUMBER(20,4)DEFAULT 0,
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_pre_sup FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_pre_rcv FOREIGN KEY (receive_id) REFERENCES product_receive_master(receive_id),
    CONSTRAINT fk_pre_order FOREIGN KEY (order_id) REFERENCES product_order_master(order_id),
    CONSTRAINT fk_pre_emp FOREIGN KEY (return_by) REFERENCES employees(employee_id)
);

CREATE SEQUENCE prod_ret_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_prod_ret_bi
BEFORE INSERT OR UPDATE ON product_return_master FOR EACH ROW
BEGIN
    -- Generate return_id only if null during INSERT
    IF INSERTING AND :NEW.return_id IS NULL THEN
        :NEW.return_id := 'PRT' || TO_CHAR(prod_ret_seq.NEXTVAL);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 21. DAMAGE
--------------------------------------------------------------------------------
CREATE TABLE damage (
 damage_id VARCHAR2(50) PRIMARY KEY,
 damage_date DATE DEFAULT SYSDATE,
 reference_no VARCHAR2(100), -- New: Link to Sales/Purchase doc
 total_loss NUMBER DEFAULT 0,
 status NUMBER DEFAULT 1, -- 1: Draft, 2: Approved, 3: Cancelled
 approved_by VARCHAR2(100),
 approval_date DATE,
 cre_by VARCHAR2(100),
 cre_dt DATE,
 upd_by VARCHAR2(100),
 upd_dt DATE, 
    CONSTRAINT fk_dmg_emp FOREIGN KEY (approved_by) REFERENCES employees(employee_id)
);

CREATE SEQUENCE damage_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_damage_bi
BEFORE INSERT OR UPDATE ON damage FOR EACH ROW
BEGIN
    -- Generate damage_id only if null during INSERT
    IF INSERTING AND :NEW.damage_id IS NULL THEN
        :NEW.damage_id := 'DMG' || TO_CHAR(damage_seq.NEXTVAL);
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 22. STOCK
--------------------------------------------------------------------------------
CREATE TABLE stock (
    stock_id        VARCHAR2(50) PRIMARY KEY,
    product_id      VARCHAR2(50) NULL,
    supplier_id     VARCHAR2(50) NULL,
    product_cat_id  VARCHAR2(50) NULL,
    sub_cat_id      VARCHAR2(50) NULL,
    quantity        NUMBER DEFAULT 0,
    last_update     TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_s_p   FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_s_sup FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_prod_cat FOREIGN KEY (product_cat_id) REFERENCES product_categories(product_cat_id),
    CONSTRAINT chk_stock_qty CHECK (quantity >= 0),
    CONSTRAINT uk_stock_product UNIQUE (product_id)
);

CREATE SEQUENCE stock_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_stock_bi
BEFORE INSERT OR UPDATE ON stock FOR EACH ROW
BEGIN
    -- Generate stock_id only if null during INSERT
    IF INSERTING AND :NEW.stock_id IS NULL THEN
        :NEW.stock_id := 'STK' || TO_CHAR(stock_seq.NEXTVAL);
    END IF;
    
    -- Update timestamp on any change
    IF UPDATING THEN
        :NEW.last_update := SYSTIMESTAMP;
    END IF;
END;
/
--------------------------------------------------------------------------------
CREATE TABLE service_details (
    service_det_id     VARCHAR2(50) PRIMARY KEY,
    service_id         VARCHAR2(50) NULL,
    product_id         VARCHAR2(50) NULL,
    servicelist_id     VARCHAR2(50) NULL,
    parts_id           VARCHAR2(50) NULL,
    service_charge     NUMBER DEFAULT 0,
    parts_price        NUMBER DEFAULT 0,
    quantity           NUMBER DEFAULT 1, 
    line_total         NUMBER DEFAULT 0,
    description        VARCHAR2(1000), 
    warranty_status    VARCHAR2(50),
    CONSTRAINT fk_sd_master FOREIGN KEY (service_id) REFERENCES service_master(service_id),
    CONSTRAINT fk_sd_list   FOREIGN KEY (servicelist_id) REFERENCES service_list(servicelist_id),
    CONSTRAINT fk_sd_parts  FOREIGN KEY (parts_id) REFERENCES parts(parts_id),
    CONSTRAINT fk_sd_prod   FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE service_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_service_det_bi BEFORE INSERT ON service_details FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.service_det_id IS NULL THEN
	:NEW.service_det_id := 'SDT' || TO_CHAR(service_det_seq.NEXTVAL);  
END IF;
END;
/

-- Keep service_master audit columns current when any service detail changes
CREATE OR REPLACE TRIGGER trg_service_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON service_details
FOR EACH ROW
DECLARE
    v_service_id service_details.service_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_service_id := :NEW.service_id;
    ELSE
        v_service_id := :OLD.service_id;
    END IF;

    UPDATE service_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE service_id = v_service_id;
END;
/

--------------------------------------------------------------------------------
-- 24. SALES_DETAIL
--------------------------------------------------------------------------------
CREATE TABLE sales_detail (
    sales_det_id   VARCHAR2(50) PRIMARY KEY,
    invoice_id     VARCHAR2(50) NULL,
    product_id     VARCHAR2(50) NULL,
    mrp            NUMBER,
    purchase_price NUMBER,
    discount_amount NUMBER,
    quantity       NUMBER,
    description    VARCHAR2(1000), 
    CONSTRAINT fk_sdt_inv  FOREIGN KEY (invoice_id) REFERENCES sales_master(invoice_id) ON DELETE CASCADE,
    CONSTRAINT fk_sdt_prod FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE sales_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_sales_det_bi BEFORE INSERT ON sales_detail FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.sales_det_id IS NULL THEN
	:NEW.sales_det_id := 'SLD' || TO_CHAR(sales_det_seq.NEXTVAL); 
END IF;
END;
/


/

-- Keep sales_master audit columns current when any sales detail changes
CREATE OR REPLACE TRIGGER trg_sales_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON sales_detail
FOR EACH ROW
DECLARE
    v_invoice_id sales_detail.invoice_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_invoice_id := :NEW.invoice_id;
    ELSE
        v_invoice_id := :OLD.invoice_id;
    END IF;

    UPDATE sales_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE invoice_id = v_invoice_id;
END;
/
 CREATE OR REPLACE TRIGGER trg_sales_final_calc
FOR INSERT OR UPDATE OR DELETE ON sales_detail
COMPOUND TRIGGER

  -- এফেক্টেড ইনভয়েস আইডি রাখার লিস্ট
  TYPE t_inv_list IS TABLE OF sales_detail.invoice_id%TYPE INDEX BY PLS_INTEGER;
  v_inv_ids t_inv_list;

  -- ১. কোন ইনভয়েসে চেঞ্জ হচ্ছে তা নোট করা
  AFTER EACH ROW IS
  BEGIN
    IF INSERTING OR UPDATING THEN
       v_inv_ids(v_inv_ids.COUNT + 1) := :NEW.invoice_id;
    ELSIF DELETING THEN
       v_inv_ids(v_inv_ids.COUNT + 1) := :OLD.invoice_id;
    END IF;
  END AFTER EACH ROW;

  -- ২. সবশেষে ক্যালকুলেশন করা (শুধুমাত্র নির্দিষ্ট আইডির জন্য)
  AFTER STATEMENT IS
    v_total NUMBER;
    v_grand_total NUMBER;
    v_vat NUMBER;
    v_discount NUMBER;
    v_adj_amount NUMBER;
  BEGIN
    FOR i IN 1 .. v_inv_ids.COUNT LOOP
      
      -- টোটাল বের করা
      SELECT NVL(SUM(mrp * quantity), 0)
      INTO v_total
      FROM sales_detail
      WHERE invoice_id = v_inv_ids(i);
      
      -- মাস্টার টেবিল থেকে ডিসকাউন্ট, ভ্যাট, অ্যাডজাস্টমেন্ট আনা
      SELECT NVL(discount,0), NVL(vat,0), NVL(adjust_amount,0)
      INTO v_discount, v_vat, v_adj_amount
      FROM sales_master
      WHERE invoice_id = v_inv_ids(i);

      -- আপনার দেওয়া ফর্মুলা অনুযায়ী গ্র্যান্ড টোটাল
      -- Formula: (Total - Discount - Adjust) + VAT%
      
      v_grand_total := (v_total - v_discount - v_adj_amount) * (1 + v_vat/100);

      -- আপডেট
      UPDATE sales_master
      SET total_amount = v_total,
          grand_total = ROUND(v_grand_total, 2) -- দশমিকের পর ২ ঘর রাখা ভালো
      WHERE invoice_id = v_inv_ids(i);
      
    END LOOP;
  END AFTER STATEMENT;

END trg_sales_final_calc;
/
 
--------------------------------------------------------------------------------
-- 25. SALES_RETURN_DETAILS
--------------------------------------------------------------------------------
CREATE TABLE sales_return_details (
    sales_return_det_id VARCHAR2(50) PRIMARY KEY,
    sales_return_id     VARCHAR2(50) NULL,
    product_id          VARCHAR2(50) NULL,
    mrp                 NUMBER,
    purchase_price      NUMBER,
    quantity            NUMBER,
    discount_amount     NUMBER,
    ITEM_TOTAL          NUMBER,
--  RETURN_TOTAL        NUMBER,
    qty_return          NUMBER,
    reason              VARCHAR2(4000),
    CONSTRAINT fk_srd_mst FOREIGN KEY (sales_return_id) REFERENCES sales_return_master(sales_return_id),
    CONSTRAINT fk_srd_prd FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE sales_ret_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_sales_ret_det_bi BEFORE INSERT ON sales_return_details FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.sales_return_det_id IS NULL THEN
	:NEW.sales_return_det_id := 'SRD' || TO_CHAR(sales_ret_det_seq.NEXTVAL); 
END IF;
END;
/

-- Keep sales_return_master audit columns current when any return detail changes
CREATE OR REPLACE TRIGGER trg_sales_ret_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON sales_return_details
FOR EACH ROW
DECLARE
    v_sales_return_id sales_return_details.sales_return_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_sales_return_id := :NEW.sales_return_id;
    ELSE
        v_sales_return_id := :OLD.sales_return_id;
    END IF;

    UPDATE sales_return_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE sales_return_id = v_sales_return_id;
END;
/

--------------------------------------------------------------------------------
-- 26. PRODUCT_ORDER_DETAIL
--------------------------------------------------------------------------------
CREATE TABLE product_order_detail (
    order_detail_id VARCHAR2(50) PRIMARY KEY,
    order_id        VARCHAR2(50) NULL,
    product_id      VARCHAR2(50) NULL,
    mrp             NUMBER, 
    purchase_price  NUMBER, 
    quantity        NUMBER,
    CONSTRAINT fk_pod_mst FOREIGN KEY (order_id) REFERENCES product_order_master(order_id),
    CONSTRAINT fk_pod_prd FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE order_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER trg_order_det_bi BEFORE INSERT ON product_order_detail FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.order_detail_id IS NULL THEN
	:NEW.order_detail_id := 'ODT' || TO_CHAR(order_det_seq.NEXTVAL); 
END IF;
END;
/

-- Keep product_order_master audit columns current when any order detail changes
CREATE OR REPLACE TRIGGER trg_order_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON product_order_detail
FOR EACH ROW
DECLARE
    v_order_id product_order_detail.order_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_order_id := :NEW.order_id;
    ELSE
        v_order_id := :OLD.order_id;
    END IF;

    UPDATE product_order_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE order_id = v_order_id;
END;
/
CREATE OR REPLACE TRIGGER tri_total_price_compound
FOR INSERT OR UPDATE OR DELETE ON PRODUCT_ORDER_DETAIL
COMPOUND TRIGGER

  -- একটি কালেকশন তৈরি করা হলো যেখানে আমরা এফেক্টেড অর্ডার আইডিগুলো রাখব
  TYPE t_order_id_list IS TABLE OF PRODUCT_ORDER_DETAIL.ORDER_ID%TYPE INDEX BY PLS_INTEGER;
  v_order_ids t_order_id_list;

  -- ধাপ ১: ইনসার্ট বা আপডেটের সময় অর্ডার আইডিগুলো সংগ্রহ করা
  AFTER EACH ROW IS
  BEGIN
    IF INSERTING OR UPDATING THEN
       v_order_ids(v_order_ids.COUNT + 1) := :NEW.ORDER_ID;
    ELSIF DELETING THEN
       v_order_ids(v_order_ids.COUNT + 1) := :OLD.ORDER_ID;
    END IF;
  END AFTER EACH ROW;

  -- ধাপ ২: সব কাজ শেষে মূল টেবিলে আপডেট চালানো (এখানে আর Mutating Error হবে না)
  AFTER STATEMENT IS
    v_total NUMBER;
    v_grand_total NUMBER;
  BEGIN
    -- ডুপ্লিকেট আইডি রিমুভ করার জন্য লজিক (সাধারণত দরকার হয় না যদি আমরা লুপ চালাই)
    -- আমরা সরাসরি লুপ চালিয়ে আপডেট করব
    FOR i IN 1 .. v_order_ids.COUNT LOOP
      
      -- ক্যালকুলেশন
      SELECT NVL(SUM(purchase_price * quantity), 0)
      INTO v_total
      FROM PRODUCT_ORDER_DETAIL
      WHERE ORDER_ID = v_order_ids(i);
      
      -- গ্র্যান্ড টোটাল (VAT ১০% ধরে)
      v_grand_total := v_total + (v_total * 0.10); -- 10/100 = 0.10

      -- মাস্টার টেবিল আপডেট (শুধুমাত্র নির্দিষ্ট অর্ডারের জন্য)
      UPDATE PRODUCT_ORDER_MASTER
      SET total_amount = v_total,
          grand_total = v_grand_total
      WHERE ORDER_ID = v_order_ids(i);
      
    END LOOP;
  END AFTER STATEMENT;

END tri_total_price_compound;
/
--------------------------------------------------------------------------------
-- 27. PRODUCT_RECEIVE_DETAILS
--------------------------------------------------------------------------------
CREATE TABLE product_receive_details (
    receive_det_id   VARCHAR2(50) PRIMARY KEY,
    receive_id       VARCHAR2(50) NULL,
    product_id       VARCHAR2(50) NULL,
    mrp              NUMBER,             
    purchase_price   NUMBER,             
    receive_quantity NUMBER,
    CONSTRAINT fk_prd_mst FOREIGN KEY (receive_id) REFERENCES product_receive_master(receive_id),
    CONSTRAINT fk_prd_prd FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE recv_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER trg_recv_det_bi BEFORE INSERT ON product_receive_details FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.receive_det_id IS NULL THEN
 :NEW.receive_det_id := 'RDT' || TO_CHAR(recv_det_seq.NEXTVAL); 
END IF;
END;
/

-- CONTROL block er calculation database a save rakhar jonno DB trigger----

---------------------------------------------------------
CREATE OR REPLACE TRIGGER tri_total_amount
AFTER INSERT OR UPDATE OR DELETE ON product_receive_details
DECLARE
BEGIN
    FOR r IN (
        SELECT DISTINCT receive_id
        FROM product_receive_details
    ) LOOP

        UPDATE product_receive_master m
        SET m.total_amount = (
                SELECT NVL(SUM(d.purchase_price * d.receive_quantity), 0)
                FROM product_receive_details d
                WHERE d.receive_id = r.receive_id
            ),
            m.grand_total = (
                SELECT NVL(SUM(d.purchase_price * d.receive_quantity), 0)
                FROM product_receive_details d
                WHERE d.receive_id = r.receive_id
            )
            + NVL((
                SELECT NVL(SUM(d.purchase_price * d.receive_quantity), 0)
                       * NVL(m.vat,0) / 100
                FROM product_receive_details d
                WHERE d.receive_id = r.receive_id
            ),0)
        WHERE m.receive_id = r.receive_id;

    END LOOP;
END;
/





-- Keep product_receive_master audit columns current when any receive detail changes
CREATE OR REPLACE TRIGGER trg_recv_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON product_receive_details
FOR EACH ROW
DECLARE
    v_receive_id product_receive_details.receive_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_receive_id := :NEW.receive_id;
    ELSE
        v_receive_id := :OLD.receive_id;
    END IF;

    UPDATE product_receive_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE receive_id = v_receive_id;
END;
/


/

--------------------------------------------------------------------------------
-- 28. PRODUCT_RETURN_DETAILS
--------------------------------------------------------------------------------
CREATE TABLE product_return_details (
    return_detail_id VARCHAR2(50) PRIMARY KEY,
    return_id        VARCHAR2(50) NULL,
    product_id       VARCHAR2(50) NULL,
    mrp              NUMBER,             
    purchase_price   NUMBER,             
    return_quantity  NUMBER, 
    reason           VARCHAR2(1000),
    CONSTRAINT fk_prdet_mst FOREIGN KEY (return_id) REFERENCES product_return_master(return_id),
    CONSTRAINT fk_prdet_prd FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE prod_ret_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_prod_ret_det_bi BEFORE INSERT ON product_return_details FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.return_detail_id IS NULL THEN
:NEW.return_detail_id := 'PRD' || TO_CHAR(prod_ret_det_seq.NEXTVAL); 
END IF;
END;
/

--RETURN_MASTER.total_amount---------
------------------------------------------
CREATE OR REPLACE TRIGGER tri_total_price
AFTER INSERT OR UPDATE OR DELETE ON product_return_details
DECLARE
BEGIN
    FOR r IN (
        SELECT DISTINCT return_id
        FROM product_return_details
    ) LOOP

        UPDATE product_return_master m
        SET m.total_amount = (
                SELECT NVL(SUM(d.purchase_price * d.return_quantity), 0)
                FROM product_return_details d
                WHERE d.return_id = r.return_id
            ),
            m.grand_total = (
                SELECT NVL(SUM(d.purchase_price * d.return_quantity), 0)
                FROM product_return_details d
                WHERE d.return_id = r.return_id
            )
            + NVL((
                SELECT NVL(SUM(d.purchase_price * d.return_quantity), 0)
                       * NVL(m.adjusted_vat,0) / 100
                FROM product_return_details d
                WHERE d.return_id = r.return_id
            ),0)
        WHERE m.return_id = r.return_id;

    END LOOP;
END;
/



/

-- Keep product_return_master audit columns current when any return detail changes
CREATE OR REPLACE TRIGGER trg_prod_ret_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON product_return_details
FOR EACH ROW
DECLARE
    v_return_id product_return_details.return_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_return_id := :NEW.return_id;
    ELSE
        v_return_id := :OLD.return_id;
    END IF;

    UPDATE product_return_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE return_id = v_return_id;
END;
/

--------------------------------------------------------------------------------
-- 29. EXPENSE_MASTER
--------------------------------------------------------------------------------
CREATE TABLE expense_master (
    expense_id      VARCHAR2(50) PRIMARY KEY,
    expense_date    DATE,
    department_id   VARCHAR2(100),
    expense_type_id VARCHAR2(50),
    expense_by      VARCHAR2(100),
    expense_total   NUMBER,
    status          NUMBER,
    cre_by          VARCHAR2(100),
    cre_dt          DATE,
    upd_by          VARCHAR2(100),
    upd_dt          DATE,
    CONSTRAINT fk_ex_mst FOREIGN KEY (expense_type_id) REFERENCES expense_list(expense_type_id),
    CONSTRAINT fk_ex_dept FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE SEQUENCE exp_mst_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER trg_exp_mst_bi BEFORE INSERT OR UPDATE ON expense_master FOR EACH ROW
BEGIN
    -- Generate expense_id only if null during INSERT
    IF INSERTING AND :NEW.expense_id IS NULL THEN
        :NEW.expense_id := 'EXM' || TO_CHAR(exp_mst_seq.NEXTVAL); 
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 30. EXPENSE_DETAILS
--------------------------------------------------------------------------------
CREATE TABLE expense_details (
    expense_det_id    VARCHAR2(50) PRIMARY KEY,
    expense_id        VARCHAR2(50) NOT NULL,
    description       VARCHAR2(1000),
    amount            NUMBER(15,2) DEFAULT 0,
    CONSTRAINT fk_ex_det_mst FOREIGN KEY (expense_id) REFERENCES expense_master(expense_id)
);


CREATE SEQUENCE exp_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER trg_exp_det_bi BEFORE INSERT OR UPDATE ON expense_details FOR EACH ROW
DECLARE v_seq NUMBER;
BEGIN 
    IF INSERTING AND :NEW.expense_det_id IS NULL THEN
        v_seq := exp_det_seq.NEXTVAL;
        :NEW.expense_det_id := 'EXD' || TO_CHAR(v_seq);
    END IF; 
END;
/
----------------------------------------------------
----EXPENSE_MASTER ER total_Amoun er trigger--------

CREATE OR REPLACE TRIGGER tri_expense_total
AFTER INSERT OR UPDATE OR DELETE ON expense_details
BEGIN
   FOR r IN (
      SELECT DISTINCT expense_id
      FROM expense_details
   ) LOOP
      UPDATE expense_master m
      SET m.expense_total = (
         SELECT NVL(SUM(d.amount), 0)
         FROM expense_details d
         WHERE d.expense_id = r.expense_id
      )
      WHERE m.expense_id = r.expense_id;
   END LOOP;
END;
/

-- Keep expense_master audit columns current when any detail row changes
CREATE OR REPLACE TRIGGER trg_exp_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON expense_details
FOR EACH ROW
DECLARE
    v_expense_id expense_details.expense_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_expense_id := :NEW.expense_id;
    ELSE
        v_expense_id := :OLD.expense_id;
    END IF;

    UPDATE expense_master
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE expense_id = v_expense_id;
END;
/

--------------------------------------------------------------------------------
-- 31. DAMAGE_DETAIL 
--------------------------------------------------------------------------------
CREATE TABLE damage_detail (
    damage_detail_id VARCHAR2(50) PRIMARY KEY,
    damage_id        VARCHAR2(50),
    product_id       VARCHAR2(50),
    mrp              NUMBER,
    purchase_price   NUMBER,
    damage_quantity  NUMBER,
    reason           VARCHAR2(1000),
    CONSTRAINT fk_dmg_mst FOREIGN KEY (damage_id) REFERENCES damage(damage_id),
    CONSTRAINT fk_dmg_prd FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE SEQUENCE damage_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER trg_damage_det_bi BEFORE INSERT ON damage_detail FOR EACH ROW 
BEGIN 
IF INSERTING AND :NEW.damage_detail_id IS NULL THEN
:NEW.damage_detail_id := 'DDT' || TO_CHAR(damage_det_seq.NEXTVAL);
END IF; 
END;
/

-- Auto-update stock when damage details change (write-offs)
-- Stock automation trigger disabled - using manual stock inserts
/*
CREATE OR REPLACE TRIGGER trg_stock_on_damage_det
AFTER INSERT OR UPDATE OR DELETE ON damage_detail
FOR EACH ROW
DECLARE
    v_target_product damage_detail.product_id%TYPE;
    v_stock_id       stock.stock_id%TYPE;
    v_curr_qty       stock.quantity%TYPE;
    v_delta          NUMBER := 0;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_target_product := :NEW.product_id;
    ELSE
        v_target_product := :OLD.product_id;
    END IF;

    IF INSERTING THEN
        v_delta := -NVL(:NEW.damage_quantity,0);
    ELSIF DELETING THEN
        v_delta := NVL(:OLD.damage_quantity,0);
    ELSE
        IF :NEW.product_id = :OLD.product_id THEN
            v_delta := -(NVL(:NEW.damage_quantity,0) - NVL(:OLD.damage_quantity,0));
        ELSE
            -- Product changed: add back old quantity then deduct new
            SELECT stock_id, quantity INTO v_stock_id, v_curr_qty
            FROM stock WHERE product_id = :OLD.product_id
            FOR UPDATE;
            UPDATE stock SET quantity = v_curr_qty + NVL(:OLD.damage_quantity,0) WHERE stock_id = v_stock_id;
            v_delta := -NVL(:NEW.damage_quantity,0);
        END IF;
    END IF;

    IF v_delta <> 0 THEN
        SELECT stock_id, quantity INTO v_stock_id, v_curr_qty
        FROM stock WHERE product_id = v_target_product
        FOR UPDATE;
        IF v_curr_qty + v_delta < 0 THEN
            RAISE_APPLICATION_ERROR(-20015, 'Stock cannot go negative on damage write-off');
        END IF;
        UPDATE stock
        SET quantity = v_curr_qty + v_delta
        WHERE stock_id = v_stock_id;
    END IF;
END;
*/
/

-- Keep damage master audit columns current when any damage detail changes
CREATE OR REPLACE TRIGGER trg_damage_det_master_audit
AFTER INSERT OR UPDATE OR DELETE ON damage_detail
FOR EACH ROW
DECLARE
    v_damage_id damage_detail.damage_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_damage_id := :NEW.damage_id;
    ELSE
        v_damage_id := :OLD.damage_id;
    END IF;

    UPDATE damage
    SET upd_by = USER,
        upd_dt = SYSDATE
    WHERE damage_id = v_damage_id;
END;
/

--------------------------------------------------------------------------------
-- 32. COM_USERS
--------------------------------------------------------------------------------
CREATE TABLE com_users (
    user_id     VARCHAR2(50) PRIMARY KEY,
    user_name   VARCHAR2(100) NOT NULL UNIQUE,
    password    VARCHAR2(200) NOT NULL,
    role        VARCHAR2(50) DEFAULT 'user' NOT NULL,
    employee_id VARCHAR2(50),
    status      NUMBER,
    cre_by      VARCHAR2(100),
    cre_dt      DATE,
    upd_by      VARCHAR2(100),
    upd_dt      DATE,
    CONSTRAINT fk_users_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE SET NULL
);

CREATE SEQUENCE users_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_users_bi
BEFORE INSERT OR UPDATE ON com_users FOR EACH ROW
DECLARE 
    v_seq NUMBER; 
    v_code VARCHAR2(100);
BEGIN
    -- Generate user_id only if null during INSERT
    IF INSERTING AND :NEW.user_id IS NULL THEN
        v_seq := users_seq.NEXTVAL;
        v_code := UPPER(SUBSTR(TRIM(:NEW.user_name), 1, 3));
        :NEW.user_id := NVL(v_code, 'USR') || TO_CHAR(v_seq);
    END IF;
    
    -- Populate audit columns independently (not nested)
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;
END;
/

--------------------------------------------------------------------------------
-- 33. PAYMENTS
--------------------------------------------------------------------------------
CREATE TABLE payments (
    payment_id   VARCHAR2(50) PRIMARY KEY,
    payment_date DATE NOT NULL,
    amount       NUMBER NOT NULL CHECK (amount > 0),
    supplier_id  VARCHAR2(50) REFERENCES suppliers(supplier_id),
    payment_type VARCHAR2(50),
    CONSTRAINT chk_payment_type CHECK (UPPER(payment_type) IN ('CASH','ONLINE','BANK'))
);

CREATE SEQUENCE payments_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE OR REPLACE TRIGGER trg_payments_bi BEFORE INSERT OR UPDATE ON payments FOR EACH ROW
BEGIN
    IF INSERTING AND :NEW.payment_id IS NULL THEN
        :NEW.payment_id := 'PAY' || TO_CHAR(payments_seq.NEXTVAL);
    END IF;
END;
/



-- Keep suppliers audit columns current when any payment row changes
CREATE OR REPLACE TRIGGER trg_payments_supplier_audit
AFTER INSERT OR UPDATE OR DELETE ON payments
FOR EACH ROW
DECLARE
    v_supplier_id payments.supplier_id%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        v_supplier_id := :NEW.supplier_id;
    ELSE
        v_supplier_id := :OLD.supplier_id;
    END IF;

    IF v_supplier_id IS NOT NULL THEN
        UPDATE suppliers
        SET upd_by = USER,
            upd_dt = SYSDATE
        WHERE supplier_id = v_supplier_id;
    END IF;
END;
/


--FOR SUPPLIERS.PAY_TOTAL------------------------
-------------------------------------------------
CREATE OR REPLACE TRIGGER trg_suppliers_pay_total
FOR INSERT OR UPDATE OR DELETE ON payments
COMPOUND TRIGGER

  TYPE t_supplier IS TABLE OF payments.supplier_id%TYPE;
  g_suppliers t_supplier := t_supplier();

  BEFORE EACH ROW IS
  BEGIN
    IF INSERTING OR UPDATING OR DELETING THEN
      g_suppliers.EXTEND;
      g_suppliers(g_suppliers.COUNT) := :NEW.supplier_id;
    END IF;
  END BEFORE EACH ROW;

  AFTER STATEMENT IS
  BEGIN
    FOR i IN 1 .. g_suppliers.COUNT LOOP
      BEGIN
        UPDATE suppliers s
        SET s.pay_total = NVL((SELECT SUM(amount)
                               FROM payments
                               WHERE supplier_id = g_suppliers(i)),0)
        WHERE s.supplier_id = g_suppliers(i);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL; -- ignore
      END;
    END LOOP;
  END AFTER STATEMENT;

END;
/

--FOR SUPPLIER.PURCHASE_TOTAL AND DUE--------
---------------------------------------------

CREATE OR REPLACE TRIGGER trg_suppliers_from_receive
AFTER INSERT OR UPDATE OR DELETE ON product_receive_master
BEGIN
   UPDATE suppliers s
   SET
      s.purchase_total =
         NVL((SELECT SUM(grand_total)
              FROM product_receive_master
              WHERE supplier_id = s.supplier_id),0)
       -
         NVL((SELECT SUM(grand_total)
              FROM product_return_master
              WHERE supplier_id = s.supplier_id),0),

      s.pay_total =
         NVL((SELECT SUM(amount)
              FROM payments
              WHERE supplier_id = s.supplier_id),0),

      s.due =
         NVL((SELECT SUM(grand_total)
              FROM product_receive_master
              WHERE supplier_id = s.supplier_id),0)
       -
         NVL((SELECT SUM(grand_total)
              FROM product_return_master
              WHERE supplier_id = s.supplier_id),0)
       -
         NVL((SELECT SUM(amount)
              FROM payments
              WHERE supplier_id = s.supplier_id),0);
END;
/




CREATE OR REPLACE TRIGGER trg_suppliers_from_return
AFTER INSERT OR UPDATE OR DELETE ON product_return_master
BEGIN
   UPDATE suppliers s
   SET
      s.purchase_total =
         NVL((SELECT SUM(grand_total)
              FROM product_receive_master
              WHERE supplier_id = s.supplier_id),0)
       -
         NVL((SELECT SUM(grand_total)
              FROM product_return_master
              WHERE supplier_id = s.supplier_id),0),

      s.pay_total =
         NVL((SELECT SUM(amount)
              FROM payments
              WHERE supplier_id = s.supplier_id),0),

      s.due =
         NVL((SELECT SUM(grand_total)
              FROM product_receive_master
              WHERE supplier_id = s.supplier_id),0)
       -
         NVL((SELECT SUM(grand_total)
              FROM product_return_master
              WHERE supplier_id = s.supplier_id),0)
       -
         NVL((SELECT SUM(amount)
              FROM payments
              WHERE supplier_id = s.supplier_id),0);
END;
/





CREATE OR REPLACE TRIGGER trg_suppliers_from_payments
AFTER INSERT OR UPDATE OR DELETE ON payments
BEGIN
   UPDATE suppliers s
   SET
      s.purchase_total =
         NVL((SELECT SUM(grand_total)
              FROM product_receive_master
              WHERE supplier_id = s.supplier_id),0)
       -
         NVL((SELECT SUM(grand_total)
              FROM product_return_master
              WHERE supplier_id = s.supplier_id),0),

      s.pay_total =
         NVL((SELECT SUM(amount)
              FROM payments
              WHERE supplier_id = s.supplier_id),0),

      s.due =
         NVL((SELECT SUM(grand_total)
              FROM product_receive_master
              WHERE supplier_id = s.supplier_id),0)
       -
         NVL((SELECT SUM(grand_total)
              FROM product_return_master
              WHERE supplier_id = s.supplier_id),0)
       -
         NVL((SELECT SUM(amount)
              FROM payments
              WHERE supplier_id = s.supplier_id),0);
END;
/




--------------------------------------------------------------------------------
-- 17(a).SERVICE MASTER TRIGGER HERE 
--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_service_master_bi
BEFORE INSERT OR UPDATE ON service_master
FOR EACH ROW
DECLARE 
    v_inv_date DATE; 
    v_warranty NUMBER;
BEGIN
    -- ID generation (SAFE)
    IF INSERTING AND :NEW.service_id IS NULL THEN
        :NEW.service_id := 'SVM' || TO_CHAR(service_master_seq.NEXTVAL);
    END IF;

    -- Audit columns
    IF INSERTING THEN
        IF :NEW.status IS NULL THEN :NEW.status := 1; END IF;
        IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
        IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
    ELSIF UPDATING THEN
        :NEW.upd_by := USER;
        :NEW.upd_dt := SYSDATE;
    END IF;

    -- Warranty logic (SAFE)
    IF INSERTING AND :NEW.invoice_id IS NOT NULL THEN
        BEGIN
            SELECT m.invoice_date, p.warranty
            INTO v_inv_date, v_warranty
            FROM sales_master m
            JOIN sales_detail d ON m.invoice_id = d.invoice_id
            JOIN products p ON d.product_id = p.product_id AND p.status = 1
            WHERE m.invoice_id = :NEW.invoice_id
            AND ROWNUM = 1;

            IF v_inv_date + (v_warranty * 30) >= SYSDATE THEN
                :NEW.warranty_applicable := 'Y';
            ELSE
                :NEW.warranty_applicable := 'N';
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                :NEW.warranty_applicable := 'N';
        END;
    END IF;
END;
/
-------------------------------------------------------------

-- Infrastructure (01, 02, 13, 14)
INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Walton Plaza', 'Walton Hi-Tech Industries Ltd.', '01711000001', 'info@waltonplaza.com',
 'Plot-1088, Block-I, Bashundhara R/A, Dhaka', 'https://www.waltonplaza.com',
 'Rafiqul Islam', 'Regional Manager', '01711000091',
 'Your Trusted Electronics Partner',
 'To deliver advanced technology and reliable service nationwide.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Singer Bangladesh', 'Singer Bangladesh Ltd.', '01711000002', 'contact@singerbd.com',
 '89 Gulshan Avenue, Dhaka', 'https://www.singerbd.com',
 'Mahmud Hasan', 'Sales Manager', '01711000092',
 'Trusted Since 1905',
 'Providing quality electronics with after-sales excellence.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Vision Electronics', 'RFL Group', '01711000003', 'support@vision.com.bd',
 'PRAN-RFL Center, Badda, Dhaka', 'https://www.vision.com.bd',
 'Sajjad Hossain', 'Service Head', '01711000093',
 'Smart Life Smart Vision',
 'To bring innovative electronics to every home.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Jamuna Electronics', 'Jamuna Group', '01711000004', 'info@jamunaelectronics.com',
 'Jamuna Future Park, Dhaka', 'https://www.jamunaelectronics.com',
 'Abdul Karim', 'Area Manager', '01711000094',
 'Innovation for Better Life',
 'Expanding electronics solutions with nationwide coverage.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Minister Hi-Tech Park', 'Minister Group', '01711000005', 'service@ministerbd.com',
 'House-47, Road-35, Gulshan-2, Dhaka', 'https://www.ministerbd.com',
 'Shariful Islam', 'Service Coordinator', '01711000095',
 'Desh er TV',
 'To ensure quality electronics Made in Bangladesh.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('LG Electronics Bangladesh', 'LG Corporation', '01711000006', 'bd.info@lge.com',
 'Gulshan 1, Dhaka', 'https://www.lg.com/bd',
 'Tanvir Ahmed', 'Corporate Sales', '01711000096',
 'Life’s Good',
 'Enhancing lifestyle with smart electronics.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Samsung Consumer Electronics', 'Samsung Bangladesh', '01711000007', 'support@samsungbd.com',
 'Banani, Dhaka', 'https://www.samsung.com/bd',
 'Naeem Rahman', 'Channel Manager', '01711000097',
 'Inspire the World',
 'Delivering innovation and premium technology.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Sharp Electronics BD', 'Esquire Electronics Ltd.', '01711000008', 'info@sharpelectronics.com.bd',
 'Tejgaon I/A, Dhaka', 'https://www.sharpelectronicsbd.com',
 'Rezaul Karim', 'Service Manager', '01711000098',
 'Technology You Can Trust',
 'Delivering reliable consumer electronics nationwide.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Hitachi Home Appliances', 'Hitachi Bangladesh', '01711000009', 'contact@hitachibd.com',
 'Kawran Bazar, Dhaka', 'https://www.hitachibd.com',
 'Masud Rana', 'Key Account Manager', '01711000099',
 'Inspire the Next',
 'Delivering durable appliances with best service support.', 1);

INSERT INTO company
(company_name, company_proprietor, phone_no, email, address, website,
 contact_person, cp_designation, cp_phone_no, tag_line, mission_vision, status)
VALUES
('Transtec Electronics', 'Bangladesh Lamps Ltd.', '01711000010', 'info@transtec.com.bd',
 'Tejgaon Industrial Area, Dhaka', 'https://www.transtec.com.bd',
 'Ahsan Kabir', 'Regional Supervisor', '01711000100',
 'Powering Everyday Life',
 'Providing affordable and quality electronics.', 1);

--JOBS

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('SALES', 'Sales Executive', 'B', 18000, 30000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('CSUP', 'Customer Support Officer', 'B', 20000, 35000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('TECH', 'Service Technician', 'B', 22000, 40000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('MGR', 'Branch Manager', 'A', 40000, 65000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('ASM', 'Assistant Manager', 'A', 32000, 50000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('ACC', 'Accounts Officer', 'B', 25000, 42000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('STOR', 'Store Keeper', 'C', 15000, 25000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('DLV', 'Delivery Man', 'C', 12000, 20000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('IT', 'IT Support Officer', 'B', 28000, 45000);

INSERT INTO jobs (job_code, job_title, job_grade, min_salary, max_salary)
VALUES ('HR', 'HR and Admin Officer', 'A', 35000, 55000);

----
INSERT INTO customers (phone_no, customer_name, alt_phone_no, email, address, city, remarks)
VALUES ('01810000001','Md. Rakib Hasan','01820000001','rakib01@gmail.com','Mirpur-10, Dhaka','Dhaka','Regular customer');

INSERT INTO customers (phone_no, customer_name, alt_phone_no, email, address, city)
VALUES ('01810000002','Sadia Akter','01820000002','sadia.bd@gmail.com','Dhanmondi 32','Dhaka');

INSERT INTO customers (phone_no, customer_name, alt_phone_no, email, address, city)
VALUES ('01810000003','Mahmudul Hasan',NULL,'mahmud.hasan@yahoo.com','Uttara Sector 7','Dhaka');

INSERT INTO customers (phone_no, customer_name, email, address, city, remarks)
VALUES ('01810000004','Shafiq Ahmed','shafiq454@gmail.com','Nandan Park Road','Savar','Buys TV frequently');

INSERT INTO customers (phone_no, customer_name, email, address, city)
VALUES ('01810000005','Rumi Chowdhury','rumi.c@gmail.com','Halishahar','Chattogram');

INSERT INTO customers (phone_no, customer_name, alt_phone_no, email, address, city)
VALUES ('01810000006','Nazmul Islam','01820000006','nazmul_bd@gmail.com','Rajshahi City','Rajshahi');

INSERT INTO customers (phone_no, customer_name, email, address, city, remarks)
VALUES ('01810000007','Kamal Hossain','kamal.h@gmail.com','Khulna Sadar','Khulna','Warranty service user');

INSERT INTO customers (phone_no, customer_name, email, address, city)
VALUES ('01810000008','Farhana Yasmin','farhana88@gmail.com','Sylhet Ambarkhana','Sylhet');

INSERT INTO customers (phone_no, customer_name, email, address, city)
VALUES ('01810000009','Arif Mahmud','arifm@gmail.com','Cumilla Town','Cumilla');

INSERT INTO customers (phone_no, customer_name, email, address, city, remarks)
VALUES ('01810000010','Majedul Karim','majed.karim@gmail.com','Barisal Notun Bazar','Barisal','VIP Customer');
--------------------------------------------------------------------------------
-- 04. Parts_CATEGORIES (Master)
--------------------------------------------------------------------------------
INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('TV', 'Television Spare Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('FRG', 'Refrigerator Spare Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('AC', 'Air Conditioner Spare Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('WM', 'Washing Machine Spare Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('MIC', 'Microwave Oven Spare Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('MOB', 'Mobile Accessories and Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('LAP', 'Laptop and Computer Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('AUDIO', 'Audio System Spare Parts');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('PWR', 'Power Supply and Boards');

INSERT INTO parts_category (parts_cat_code, parts_cat_name)
VALUES ('GEN', 'General Electronic Components');

--------------------------------------------------------------------------------
-- 05. PRODUCT_CATEGORIES (Master)
--------------------------------------------------------------------------------

INSERT INTO product_categories (product_cat_name)
VALUES ('LED Television');

INSERT INTO product_categories (product_cat_name)
VALUES ('Refrigerator and Freezer');

INSERT INTO product_categories (product_cat_name)
VALUES ('Air Conditioner');

INSERT INTO product_categories (product_cat_name)
VALUES ('Washing Machine');

INSERT INTO product_categories (product_cat_name)
VALUES ('Microwave Oven');

INSERT INTO product_categories (product_cat_name)
VALUES ('Smart Phone');

INSERT INTO product_categories (product_cat_name)
VALUES ('Laptop and Computer');

INSERT INTO product_categories (product_cat_name)
VALUES ('Home Theater and Sound System');

INSERT INTO product_categories (product_cat_name)
VALUES ('Small Home Appliances');

INSERT INTO product_categories (product_cat_name)
VALUES ('Generator and Power Products');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Walton', 'WD-LED32F', '32 Inch', 'Black');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Walton', 'WTM-RT240', '240 Liter', 'Silver');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Samsung', 'UA43T5400', '43 Inch', 'Black');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Samsung', 'AR12MVF', '1 Ton', 'White');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('LG', 'GL-B201SLBB', '190 Liter', 'Silver');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('LG', 'LG-WM140', '8 Kg', 'White');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Singer', 'Singer Smart 32', '32 Inch', 'Black');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Hitachi', 'RAS-F13CF', '1 Ton', 'White');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Vision', 'VIS-24UD', '24 Inch', 'Black');

INSERT INTO brand (brand_name, model_name, brand_size, color)
VALUES ('Minister', 'M-DFR-240', '240 Liter', 'Red');


INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email)
VALUES
('Walton Spare Parts Division','01715000001','spares@waltonbd.com','Bashundhara Industrial Area, Dhaka',
 'Abdul Karim','Procurement Manager','01716000001','karim@waltonbd.com');

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email)
VALUES
('Samsung Authorized Distributor','01715000002','dist@samsungbd.com','Banani, Dhaka',
 'Tanvir Ahmed','Supply Lead','01716000002','tanvir@samsungbd.com');

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email)
VALUES
('LG Electronics Supplier','01715000003','supplier@lgbd.com','Gulshan-1, Dhaka',
 'Ruhul Amin','Account Manager','01716000003','amin@lgbd.com');

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email)
VALUES
('Vision / RFL Parts Supplier','01715000004','vision.parts@rfl.com','Badda, Dhaka',
 'Shahadat Hossain','Parts Coordinator','01716000004','shahadat@rfl.com');

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email)
VALUES
('Minister Hi-Tech Supplier','01715000005','supplier@minister.com','Gulshan-2, Dhaka',
 'Nazmul Islam','Logistics Lead','01716000005','nazmul@minister.com');

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email)
VALUES
('Jamuna Electronics Supplier','01715000006','jamuna.supplier@gmail.com','Jamuna Future Park, Dhaka',
 'Faruk Ahmed','Senior Buyer','01716000006','faruk@jamuna.com');

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email)
VALUES
('Global Electronics Importer','01715000007','import@globalelec.com','Chawk Bazar, Dhaka',
 'Kamal Uddin','Import Manager','01716000007','kamal@globalelec.com');

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email)
VALUES
('Asian Spare Parts House','01715000008','asianparts@gmail.com','Elephant Road, Dhaka',
 'Sharif Al Mamun','Owner','01716000008','sharif@asparts.com');

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email)
VALUES
('Bangladesh Electronics Wholesale','01715000009','info@bdwholesale.com','Station Road, Chattogram',
 'Jahangir Alam','Wholesale Manager','01716000009','jahangir@bdwholesale.com');

INSERT INTO suppliers
(supplier_name, phone_no, email, address, contact_person, cp_designation, cp_phone_no, cp_email)
VALUES
('City Electronics Parts Supplier','01715000010','cityparts@gmail.com','Sylhet Amberkhana',
 'Shafiq Rahman','Parts Manager','01716000010','shafiq@cityparts.com');

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('TV Installation', 'Wall mount / table stand TV installation service', 800);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('TV Repair Service', 'LED/LCD television diagnosis and repair service', 1500);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Refrigerator Repair', 'Cooling issue, compressor issue, gas refill and repair', 2000);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('AC Installation', 'Indoor and outdoor AC installation with basic setup', 3500);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('AC Servicing', 'AC cleaning, gas checking, maintenance and servicing', 1500);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Washing Machine Repair', 'Repair and maintenance of automatic/manual washing machines', 1800);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Microwave Oven Repair', 'Heating problem / board problem repair service', 1200);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Laptop / Computer Repair', 'Hardware, software, OS and chip level checkup', 2000);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Mobile Service and Repair', 'Smartphone software and hardware problem fixing', 1000);

INSERT INTO service_list (service_name, service_desc, service_cost)
VALUES ('Home Appliance Diagnosis', 'General diagnosis and checking charge for appliances', 500);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('OFF', 'Office Rent', 'Monthly office/shop rent expense', 30000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('SAL', 'Staff Salary', 'Technician, sales and support staff salary expense', 80000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('UTL', 'Utility Bills', 'Electricity, gas and water bill payment', 15000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('INT', 'Internet and Telephone Bill', 'Office internet and phone bills', 5000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('TRN', 'Transport and Delivery Cost', 'Product delivery and technician transport', 12000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('MKT', 'Marketing and Promotion', 'Advertisement, banner and promotion expense', 10000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('REP', 'Office Repair and Maintenance', 'Shop/office repairing and maintenance', 7000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('PUR', 'Purchase Misc Expense', 'Unplanned purchase, packaging, loading', 6000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('TEC', 'Technician Allowance', 'On-site service allowance for technicians', 8000);

INSERT INTO expense_list (expense_code, type_name, description, default_amount)
VALUES ('OTH', 'Other General Expenses', 'Miscellaneous office related expenses', 3000);



-------------------------------------error free------------------------------

--------------------------------------------------------------------------------
-- 10. SUB_CATEGORIES (Automatic FK Linkage)
--------------------------------------------------------------------------------

-- LED Television Links
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Smart LED TV', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'LED Television'));
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Android TV', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'LED Television'));

-- Refrigerator Links
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Double Door Refrigerator', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Refrigerator and Freezer'));
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Deep Freezer', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Refrigerator and Freezer'));

-- Air Conditioner Links
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Split AC', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Air Conditioner'));
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Window AC', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Air Conditioner'));

-- Washing Machine Links
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Front Load Washing Machine', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Washing Machine'));
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Top Load Washing Machine', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Washing Machine'));

-- Microwave Oven Links
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Convection Microwave Oven', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Microwave Oven'));
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Solo Microwave Oven', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Microwave Oven'));

-- Smart Phone Links
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Android Smartphone', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Smart Phone'));
INSERT INTO sub_categories (sub_cat_name, product_cat_id) 
VALUES ('Feature Phone', (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Smart Phone'));

COMMIT;

--------------------------------------------------------------------------------
-- 11. PRODUCTS (Dynamic FK Mapping to ensure Integrity)
--------------------------------------------------------------------------------

-- Product 1: Samsung Galaxy S24
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'SAM-S24-018', 'Samsung Galaxy S24', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Smart Phone'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Android Smartphone'),
    (SELECT brand_id FROM brand WHERE model_name = 'UA43T5400'),
    'Pcs', 95000, 82000, 12
);

-- Product 2: iPhone 15 Pro
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'IPH-15-029', 'iPhone 15 Pro', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Smart Phone'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Android Smartphone'),
    (SELECT brand_id FROM brand WHERE model_name = 'WD-LED32F'),
    'Pcs', 145000, 130000, 12
);

-- Product 3: Dell Latitude
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'DEL-LAT-0310', 'Dell Latitude 5420', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Laptop and Computer'),
    NULL, -- No laptop sub-category exists in current schema
    (SELECT brand_id FROM brand WHERE model_name = 'WTM-RT240'),
    'Unit', 85000, 75000, 36
);

-- Product 4: LG Double Door Refrigerator
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'LG-REF-0411', 'LG Double Door Refrigerator', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Refrigerator and Freezer'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Double Door Refrigerator'),
    (SELECT brand_id FROM brand WHERE model_name = 'GL-B201SLBB'),
    'Unit', 75000, 65000, 24
);

-- Product 5: Walton 42 Inch LED
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'WAL-TV-0512', 'Walton 42 Inch LED', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'LED Television'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Smart LED TV'),
    (SELECT brand_id FROM brand WHERE model_name = 'WD-LED32F'),
    'Unit', 35000, 28000, 60
);

-- Product 6: Midea Split AC
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'MIN-AC-0613', 'Midea Split AC 1.5 Ton', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Air Conditioner'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Split AC'),
    (SELECT brand_id FROM brand WHERE model_name = 'M-DFR-240'),
    'Unit', 48000, 42000, 12
);

-- Product 7: Panasonic Microwave
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'PAN-MIC-0714', 'Panasonic Microwave', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Global Electronics Importer'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Microwave Oven'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Android Smartphone'),
    (SELECT brand_id FROM brand WHERE model_name = 'Singer Smart 32'),
    'Pcs', 18000, 15000, 12
);

-- Product 8: Samsung Front Load Washer
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'SAM-WASH-0815', 'Samsung Front Load Washer', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Washing Machine'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Front Load Washing Machine'),
    (SELECT brand_id FROM brand WHERE model_name = 'AR12MVF'),
    'Unit', 55000, 48000, 24
);

-- Product 9: Hitachi Silent Generator
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'HIT-GEN-0916', 'Hitachi Silent Generator', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Generator and Power Products'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Solo Microwave Oven'),
    (SELECT brand_id FROM brand WHERE model_name = 'RAS-F13CF'),
    'Unit', 120000, 105000, 12
);

-- Product 10: LG Home Theater
INSERT INTO products (product_code, product_name, supplier_id, category_id, sub_cat_id, brand_id, uom, mrp, purchase_price, warranty) 
VALUES (
    'LG-HOM-1017', 'LG Home Theater System', 
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier'),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Home Theater and Sound System'),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Top Load Washing Machine'),
    (SELECT brand_id FROM brand WHERE model_name = 'LG-WM140'),
    'Set', 25000, 21000, 12
);

COMMIT;

--------------------------------------------------------------------------------
-- 12. PARTS (Dynamic Mapping to Parts Category)
--------------------------------------------------------------------------------

-- Television Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('TV-MB', 'LED TV Motherboard', 2500, 4000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Television Spare Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('TV-DSP', 'LED TV Display Panel', 8000, 12000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Television Spare Parts' AND ROWNUM=1));

-- Refrigerator Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('FRG-COMP', 'Refrigerator Compressor Unit', 6500, 9500,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Refrigerator Spare Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('FRG-THERM', 'Refrigerator Thermostat', 1200, 2000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Refrigerator Spare Parts' AND ROWNUM=1));

-- Air Conditioner Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('AC-FAN', 'AC Outdoor Fan Motor', 3500, 5000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Air Conditioner Spare Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('AC-REMOTE', 'AC Remote Controller', 700, 1200,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Air Conditioner Spare Parts' AND ROWNUM=1));

-- Washing Machine Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('WM-BELT', 'Washing Machine Drum Belt', 400, 800,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Washing Machine Spare Parts' AND ROWNUM=1));

-- Microwave Oven Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('MIC-MAG', 'Microwave Oven Magnetron Tube', 2600, 4000,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Microwave Oven Spare Parts' AND ROWNUM=1));

-- Laptop and Computer Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('LAP-ADPT', 'Laptop Charger Adapter', 900, 1800,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Laptop and Computer Parts' AND ROWNUM=1));

-- Power Supply and Boards
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('PWR-BOARD', 'LED TV Power Supply Board', 1500, 2500,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Power Supply and Boards' AND ROWNUM=1));

-- Mobile and Smartphone Spare Parts
INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('MOB-BAT-S24', 'Samsung Galaxy S24 Battery', 1200, 1800,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Mobile Accessories and Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('MOB-DSP-S24', 'Samsung Galaxy S24 Display Panel', 2500, 3500,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Mobile Accessories and Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('MOB-BAT-GEN', 'Generic Smartphone Battery', 800, 1200,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Mobile Accessories and Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('MOB-SCR-GEN', 'Generic Mobile Screen Protector', 150, 300,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Mobile Accessories and Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('MOB-CHG-USB', 'USB Type-C Mobile Charger', 400, 700,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Mobile Accessories and Parts' AND ROWNUM=1));

INSERT INTO parts (parts_code, parts_name, purchase_price, mrp, parts_cat_id)
VALUES ('MOB-CASE', 'Universal Mobile Phone Case', 250, 500,
 (SELECT parts_cat_id FROM parts_category 
  WHERE parts_cat_name='Mobile Accessories and Parts' AND ROWNUM=1));


--------------------------------------------------------------------------------
-- 13. DEPARTMENTS (Matching Employee FKs)
--------------------------------------------------------------------------------
-- Data referenced by first set of employees
INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('PRO101', 'Procurement and Sourcing', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('LOG116', 'Logistics and Supply Chain', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('IT 106', 'IT Operations', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('HUM111', 'Human Resources', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('ACC96', 'Finance and Accounting', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

-- Data referenced by second set of employees
INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('SAL41', 'Sales Department', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('CUS46', 'Customer Support', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('SER51', 'After Sales Service', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('ACC56', 'Corporate Accounts', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('PRO61', 'General Procurement', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('IT 66', 'IT Infrastructure', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('HUM71', 'Human Capital Management', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));

INSERT INTO departments (department_id, department_name, company_id) 
VALUES ('LOG76', 'Shipping and Delivery', (SELECT company_id FROM company WHERE status = 1 AND ROWNUM = 1));



--------------------------------------------------------------------------------
-- 14. EMPLOYEES (Populated with your provided Job and Dept IDs)
--------------------------------------------------------------------------------

-- 1. The Manager (Insert first so others can reference as manager_id)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Rafiqul', 'Hasan', 'rafiqul.hasan@walton.com', '01711100001', 'Bashundhara, Dhaka', SYSDATE-800, 60000, 
        'MGR4', 'SAL41');

-- 2. Procurement Officer (References ASM5)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Zahid', 'Hasib', 'zahid.hasib@walton.com', '01711110010', 'Banani, Dhaka', SYSDATE-150, 33000, 
        'ASM5', 'PRO101');

-- 3. Store Keeper (References STOR7)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Rezaul', 'Karim', 'rezaul.karim@walton.com', '01711110005', 'Badda, Dhaka', SYSDATE-400, 22000, 
        'STOR7', 'LOG116');

-- 4. IT Support Officer (References IT9)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Tanvir', 'Rahman', 'tanvir.rahman@walton.com', '01711110006', 'Mohakhali, Dhaka', SYSDATE-350, 40000, 
        'IT9', 'IT 106');

-- 5. HR Officer (References HR10)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Sharmin', 'Begum', 'sharmin.begum@walton.com', '01711110007', 'Khilgaon, Dhaka', SYSDATE-300, 45000, 
        'HR10', 'HUM111');

-- 6. Sales Executive (References SALES1 and Manager Rafiqul)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Sadia', 'Akter', 'sadia.akter@walton.com', '01711100002', 'Mirpur, Dhaka', SYSDATE-500, 25000, 
        'SALES1', 'SAL41', (SELECT employee_id FROM employees WHERE last_name='Hasan' AND status = 1 AND ROWNUM=1));

-- 7. Customer Support (References CSUP2)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Kamal', 'Hossain', 'kamal.hossain@walton.com', '01711100003', 'Banani, Dhaka', SYSDATE-600, 28000, 
        'CSUP2', 'CUS46', (SELECT employee_id FROM employees WHERE last_name='Hasan' AND status = 1 AND ROWNUM=1));

-- 8. Service Technician (References TECH3)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Nazmul', 'Islam', 'nazmul.islam@walton.com', '01711100004', 'Uttara, Dhaka', SYSDATE-450, 35000, 
        'TECH3', 'SER51');

-- 9. Accounting Assistant (References ACC6)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Jannat', 'Ara', 'jannat.ara@walton.com', '01711110009', 'Tejgaon, Dhaka', SYSDATE-180, 26000, 
        'ACC6', 'ACC96');

-- 10. Delivery Staff (References DLV8)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Ahsan', 'Kabir', 'ahsan.kabir@walton.com', '01711110008', 'Khilkhet, Dhaka', SYSDATE-200, 15000, 
        'DLV8', 'LOG76');

-- 10b. IT Operations Manager (reports to Rafiqul Hasan)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Farid', 'Ahmed', 'farid.ahmed@walton.com', '01733300021', 'Baridhara, Dhaka', SYSDATE-420, 50000,
    'MGR4', 'IT 106', (SELECT employee_id FROM employees WHERE last_name='Hasan' AND status = 1 AND ROWNUM=1));

-- 10c. Procurement Manager (reports to Rafiqul Hasan)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Salma', 'Chowdhury', 'salma.chowdhury@walton.com', '01733300022', 'Gulshan, Dhaka', SYSDATE-380, 52000,
    'MGR4', 'PRO101', (SELECT employee_id FROM employees WHERE last_name='Hasan' AND status = 1 AND ROWNUM=1));



UPDATE employees
SET manager_id = (SELECT employee_id FROM employees WHERE last_name='Hasan' AND status = 1)
WHERE last_name <> 'Hasan';
UPDATE departments
SET manager_id = (SELECT employee_id FROM employees WHERE last_name='Hasan' AND status = 1);

-- Reassign specific departments to new managers
UPDATE departments
SET manager_id = (SELECT employee_id FROM employees WHERE email = 'farid.ahmed@walton.com' AND status = 1)
WHERE department_id = 'IT 106';

UPDATE departments
SET manager_id = (SELECT employee_id FROM employees WHERE email = 'salma.chowdhury@walton.com' AND status = 1)
WHERE department_id = 'PRO101';


--------------------------------------------------------------------------------
-- 14. EMPLOYEES (Additional Data Set)
--------------------------------------------------------------------------------

-- 11. Senior Accountant
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Fatima', 'Zohra', 'fatima.z@walton.com', '01722200011', 'Lalmatia, Dhaka', SYSDATE-700, 42000, 
        'ACC6', 'ACC56');

-- 12. Junior Sales Rep (Reporting to Rafiqul Hasan)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id, manager_id)
VALUES ('Sabbir', 'Ahmed', 'sabbir.a@walton.com', '01722200012', 'Farmgate, Dhaka', SYSDATE-120, 22000, 
        'SALES1', 'SAL41', (SELECT employee_id FROM employees WHERE last_name='Hasan' AND status = 1 AND ROWNUM=1));

-- 13. Senior Technician
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Mominul', 'Haque', 'momin.h@walton.com', '01722200013', 'Tongi, Gazipur', SYSDATE-950, 38000, 
        'TECH3', 'SER51');

-- 14. IT Security Specialist
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Ariful', 'Islam', 'arif.i@walton.com', '01722200014', 'Dhanmondi, Dhaka', SYSDATE-400, 45000, 
        'IT9', 'IT 66');

-- 15. HR Assistant
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Lutfur', 'Nahid', 'lutfur.n@walton.com', '01722200015', 'Malibagh, Dhaka', SYSDATE-280, 35000, 
        'HR10', 'HUM71');

-- 16. Customer Support Lead
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Rumana', 'Afroz', 'rumana.a@walton.com', '01722200016', 'Banani, Dhaka', SYSDATE-550, 31000, 
        'CSUP2', 'CUS46');

-- 17. Procurement Specialist
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Tariq', 'Aziz', 'tariq.a@walton.com', '01722200017', 'Uttara Sector 4, Dhaka', SYSDATE-320, 37000, 
        'ASM5', 'PRO61');

-- 18. Warehouse Assistant
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Shohel', 'Rana', 'shohel.r@walton.com', '01722200018', 'Savar, Dhaka', SYSDATE-100, 19000, 
        'STOR7', 'LOG76');

-- 19. Inventory Controller
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Keya', 'Payel', 'keya.p@walton.com', '01722200019', 'Nikunja, Dhaka', SYSDATE-480, 24000, 
        'STOR7', 'LOG116');

-- 20. Logistics Coordinator (Fixed salary: 20000 within DLV8 range 12000-20000)
INSERT INTO employees (first_name, last_name, email, phone_no, address, hire_date, salary, job_id, department_id)
VALUES ('Imtiaz', 'Bulbul', 'imtiaz.b@walton.com', '01722200020', 'Rampura, Dhaka', SYSDATE-600, 20000, 
        'DLV8', 'LOG116');

--------------------------------------------------------------------------------
-- 18. PRODUCT_ORDER_MASTER
-- Orders will be: ORD1, ORD2, ORD3, ORD4, ORD5, ORD6, ORD7, ORD8, ORD9, ORD10
--------------------------------------------------------------------------------

-- ORD1: Samsung Order for SAM-S24-018
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor'),
    (SELECT employee_id FROM employees WHERE first_name = 'Rafiqul' AND last_name = 'Hasan' AND status = 1 AND ROWNUM = 1),
    SYSDATE + 5, 1
);

-- ORD2: LG Order for LG-REF-0411
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier'),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND status = 1 AND ROWNUM = 1),
    SYSDATE + 7, 1
);

-- ORD3: Walton Order for WAL-TV-0512
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division'),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND status = 1 AND ROWNUM = 1),
    SYSDATE + 3, 1
);

-- ORD4: Samsung Order for SAM-WASH-0815
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor'),
    (SELECT employee_id FROM employees WHERE first_name = 'Keya' AND last_name = 'Payel' AND status = 1 AND ROWNUM = 1),
    SYSDATE + 10, 1
);

-- ORD5: Asian Order for DEL-LAT-0310
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House'),
    (SELECT employee_id FROM employees WHERE first_name = 'Tariq' AND last_name = 'Aziz' AND status = 1 AND ROWNUM = 1),
    SYSDATE + 4, 1
);

-- ORD6: Global Electronics Order for PAN-MIC-0714
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Global Electronics Importer'),
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND status = 1 AND ROWNUM = 1),
    SYSDATE + 6, 1
);

-- ORD7: Jamuna Order for HIT-GEN-0916
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier'),
    (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND status = 1 AND ROWNUM = 1),
    SYSDATE + 8, 1
);

-- ORD8: Minister Order for MIN-AC-0613
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier'),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND status = 1 AND ROWNUM = 1),
    SYSDATE + 2, 1
);

-- ORD9: City Electronics Order for IPH-15-029
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier'),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND status = 1 AND ROWNUM = 1),
    SYSDATE + 9, 1
);

-- ORD10: LG Order for LG-HOM-1017
INSERT INTO product_order_master (supplier_id, order_by, expected_delivery_date, status)
VALUES (
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier'),
    (SELECT employee_id FROM employees WHERE first_name = 'Rezaul' AND last_name = 'Karim' AND status = 1 AND ROWNUM = 1),
    SYSDATE + 12, 1
);

COMMIT;


--------------------------------------------------------------------------------
-- 26. PRODUCT_ORDER_DETAIL
-- Each order has exactly ONE product for clean receive mapping
--------------------------------------------------------------------------------

-- ORD1 Detail: Samsung Galaxy S24
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES ('ORD1',
    (SELECT product_id FROM products WHERE product_code = 'SAM-S24-018'),
    95000, 82000, 10
);

-- ORD2 Detail: LG Refrigerator
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES ('ORD2',
    (SELECT product_id FROM products WHERE product_code = 'LG-REF-0411'),
    75000, 65000, 5
);

-- ORD3 Detail: Walton LED TV
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES ('ORD3',
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512'),
    35000, 28000, 15
);

-- ORD4 Detail: Samsung Washing Machine
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES ('ORD4',
    (SELECT product_id FROM products WHERE product_code = 'SAM-WASH-0815'),
    55000, 48000, 8
);

-- ORD5 Detail: Dell Laptop
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES ('ORD5',
    (SELECT product_id FROM products WHERE product_code = 'DEL-LAT-0310'),
    85000, 75000, 12
);

-- ORD6 Detail: Panasonic Microwave
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES ('ORD6',
    (SELECT product_id FROM products WHERE product_code = 'PAN-MIC-0714'),
    18000, 15000, 10
);

-- ORD7 Detail: Hitachi Generator
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES ('ORD7',
    (SELECT product_id FROM products WHERE product_code = 'HIT-GEN-0916'),
    120000, 105000, 3
);

-- ORD8 Detail: Midea AC
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES ('ORD8',
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613'),
    48000, 42000, 10
);

-- ORD9 Detail: iPhone 15
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES ('ORD9',
    (SELECT product_id FROM products WHERE product_code = 'IPH-15-029'),
    145000, 130000, 7
);

-- ORD10 Detail: LG Home Theater
INSERT INTO product_order_detail (order_id, product_id, mrp, purchase_price, quantity)
VALUES ('ORD10',
    (SELECT product_id FROM products WHERE product_code = 'LG-HOM-1017'),
    25000, 21000, 20
);

COMMIT;


--------------------------------------------------------------------------------
-- 19. PRODUCT_RECEIVE_MASTER
-- REMOVED: Product receive data has been commented out
-- Keeping product_order_master only (no transaction data)
--------------------------------------------------------------------------------

/*
-- RCV1-RCV10 inserts removed
*/

COMMIT;

--------------------------------------------------------------------------------
-- 20. PRODUCT_RETURN_MASTER
-- REMOVED: Product return data has been commented out
-- Keeping product_order_master only (no transaction data)
--------------------------------------------------------------------------------

/*
-- RTN1-RTN10 inserts removed
*/

COMMIT;

--------------------------------------------------------------------------------
-- 27. PRODUCT_RECEIVE_DETAILS
-- REMOVED: Product receive details data has been commented out
-- Keeping product_order_master only (no transaction data)
--------------------------------------------------------------------------------

/*
-- Receive detail inserts removed
*/

COMMIT;

--------------------------------------------------------------------------------
-- 26A. STOCK (Master Data Only - Independent of Transactions)
-- IMPORTANT: stock table enforces UNIQUE constraint on product_id
-- Stock values are independent, not calculated from transactions
--------------------------------------------------------------------------------
DELETE FROM stock;

-- Samsung S24
INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'SAM-S24-018' AND status = 1 AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND status = 1 AND ROWNUM = 1),
    50
);

-- LG Refrigerator
INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'LG-REF-0411' AND status = 1 AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND status = 1 AND ROWNUM = 1),
    30
);

-- Walton TV
INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND status = 1 AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Walton Spare Parts Division' AND status = 1 AND ROWNUM = 1),
    25
);

-- Samsung Washer
INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'SAM-WASH-0815' AND status = 1 AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Samsung Authorized Distributor' AND status = 1 AND ROWNUM = 1),
    20
);

-- Dell Laptop
INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'DEL-LAT-0310' AND status = 1 AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Asian Spare Parts House' AND status = 1 AND ROWNUM = 1),
    15
);

-- LG Home Theater
INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'LG-HOM-1017' AND status = 1 AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'LG Electronics Supplier' AND status = 1 AND ROWNUM = 1),
    40
);

-- Hitachi Generator
INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'HIT-GEN-0916' AND status = 1 AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Jamuna Electronics Supplier' AND status = 1 AND ROWNUM = 1),
    10
);

-- Midea AC
INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613' AND status = 1 AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Minister Hi-Tech Supplier' AND status = 1 AND ROWNUM = 1),
    35
);

-- iPhone 15 Pro
INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'IPH-15-029' AND status = 1 AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'City Electronics Parts Supplier' AND status = 1 AND ROWNUM = 1),
    22
);

-- Panasonic Microwave
INSERT INTO stock (product_id, supplier_id, quantity)
VALUES (
    (SELECT product_id FROM products WHERE product_code = 'PAN-MIC-0714' AND status = 1 AND ROWNUM = 1),
    (SELECT supplier_id FROM suppliers WHERE supplier_name = 'Global Electronics Importer' AND status = 1 AND ROWNUM = 1),
    18
);

COMMIT;


--------------------------------------------------------------------------------
-- 28. PRODUCT_RETURN_DETAILS
-- REMOVED: Product return details data has been commented out
-- Keeping product_order_master only (no transaction data)
--------------------------------------------------------------------------------

/*
-- Return detail inserts removed
*/

COMMIT;

--------------------------------------------------------------------------------
-- ADDITIONAL DATA: SALES, SERVICE, AND OPERATIONAL RECORDS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 31. SALES_MASTER (Customer Sales Invoices)
--------------------------------------------------------------------------------

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000001' AND status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Rafiqul' AND last_name = 'Hasan' AND status = 1 AND ROWNUM = 1),
    SYSDATE - 20,
    2000
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000002' AND status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND status = 1 AND ROWNUM = 1),
    SYSDATE - 30,
    3000
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000003' AND status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND status = 1 AND ROWNUM = 1),
    SYSDATE - 750,
    1500
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000004' AND status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND status = 1 AND ROWNUM = 1),
    SYSDATE - 740,
    5000
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000005' AND status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Tariq' AND last_name = 'Aziz' AND status = 1 AND ROWNUM = 1),
    SYSDATE - 60,
    2500
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000006' AND status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Rumana' AND last_name = 'Afroz' AND status = 1 AND ROWNUM = 1),
    SYSDATE - 100,
    1000
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000007' AND status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND status = 1 AND ROWNUM = 1),
    SYSDATE - 50,
    3000
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000008' AND status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Rafiqul' AND last_name = 'Hasan' AND status = 1 AND ROWNUM = 1),
    SYSDATE - 380,
    2000
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000009' AND status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND status = 1 AND ROWNUM = 1),
    SYSDATE - 90,
    500
);

INSERT INTO sales_master (customer_id, sales_by, invoice_date, discount)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_no = '01810000010' AND status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND status = 1 AND ROWNUM = 1),
    SYSDATE - 400,
    8000
);

COMMIT;


--------------------------------------------------------------------------------
-- 32. SALES_DETAIL (Sales Line Items)
--------------------------------------------------------------------------------

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000001' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND status = 1 AND ROWNUM = 1),
    1, 35000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000002' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613' AND status = 1 AND ROWNUM = 1),
    1, 48000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000003' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-REF-0411' AND status = 1 AND ROWNUM = 1),
    1, 75000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000004' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'SAM-WASH-0815' AND status = 1 AND ROWNUM = 1),
    1, 55000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000005' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'DEL-LAT-0310' AND status = 1 AND ROWNUM = 1),
    1, 85000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000006' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND status = 1 AND ROWNUM = 1),
    1, 35000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000007' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'MIN-AC-0613' AND status = 1 AND ROWNUM = 1),
    1, 48000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000008' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'PAN-MIC-0714' AND status = 1 AND ROWNUM = 1),
    1, 18000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000009' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'IPH-15-029' AND status = 1 AND ROWNUM = 1),
    1, 145000
);

INSERT INTO sales_detail (invoice_id, product_id, quantity, mrp)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000010' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
    (SELECT product_id FROM products WHERE product_code = 'LG-HOM-1017' AND status = 1 AND ROWNUM = 1),
    1, 25000
);

COMMIT;


--------------------------------------------------------------------------------
-- 33. SALES_RETURN_MASTER (Returns from Customers)
--------------------------------------------------------------------------------

INSERT INTO sales_return_master (invoice_id, return_date)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000001' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
    SYSDATE - 5
);

INSERT INTO sales_return_master (invoice_id, return_date)
VALUES (
    (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000009' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
    SYSDATE
);

COMMIT;


--------------------------------------------------------------------------------
-- 34. SERVICE_MASTER (Service Requests)
--------------------------------------------------------------------------------

-- Service 1: TV Repair Service with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    -- Insert master record
    INSERT INTO service_master (customer_id, invoice_id, service_date, service_by, service_charge_total, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000001' AND status = 1 AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000001' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        SYSDATE - 5,
        (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND status = 1 AND ROWNUM = 1),
        2500, 900, 6900, 'Y'
    )
    RETURNING service_id INTO v_service_id;
    
    -- Insert detail records
    INSERT INTO service_details (service_id, product_id, servicelist_id, parts_id, quantity, service_charge, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND status = 1 AND ROWNUM = 1),
        (SELECT servicelist_id FROM service_list WHERE service_name = 'TV Repair Service' AND status = 1 AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'LED TV Motherboard' AND status = 1 AND ROWNUM = 1), 
        1, 1250, 2000, 3250, 'Y', 
        'Replaced defective LED TV motherboard due to power surge damage'
    );
    
    INSERT INTO service_details (service_id, product_id, servicelist_id, parts_id, quantity, service_charge, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND status = 1 AND ROWNUM = 1),
        (SELECT servicelist_id FROM service_list WHERE service_name = 'TV Repair Service' AND status = 1 AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'LED TV Display Panel' AND status = 1 AND ROWNUM = 1), 
        1, 1250, 1500, 2750, 'Y', 
        'Replaced cracked display panel after physical impact'
    );
    
    COMMIT;
END;
/

-- Service 2: AC Servicing with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    -- Insert master record
    INSERT INTO service_master (customer_id, invoice_id, service_date, service_by, service_charge_total, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000002' AND status = 1 AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000002' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        SYSDATE - 3,
        (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND status = 1 AND ROWNUM = 1),
        1800, 600, 4600, 'N'
    )
    RETURNING service_id INTO v_service_id;
    
    -- Insert detail records
    INSERT INTO service_details (service_id, product_id, servicelist_id, parts_id, quantity, service_charge, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT d.product_id FROM sales_detail d
         JOIN sales_master m ON d.invoice_id = m.invoice_id AND m.status = 1 
         JOIN products p ON d.product_id = p.product_id AND p.status = 1
         JOIN product_categories pc ON p.category_id = pc.product_cat_id AND pc.status = 1
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000002' AND status = 1 AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Air Conditioner%' AND ROWNUM = 1),
        (SELECT servicelist_id FROM service_list WHERE service_name = 'AC Servicing' AND status = 1 AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'AC Outdoor Fan Motor' AND status = 1 AND ROWNUM = 1), 
        1, 900, 1200, 2100, 'N', 
        'Replaced outdoor fan motor - warranty void due to improper installation by unauthorized technician'
    );
    
    INSERT INTO service_details (service_id, product_id, servicelist_id, parts_id, quantity, service_charge, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT d.product_id FROM sales_detail d
         JOIN sales_master m ON d.invoice_id = m.invoice_id AND m.status = 1 
         JOIN products p ON d.product_id = p.product_id AND p.status = 1
         JOIN product_categories pc ON p.category_id = pc.product_cat_id AND pc.status = 1
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000002' AND status = 1 AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Air Conditioner%' AND ROWNUM = 1),
        (SELECT servicelist_id FROM service_list WHERE service_name = 'AC Servicing' AND status = 1 AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'AC Remote Controller' AND status = 1 AND ROWNUM = 1), 
        1, 900, 1000, 1900, 'N', 
        'Remote replacement not covered - physical damage due to customer mishandling'
    );
    
    COMMIT;
END;
/

-- Service 3: Refrigerator Repair with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, service_by, service_charge_total, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000003' AND status = 1 AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000003' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        SYSDATE - 2,
        (SELECT employee_id FROM employees WHERE first_name = 'Keya' AND last_name = 'Payel' AND status = 1 AND ROWNUM = 1),
        2200, 1005, 7705, 'N'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT d.product_id FROM sales_detail d
         JOIN sales_master m ON d.invoice_id = m.invoice_id AND m.status = 1 
         JOIN products p ON d.product_id = p.product_id AND p.status = 1
         JOIN product_categories pc ON p.category_id = pc.product_cat_id AND pc.status = 1
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000003' AND status = 1 AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Refrigerator%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'Refrigerator Compressor Unit' AND status = 1 AND ROWNUM = 1), 
        1, 3000, 3000, 'N', 
        'Replaced faulty compressor unit - refrigerator not cooling properly'
    );
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT d.product_id FROM sales_detail d
         JOIN sales_master m ON d.invoice_id = m.invoice_id AND m.status = 1 
         JOIN products p ON d.product_id = p.product_id AND p.status = 1
         JOIN product_categories pc ON p.category_id = pc.product_cat_id AND pc.status = 1
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000003' AND status = 1 AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Refrigerator%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'Refrigerator Thermostat' AND status = 1 AND ROWNUM = 1), 
        1, 1500, 1500, 'N', 
        'Replaced malfunctioning thermostat for better temperature control'
    );
    
    COMMIT;
END;
/

-- Service 4: Washing Machine Repair with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, service_by, service_charge_total, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000004' AND status = 1 AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000004' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        SYSDATE - 1,
        (SELECT employee_id FROM employees WHERE first_name = 'Imtiaz' AND last_name = 'Bulbul' AND status = 1 AND ROWNUM = 1),
        1500, 495, 3795, 'N'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT d.product_id FROM sales_detail d
         JOIN sales_master m ON d.invoice_id = m.invoice_id AND m.status = 1 
         JOIN products p ON d.product_id = p.product_id AND p.status = 1
         JOIN product_categories pc ON p.category_id = pc.product_cat_id AND pc.status = 1
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000004' AND status = 1 AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Washing Machine%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'Washing Machine Drum Belt' AND status = 1 AND ROWNUM = 1), 
        1, 1800, 1800, 'N', 
        'Replaced worn-out drum belt - machine drum was not spinning'
    );
    
    COMMIT;
END;
/

-- Service 5: Laptop/Computer Repair with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, service_by, service_charge_total, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000005' AND status = 1 AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000005' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        SYSDATE - 4,
        (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND status = 1 AND ROWNUM = 1),
        3000, 825, 6325, 'N'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT d.product_id FROM sales_detail d
         JOIN sales_master m ON d.invoice_id = m.invoice_id AND m.status = 1 
         JOIN products p ON d.product_id = p.product_id AND p.status = 1
         JOIN product_categories pc ON p.category_id = pc.product_cat_id AND pc.status = 1
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000005' AND status = 1 AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Laptop%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'Laptop Charger Adapter' AND status = 1 AND ROWNUM = 1), 
        1, 1500, 1500, 'N', 
        'Charger damage not covered - warranty void due to liquid spill damage'
    );
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT d.product_id FROM sales_detail d
         JOIN sales_master m ON d.invoice_id = m.invoice_id AND m.status = 1 
         JOIN products p ON d.product_id = p.product_id AND p.status = 1
         JOIN product_categories pc ON p.category_id = pc.product_cat_id AND pc.status = 1
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000005' AND status = 1 AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Laptop%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'LED TV Power Supply Board' AND status = 1 AND ROWNUM = 1), 
        1, 1000, 1000, 'N', 
        'Power supply failure caused by liquid damage - warranty not applicable'
    );
    
    COMMIT;
END;
/

-- Service 6: TV Installation with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, service_by, service_charge_total, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000006' AND status = 1 AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000006' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        SYSDATE - 10,
        (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND status = 1 AND ROWNUM = 1),
        1200, 405, 3105, 'Y'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT product_id FROM products WHERE product_code = 'WAL-TV-0512' AND status = 1 AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'LED TV Display Panel' AND status = 1 AND ROWNUM = 1), 
        1, 1500, 1500, 'Y', 
        'TV wall mount installation with display panel setup and cable management'
    );
    
    COMMIT;
END;
/

-- Service 7: AC Installation with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, service_by, service_charge_total, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000007' AND status = 1 AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000007' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        SYSDATE - 8,
        (SELECT employee_id FROM employees WHERE first_name = 'Keya' AND last_name = 'Payel' AND status = 1 AND ROWNUM = 1),
        2500, 675, 5175, 'Y'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT d.product_id FROM sales_detail d
         JOIN sales_master m ON d.invoice_id = m.invoice_id AND m.status = 1 
         JOIN products p ON d.product_id = p.product_id AND p.status = 1
         JOIN product_categories pc ON p.category_id = pc.product_cat_id AND pc.status = 1
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000007' AND status = 1 AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Air Conditioner%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'AC Outdoor Fan Motor' AND status = 1 AND ROWNUM = 1), 
        2, 1000, 2000, 'Y', 
        'Complete AC installation with outdoor unit setup and dual fan motor installation'
    );
    
    COMMIT;
END;
/

-- Service 8: Microwave Oven Repair with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, service_by, service_charge_total, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000008' AND status = 1 AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000008' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        SYSDATE - 6,
        (SELECT employee_id FROM employees WHERE first_name = 'Imtiaz' AND last_name = 'Bulbul' AND status = 1 AND ROWNUM = 1),
        1200, 600, 4600, 'N'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT d.product_id FROM sales_detail d
         JOIN sales_master m ON d.invoice_id = m.invoice_id AND m.status = 1 
         JOIN products p ON d.product_id = p.product_id AND p.status = 1
         JOIN product_categories pc ON p.category_id = pc.product_cat_id AND pc.status = 1
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000008' AND status = 1 AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Microwave%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'Microwave Oven Magnetron Tube' AND status = 1 AND ROWNUM = 1), 
        1, 2800, 2800, 'N', 
        'Replaced burnt magnetron tube - microwave not heating food properly'
    );
    
    COMMIT;
END;
/

-- Service 9: Mobile Service and Repair with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, service_by, service_charge_total, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000009' AND status = 1 AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000009' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        SYSDATE - 7,
        (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND status = 1 AND ROWNUM = 1),
        2200, 555, 4255, 'Y'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT d.product_id FROM sales_detail d
         JOIN sales_master m ON d.invoice_id = m.invoice_id AND m.status = 1 
         JOIN products p ON d.product_id = p.product_id AND p.status = 1
         JOIN product_categories pc ON p.category_id = pc.product_cat_id AND pc.status = 1
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000009' AND status = 1 AND ROWNUM = 1)
         AND pc.product_cat_name LIKE '%Phone%' AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'Laptop Charger Adapter' AND status = 1 AND ROWNUM = 1), 
        1, 1500, 1500, 'Y', 
        'Mobile phone charging port repair and compatible charger replacement'
    );
    
    COMMIT;
END;
/

-- Service 10: Home Appliance Diagnosis with Details (Integrated)
DECLARE
    v_service_id VARCHAR2(50);
BEGIN
    INSERT INTO service_master (customer_id, invoice_id, service_date, service_by, service_charge_total, vat, grand_total, warranty_applicable)
    VALUES (
        (SELECT customer_id FROM customers WHERE phone_no = '01810000010' AND status = 1 AND ROWNUM = 1),
        (SELECT invoice_id FROM sales_master WHERE customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000010' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        SYSDATE - 9,
        (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND status = 1 AND ROWNUM = 1),
        800, 300, 2300, 'N'
    )
    RETURNING service_id INTO v_service_id;
    
    INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
    VALUES (
        v_service_id, 
        (SELECT d.product_id FROM sales_detail d
         JOIN sales_master m ON d.invoice_id = m.invoice_id AND m.status = 1 
         JOIN products p ON d.product_id = p.product_id AND p.status = 1
         WHERE m.customer_id = (SELECT customer_id FROM customers WHERE phone_no = '01810000010' AND status = 1 AND ROWNUM = 1)
         AND ROWNUM = 1),
        (SELECT parts_id FROM parts WHERE parts_name = 'LED TV Motherboard' AND status = 1 AND ROWNUM = 1), 
        1, 1200, 1200, 'N', 
        'Complete diagnostic testing and motherboard inspection for home theater system'
    );
    
    COMMIT;
END;
/


--------------------------------------------------------------------------------
-- 35. DAMAGE (Damaged Goods) - No seed data; use triggers for actual transactions
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- 36. EXPENSE_MASTER (Business Expenses)
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- 37. PAYMENTS (Supplier Payments)
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- 38. COM_USERS (Application Users)
--------------------------------------------------------------------------------

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'rafiqul.admin',
    'admin@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Rafiqul' AND last_name = 'Hasan' AND status = 1 AND ROWNUM = 1),
    'ADMIN'
);

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'ariful.sales',
    'sales@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Ariful' AND last_name = 'Islam' AND status = 1 AND ROWNUM = 1),
    'SALES_MANAGER'
);

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'fatima.accounts',
    'account@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Fatima' AND last_name = 'Zohra' AND status = 1 AND ROWNUM = 1),
    'ACCOUNTANT'
);

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'zahid.procurement',
    'purchase@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Zahid' AND last_name = 'Hasib' AND status = 1 AND ROWNUM = 1),
    'PROCUREMENT'
);

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'mominul.service',
    'service@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Mominul' AND last_name = 'Haque' AND status = 1 AND ROWNUM = 1),
    'SERVICE_TECH'
);

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'tariq.sales',
    'sales@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Tariq' AND last_name = 'Aziz' AND status = 1 AND ROWNUM = 1),
    'SALES_EXECUTIVE'
);

INSERT INTO com_users (user_name, password, employee_id, role)
VALUES (
    'rumana.support',
    'support@2026',
    (SELECT employee_id FROM employees WHERE first_name = 'Rumana' AND last_name = 'Afroz' AND status = 1 AND ROWNUM = 1),
    'CUSTOMER_SUPPORT'
);

COMMIT;


--------------------------------------------------------------------------------
-- 39. SALES_RETURN_DETAILS - No seed data; use triggers for actual return transactions
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- 40. SERVICE_DETAILS (Integrated with SERVICE_MASTER above)
--------------------------------------------------------------------------------
-- Note: Service details are now integrated with their master records in PL/SQL blocks above
-- This eliminates the need for separate INSERT statements and ensures proper FK relationships


--------------------------------------------------------------------------------
-- 41. EXPENSE_DETAILS (Expense Line Items)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 42. DAMAGE_DETAIL - No seed data; use triggers for actual damage transactions
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE UPDATE_STOCK_QTY (
    p_product_id IN VARCHAR2,
    p_quantity   IN NUMBER
) IS
    v_count NUMBER;
    v_supplier_id VARCHAR2(50);
    v_cat_id VARCHAR2(50);
    v_sub_cat_id VARCHAR2(50);
BEGIN
    -- ১. চেক করা প্রোডাক্টটি স্টকে আছে কিনা
    SELECT COUNT(*) INTO v_count FROM stock WHERE product_id = p_product_id;

    IF v_count > 0 THEN
        -- ২. যদি থাকে, তাহলে কোয়ান্টিটি আপডেট করো
        UPDATE stock
        SET quantity = quantity + p_quantity,
            last_update = SYSTIMESTAMP
        WHERE product_id = p_product_id;
    ELSE
        -- ৩. যদি না থাকে এবং কোয়ান্টিটি পজিটিভ হয়, তাহলে ইনসার্ট করো
        IF p_quantity > 0 THEN
            BEGIN
                SELECT supplier_id, category_id, sub_cat_id
                INTO v_supplier_id, v_cat_id, v_sub_cat_id
                FROM products
                WHERE product_id = p_product_id;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                v_supplier_id := NULL; v_cat_id := NULL; v_sub_cat_id := NULL;
            END;

            INSERT INTO stock (product_id, supplier_id, product_cat_id, sub_cat_id, quantity)
            VALUES (p_product_id, v_supplier_id, v_cat_id, v_sub_cat_id, p_quantity);
        ELSE
             -- স্টক নেই কিন্তু নেগেটিভ করতে চাইলে এরর (অপশনাল)
             NULL; 
        END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_auto_stock_receive
AFTER INSERT OR UPDATE OR DELETE ON product_receive_details
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE_STOCK_QTY(:NEW.product_id, :NEW.receive_quantity);
    ELSIF DELETING THEN
        UPDATE_STOCK_QTY(:OLD.product_id, -:OLD.receive_quantity);
    ELSIF UPDATING THEN
        -- যদি প্রোডাক্ট চেইঞ্জ হয়
        IF :OLD.product_id != :NEW.product_id THEN
            UPDATE_STOCK_QTY(:OLD.product_id, -:OLD.receive_quantity);
            UPDATE_STOCK_QTY(:NEW.product_id, :NEW.receive_quantity);
        ELSE
            UPDATE_STOCK_QTY(:NEW.product_id, :NEW.receive_quantity - :OLD.receive_quantity);
        END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_auto_stock_sales
AFTER INSERT OR UPDATE OR DELETE ON sales_detail
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE_STOCK_QTY(:NEW.product_id, -:NEW.quantity);
    ELSIF DELETING THEN
        UPDATE_STOCK_QTY(:OLD.product_id, :OLD.quantity); -- ডিলিট হলে স্টক ফেরত আসবে
    ELSIF UPDATING THEN
        IF :OLD.product_id != :NEW.product_id THEN
            UPDATE_STOCK_QTY(:OLD.product_id, :OLD.quantity);
            UPDATE_STOCK_QTY(:NEW.product_id, -:NEW.quantity);
        ELSE
            -- (New - Old) * -1 কারণ বাড়লে স্টক কমবে
            UPDATE_STOCK_QTY(:NEW.product_id, -(:NEW.quantity - :OLD.quantity));
        END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_auto_stock_sales_return
AFTER INSERT OR UPDATE OR DELETE ON sales_return_details
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE_STOCK_QTY(:NEW.product_id, :NEW.quantity);
    ELSIF DELETING THEN
        UPDATE_STOCK_QTY(:OLD.product_id, -:OLD.quantity);
    ELSIF UPDATING THEN
        IF :OLD.product_id != :NEW.product_id THEN
            UPDATE_STOCK_QTY(:OLD.product_id, -:OLD.quantity);
            UPDATE_STOCK_QTY(:NEW.product_id, :NEW.quantity);
        ELSE
            UPDATE_STOCK_QTY(:NEW.product_id, :NEW.quantity - :OLD.quantity);
        END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_auto_stock_purchase_return
AFTER INSERT OR UPDATE OR DELETE ON product_return_details
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE_STOCK_QTY(:NEW.product_id, -:NEW.return_quantity);
    ELSIF DELETING THEN
        UPDATE_STOCK_QTY(:OLD.product_id, :OLD.return_quantity);
    ELSIF UPDATING THEN
        IF :OLD.product_id != :NEW.product_id THEN
            UPDATE_STOCK_QTY(:OLD.product_id, :OLD.return_quantity);
            UPDATE_STOCK_QTY(:NEW.product_id, -:NEW.return_quantity);
        ELSE
            UPDATE_STOCK_QTY(:NEW.product_id, -(:NEW.return_quantity - :OLD.return_quantity));
        END IF;
    END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_auto_stock_damage
AFTER INSERT OR UPDATE OR DELETE ON damage_detail
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE_STOCK_QTY(:NEW.product_id, -:NEW.damage_quantity);
    ELSIF DELETING THEN
        UPDATE_STOCK_QTY(:OLD.product_id, :OLD.damage_quantity);
    ELSIF UPDATING THEN
        IF :OLD.product_id != :NEW.product_id THEN
            UPDATE_STOCK_QTY(:OLD.product_id, :OLD.damage_quantity);
            UPDATE_STOCK_QTY(:NEW.product_id, -:NEW.damage_quantity);
        ELSE
            UPDATE_STOCK_QTY(:NEW.product_id, -(:NEW.damage_quantity - :OLD.damage_quantity));
        END IF;
    END IF;
END;
/
/* 
IF NEEDED THEN......
BEGIN
    -- ১. স্টক টেবিল ক্লিয়ার করা
    DELETE FROM stock;
    
    -- ২. ম্যানুয়াল ইনিশিয়াল স্টক ইনসার্ট করা (যদি রিসিভ ডিটেইলস না থাকে)
    -- তোমার স্ক্রিপ্টের ম্যানুয়াল স্টক ইনসার্টগুলো এখানে রাখতে পারো, 
    -- অথবা প্রোডাক্ট রিসিভ টেবিল থেকে অটোমেটিক আনতে পারো।
    
    -- উদাহরণ: রিসিভ থেকে স্টক জেনারেট করা
    FOR r IN (SELECT product_id, SUM(receive_quantity) as qty FROM product_receive_details GROUP BY product_id) LOOP
        UPDATE_STOCK_QTY(r.product_id, r.qty);
    END LOOP;

    -- ৩. সেলস থেকে স্টক মাইনাস করা
    FOR s IN (SELECT product_id, SUM(quantity) as qty FROM sales_detail GROUP BY product_id) LOOP
        UPDATE_STOCK_QTY(s.product_id, -s.qty);
    END LOOP;
*/

--change sales_return
CREATE OR REPLACE TRIGGER trg_auto_stock_sales_return
AFTER INSERT OR UPDATE OR DELETE ON sales_return_details
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        -- ভুল ছিল: :NEW.quantity (এটা ইনভয়েস কোয়ান্টিটি ৪)
        -- সঠিক হবে: :NEW.qty_return (এটা রিটার্ন কোয়ান্টিটি ২)
        UPDATE_STOCK_QTY(:NEW.product_id, NVL(:NEW.qty_return, 0));
        
    ELSIF DELETING THEN
        UPDATE_STOCK_QTY(:OLD.product_id, -NVL(:OLD.qty_return, 0));
        
    ELSIF UPDATING THEN
        IF :OLD.product_id != :NEW.product_id THEN
            UPDATE_STOCK_QTY(:OLD.product_id, -NVL(:OLD.qty_return, 0));
            UPDATE_STOCK_QTY(:NEW.product_id, NVL(:NEW.qty_return, 0));
        ELSE
            UPDATE_STOCK_QTY(:NEW.product_id, NVL(:NEW.qty_return, 0) - NVL(:OLD.qty_return, 0));
        END IF;
    END IF;
END;
/
-- change purchase_return trigger 
CREATE OR REPLACE TRIGGER trg_auto_stock_purchase_return
AFTER INSERT OR UPDATE OR DELETE ON product_return_details
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        -- NVL(:NEW.return_quantity, 0) ব্যবহার করা হয়েছে যাতে খালি থাকলে ০ ধরে নেয়
        UPDATE_STOCK_QTY(:NEW.product_id, -NVL(:NEW.return_quantity, 0));
    ELSIF DELETING THEN
        UPDATE_STOCK_QTY(:OLD.product_id, NVL(:OLD.return_quantity, 0));
    ELSIF UPDATING THEN
        IF :OLD.product_id != :NEW.product_id THEN
            UPDATE_STOCK_QTY(:OLD.product_id, NVL(:OLD.return_quantity, 0));
            UPDATE_STOCK_QTY(:NEW.product_id, -NVL(:NEW.return_quantity, 0));
        ELSE
            UPDATE_STOCK_QTY(:NEW.product_id, -(NVL(:NEW.return_quantity, 0) - NVL(:OLD.return_quantity, 0)));
        END IF;
    END IF;
END;
/


    
    -- ৪. রিটার্ন এবং ড্যামেজ একইভাবে হ্যান্ডেল করতে হবে...
    COMMIT;
-- ================================================================================
-- Comprehensive Insert Data for Oxen Company Limited Database
-- Purpose: Add balanced sample data for all 33 tables with perfect FK alignment
-- Pattern: Follows master-detail transaction patterns with dynamic FK lookups
-- Status Filter: All lookups include "status = 1 AND ROWNUM = 1" for safety
-- ================================================================================

-- ============================================================================
-- SECTION 1: MASTER DATA EXPANSION
-- ============================================================================

-- ------------------------------------------------
-- 1.1 Additional Customers (15 new records)
-- ------------------------------------------------
PROMPT Inserting additional customers...

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Rahman Electronics', '01712345678', 'rahman@example.com', 'House 25, Road 5, Mirpur-1, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Karim Trading', '01812345679', 'karim@example.com', 'Shop 15, New Market, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Akter Stores', '01912345680', 'akter@example.com', 'House 42, Dhanmondi-15, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Hossain Electronics', '01612345681', 'hossain@example.com', 'Plot 8, Uttara Sector-4, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Begum Traders', '01712345682', 'begum@example.com', 'House 12, Mohammadpur, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Ali Enterprise', '01812345683', 'ali@example.com', 'Shop 22, Gulshan-2, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Sultana Electronics', '01912345684', 'sultana@example.com', 'House 67, Banani, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Ahmed Trading Co', '01612345685', 'ahmed@example.com', 'Plot 15, Bashundhara R/A, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Nasrin Stores', '01712345686', 'nasrin@example.com', 'House 88, Lalmatia, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Kabir Electronics Hub', '01812345687', 'kabir@example.com', 'Shop 5, Farmgate, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Siddique Traders', '01912345688', 'siddique@example.com', 'House 33, Mirpur-10, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Fatema Electronics', '01612345689', 'fatema@example.com', 'Plot 42, Uttara Sector-7, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Mia Trading House', '01712345690', 'mia@example.com', 'House 19, Dhanmondi-32, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Chowdhury Electronics', '01812345691', 'chowdhury@example.com', 'Shop 8, Elephant Road, Dhaka');

INSERT INTO customers (customer_name, phone_no, email, address)
VALUES ('Begum Trading Co', '01912345692', 'begumtrading@example.com', 'House 55, Mohakhali DOHS, Dhaka');

-- ------------------------------------------------
-- 1.2 Additional Suppliers (8 new records)
-- ------------------------------------------------
PROMPT Inserting additional suppliers...

INSERT INTO suppliers (supplier_name, phone_no, email, address)
VALUES ('Vision Electronics BD', '01712340001', 'vision@supplier.com', 'Plot 22, Tejgaon I/A, Dhaka');

INSERT INTO suppliers (supplier_name, phone_no, email, address)
VALUES ('Minister Trading', '01812340002', 'minister@supplier.com', 'House 88, Uttara Sector-10, Dhaka');

INSERT INTO suppliers (supplier_name, phone_no, email, address)
VALUES ('Sharp Electronics Importer', '01912340003', 'sharp@supplier.com', 'Shop 12, Banglamotor, Dhaka');

INSERT INTO suppliers (supplier_name, phone_no, email, address)
VALUES ('Hitachi Distributor BD', '01612340004', 'hitachi@supplier.com', 'Plot 5, Mohakhali C/A, Dhaka');

INSERT INTO suppliers (supplier_name, phone_no, email, address)
VALUES ('Sony Bangladesh', '01712340005', 'sony@supplier.com', 'House 77, Banani-11, Dhaka');

INSERT INTO suppliers (supplier_name, phone_no, email, address)
VALUES ('Panasonic Parts Supplier', '01812340006', 'panasonic@supplier.com', 'Shop 33, Kawran Bazar, Dhaka');

INSERT INTO suppliers (supplier_name, phone_no, email, address)
VALUES ('Toshiba Electronics BD', '01912340007', 'toshiba@supplier.com', 'Plot 15, Gulshan-1, Dhaka');

INSERT INTO suppliers (supplier_name, phone_no, email, address)
VALUES ('Haier Appliances Distributor', '01612340008', 'haier@supplier.com', 'House 42, Mirpur-2, Dhaka');

-- ------------------------------------------------
-- 1.3 Additional Products (20 new records)
-- ------------------------------------------------
PROMPT Inserting additional products...

-- Refrigerators
INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Vision Refrigerator 12 CFT', 'VIS-REF-12',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Refrigerator' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Non-Frost Refrigerator' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Vision' AND status = 1 AND ROWNUM = 1),
    28000, 12);

INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Minister Refrigerator 15 CFT', 'MIN-REF-15',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Minister%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Refrigerator' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Frost Refrigerator' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Minister' AND status = 1 AND ROWNUM = 1),
    35000, 12);

-- Air Conditioners
INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Sharp AC 1.5 Ton Split', 'SHA-AC-1.5',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Air Conditioner' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Split AC' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Sharp' AND status = 1 AND ROWNUM = 1),
    38000, 12);

INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Hitachi AC 2 Ton Inverter', 'HIT-AC-2.0',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Hitachi%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Air Conditioner' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Inverter AC' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Hitachi' AND status = 1 AND ROWNUM = 1),
    55000, 12);

-- LED Televisions
INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Sony 43 inch Smart LED TV', 'SON-LED-43',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sony%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'LED Television' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Smart LED TV' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Sony' AND status = 1 AND ROWNUM = 1),
    42000, 12);

INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Sharp 32 inch HD LED TV', 'SHA-LED-32',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'LED Television' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'HD LED TV' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Sharp' AND status = 1 AND ROWNUM = 1),
    18000, 12);

-- Washing Machines
INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('LG 7kg Front Load Washing Machine', 'LG-WM-7F',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%LG%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Washing Machine' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Front Load Washing Machine' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'LG' AND status = 1 AND ROWNUM = 1),
    32000, 12);

INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Samsung 8kg Top Load Washing Machine', 'SAM-WM-8T',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Washing Machine' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Top Load Washing Machine' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Samsung' AND status = 1 AND ROWNUM = 1),
    28000, 12);

-- Microwave Ovens
INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Panasonic 23L Microwave Oven', 'PAN-MW-23',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Microwave Oven' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Solo Microwave' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Panasonic' AND status = 1 AND ROWNUM = 1),
    8500, 12);

INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Sharp 25L Convection Microwave', 'SHA-MW-25',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Microwave Oven' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Convection Microwave' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Sharp' AND status = 1 AND ROWNUM = 1),
    12000, 12);

-- Fans
INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Walton Ceiling Fan 56 inch', 'WAL-FAN-56',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Walton%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Fan' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Ceiling Fan' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Walton' AND status = 1 AND ROWNUM = 1),
    2200, 12);

INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Vision Table Fan 16 inch', 'VIS-FAN-16',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Fan' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Table Fan' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Vision' AND status = 1 AND ROWNUM = 1),
    1500, 12);

-- Mobile Phones
INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Samsung Galaxy A54 5G', 'SAM-MOB-A54',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Mobile Phone' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Smartphone' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Samsung' AND status = 1 AND ROWNUM = 1),
    42000, 12);

INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Walton Primo X7 Pro', 'WAL-MOB-X7',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Walton%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Mobile Phone' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Smartphone' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Walton' AND status = 1 AND ROWNUM = 1),
    18000, 12);

-- Kitchen Appliances
INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Singer Rice Cooker 2.8L', 'SIN-RC-2.8',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Singer%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Kitchen Appliance' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Rice Cooker' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Singer' AND status = 1 AND ROWNUM = 1),
    3200, 12);

INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Panasonic Blender 1.5L', 'PAN-BL-1.5',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Kitchen Appliance' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Blender' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Panasonic' AND status = 1 AND ROWNUM = 1),
    2800, 12);

-- Iron
INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Philips Steam Iron 2400W', 'PHI-IRON-2400',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Iron' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Steam Iron' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Philips' AND status = 1 AND ROWNUM = 1),
    2500, 12);

-- Home Theatre
INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Sony Home Theatre 5.1 Channel', 'SON-HT-5.1',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sony%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Home Theatre' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = '5.1 Channel Home Theatre' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Sony' AND status = 1 AND ROWNUM = 1),
    28000, 12);

-- Laptop
INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('HP Laptop Core i5 8GB RAM', 'HP-LAP-I5',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sony%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Laptop' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Gaming Laptop' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'HP' AND status = 1 AND ROWNUM = 1),
    52000, 12);

-- Desktop
INSERT INTO products (product_name, product_code, supplier_id, category_id, sub_cat_id, brand_id, purchase_price, warranty)
VALUES ('Walton Desktop Core i3 4GB', 'WAL-DES-I3',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Walton%' AND status = 1 AND ROWNUM = 1),
    (SELECT product_cat_id FROM product_categories WHERE product_cat_name = 'Desktop' AND status = 1 AND ROWNUM = 1),
    (SELECT sub_cat_id FROM sub_categories WHERE sub_cat_name = 'Gaming Desktop' AND status = 1 AND ROWNUM = 1),
    (SELECT brand_id FROM brand WHERE brand_name = 'Walton' AND status = 1 AND ROWNUM = 1),
    32000, 12);

COMMIT;

-- ============================================================================
-- SECTION 2: SUPPLY CHAIN TRANSACTIONS
-- ============================================================================

-- ------------------------------------------------
-- 2.1 Product Orders (10 orders with details)
-- ------------------------------------------------
PROMPT Inserting product orders...

-- Order 1: Vision Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-01',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id, 
        (SELECT product_id FROM products WHERE product_code = 'VIS-REF-12' AND status = 1 AND ROWNUM = 1),
        10, 28000);
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1),
        20, 1500);
    
    COMMIT;
END;
/

-- Order 2: Samsung Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-03',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-WM-8T' AND status = 1 AND ROWNUM = 1),
        8, 28000);
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-MOB-A54' AND status = 1 AND ROWNUM = 1),
        15, 42000);
    
    COMMIT;
END;
/

-- Order 3: LG Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-05',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%LG%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'LG-WM-7F' AND status = 1 AND ROWNUM = 1),
        12, 32000);
    
    COMMIT;
END;
/

-- Order 4: Sharp Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-07',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-AC-1.5' AND status = 1 AND ROWNUM = 1),
        6, 38000);
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        15, 18000);
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-MW-25' AND status = 1 AND ROWNUM = 1),
        10, 12000);
    
    COMMIT;
END;
/

-- Order 5: Walton Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-10',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Walton%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-FAN-56' AND status = 1 AND ROWNUM = 1),
        25, 2200);
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-MOB-X7' AND status = 1 AND ROWNUM = 1),
        20, 18000);
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-DES-I3' AND status = 1 AND ROWNUM = 1),
        5, 32000);
    
    COMMIT;
END;
/

-- Order 6: Sony Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-12',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sony%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-LED-43' AND status = 1 AND ROWNUM = 1),
        10, 42000);
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-HT-5.1' AND status = 1 AND ROWNUM = 1),
        8, 28000);
    
    COMMIT;
END;
/

-- Order 7: Minister Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-15',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Minister%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'MIN-REF-15' AND status = 1 AND ROWNUM = 1),
        7, 35000);
    
    COMMIT;
END;
/

-- Order 8: Hitachi Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-18',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Hitachi%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'HIT-AC-2.0' AND status = 1 AND ROWNUM = 1),
        5, 55000);
    
    COMMIT;
END;
/

-- Order 9: Panasonic Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-20',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-MW-23' AND status = 1 AND ROWNUM = 1),
        12, 8500);
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-BL-1.5' AND status = 1 AND ROWNUM = 1),
        18, 2800);
    
    COMMIT;
END;
/

-- Order 10: Singer Products
DECLARE
    v_order_id VARCHAR2(50);
BEGIN
    INSERT INTO product_order_master (order_date, supplier_id, order_by)
    VALUES (
        DATE '2025-11-22',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Singer%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING order_id INTO v_order_id;
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'SIN-RC-2.8' AND status = 1 AND ROWNUM = 1),
        15, 3200);
    
    INSERT INTO product_order_detail (order_id, product_id, quantity, purchase_price)
    VALUES (v_order_id,
        (SELECT product_id FROM products WHERE product_code = 'PHI-IRON-2400' AND status = 1 AND ROWNUM = 1),
        10, 2500);
    
    COMMIT;
END;
/

-- ------------------------------------------------
-- 2.2 Product Receives (10 receives linked to orders)
-- ------------------------------------------------
PROMPT Inserting product receives...

-- Receive 1: For Order 1 (Vision)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, received_by)
    VALUES (
        DATE '2025-11-05',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-01' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-REF-12' AND status = 1 AND ROWNUM = 1),
        10, 28000);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1),
        20, 1500);
    
    COMMIT;
END;
/

-- Receive 2: For Order 2 (Samsung)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, received_by)
    VALUES (
        DATE '2025-11-08',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-03' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-WM-8T' AND status = 1 AND ROWNUM = 1),
        8, 28000);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-MOB-A54' AND status = 1 AND ROWNUM = 1),
        15, 42000);
    
    COMMIT;
END;
/

-- Receive 3: For Order 3 (LG)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, received_by)
    VALUES (
        DATE '2025-11-10',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-05' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%LG%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'LG-WM-7F' AND status = 1 AND ROWNUM = 1),
        12, 32000);
    
    COMMIT;
END;
/

-- Receive 4: For Order 4 (Sharp)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, received_by)
    VALUES (
        DATE '2025-11-12',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-07' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-AC-1.5' AND status = 1 AND ROWNUM = 1),
        6, 38000);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        15, 18000);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-MW-25' AND status = 1 AND ROWNUM = 1),
        10, 12000);
    
    COMMIT;
END;
/

-- Receive 5: For Order 5 (Walton)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, received_by)
    VALUES (
        DATE '2025-11-14',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-10' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Walton%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-FAN-56' AND status = 1 AND ROWNUM = 1),
        25, 2200);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-MOB-X7' AND status = 1 AND ROWNUM = 1),
        20, 18000);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-DES-I3' AND status = 1 AND ROWNUM = 1),
        5, 32000);
    
    COMMIT;
END;
/

-- Receive 6: For Order 6 (Sony)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, received_by)
    VALUES (
        DATE '2025-11-17',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-12' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sony%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-LED-43' AND status = 1 AND ROWNUM = 1),
        10, 42000);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-HT-5.1' AND status = 1 AND ROWNUM = 1),
        8, 28000);
    
    COMMIT;
END;
/

-- Receive 7: For Order 7 (Minister)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, received_by)
    VALUES (
        DATE '2025-11-20',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-15' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Minister%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'MIN-REF-15' AND status = 1 AND ROWNUM = 1),
        7, 35000);
    
    COMMIT;
END;
/

-- Receive 8: For Order 8 (Hitachi)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, received_by)
    VALUES (
        DATE '2025-11-23',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-18' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Hitachi%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'HIT-AC-2.0' AND status = 1 AND ROWNUM = 1),
        5, 55000);
    
    COMMIT;
END;
/

-- Receive 9: For Order 9 (Panasonic)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, received_by)
    VALUES (
        DATE '2025-11-25',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-20' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-MW-23' AND status = 1 AND ROWNUM = 1),
        12, 8500);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-BL-1.5' AND status = 1 AND ROWNUM = 1),
        18, 2800);
    
    COMMIT;
END;
/

-- Receive 10: For Order 10 (Singer)
DECLARE
    v_receive_id VARCHAR2(50);
BEGIN
    INSERT INTO product_receive_master (receive_date, order_id, supplier_id, received_by)
    VALUES (
        DATE '2025-11-27',
        (SELECT order_id FROM product_order_master WHERE order_date = DATE '2025-11-22' AND status = 1 AND ROWNUM = 1),
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Singer%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING receive_id INTO v_receive_id;
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'SIN-RC-2.8' AND status = 1 AND ROWNUM = 1),
        15, 3200);
    
    INSERT INTO product_receive_details (receive_id, product_id, receive_quantity, purchase_price)
    VALUES (v_receive_id,
        (SELECT product_id FROM products WHERE product_code = 'PHI-IRON-2400' AND status = 1 AND ROWNUM = 1),
        10, 2500);
    
    COMMIT;
END;
/

-- ------------------------------------------------
-- 2.3 Product Returns (5 returns for supplier)
-- ------------------------------------------------
PROMPT Inserting product returns...

-- Return 1: Defective Vision Fans
DECLARE
    v_return_id VARCHAR2(50);
BEGIN
    INSERT INTO product_return_master (return_date, supplier_id, return_by)
    VALUES (
        DATE '2025-11-08',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO product_return_details (return_id, product_id, return_quantity, purchase_price, reason)
    VALUES (v_return_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1),
        3, 1500, 'Returned to supplier');
    
    COMMIT;
END;
/

-- Return 2: Damaged Samsung Phones
DECLARE
    v_return_id VARCHAR2(50);
BEGIN
    INSERT INTO product_return_master (return_date, supplier_id, return_by)
    VALUES (
        DATE '2025-11-11',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO product_return_details (return_id, product_id, return_quantity, purchase_price, reason)
    VALUES (v_return_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-MOB-A54' AND status = 1 AND ROWNUM = 1),
        2, 42000, 'Returned to supplier');
    
    COMMIT;
END;
/

-- Return 3: Defective Sharp LED
DECLARE
    v_return_id VARCHAR2(50);
BEGIN
    INSERT INTO product_return_master (return_date, supplier_id, return_by)
    VALUES (
        DATE '2025-11-15',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO product_return_details (return_id, product_id, return_quantity, purchase_price, reason)
    VALUES (v_return_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        1, 18000, 'Returned to supplier');
    
    COMMIT;
END;
/

-- Return 4: Faulty Panasonic Blenders
DECLARE
    v_return_id VARCHAR2(50);
BEGIN
    INSERT INTO product_return_master (return_date, supplier_id, return_by)
    VALUES (
        DATE '2025-11-28',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO product_return_details (return_id, product_id, return_quantity, purchase_price, reason)
    VALUES (v_return_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-BL-1.5' AND status = 1 AND ROWNUM = 1),
        4, 2800, 'Returned to supplier');
    
    COMMIT;
END;
/

-- Return 5: Wrong Model Singer Rice Cooker
DECLARE
    v_return_id VARCHAR2(50);
BEGIN
    INSERT INTO product_return_master (return_date, supplier_id, return_by)
    VALUES (
        DATE '2025-11-30',
        (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Singer%' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Purchase and Supply' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1)
    )
    RETURNING return_id INTO v_return_id;
    
    INSERT INTO product_return_details (return_id, product_id, return_quantity, purchase_price, reason)
    VALUES (v_return_id,
        (SELECT product_id FROM products WHERE product_code = 'SIN-RC-2.8' AND status = 1 AND ROWNUM = 1),
        2, 3200, 'Returned to supplier');
    
    COMMIT;
END;
/

-- ============================================================================
-- SECTION 3: SALES TRANSACTIONS
-- ============================================================================

-- ------------------------------------------------
-- 3.1 Additional Sales (15 new sales with details)
-- ------------------------------------------------
PROMPT Inserting additional sales...

-- Sale 1
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-01',
        (SELECT customer_id FROM customers WHERE customer_name = 'Rahman Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        2000, 1800
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-REF-12' AND status = 1 AND ROWNUM = 1),
        2, 32000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1),
        3, 1900);
    
    COMMIT;
END;
/

-- Sale 2
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-02',
        (SELECT customer_id FROM customers WHERE customer_name = 'Karim Trading' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        3000, 2500
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-WM-8T' AND status = 1 AND ROWNUM = 1),
        1, 33000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-MOB-A54' AND status = 1 AND ROWNUM = 1),
        2, 48000);
    
    COMMIT;
END;
/

-- Sale 3
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-03',
        (SELECT customer_id FROM customers WHERE customer_name = 'Akter Stores' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        2500, 2200
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'LG-WM-7F' AND status = 1 AND ROWNUM = 1),
        1, 38000);
    
    COMMIT;
END;
/

-- Sale 4
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-04',
        (SELECT customer_id FROM customers WHERE customer_name = 'Hossain Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        4000, 3500
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-AC-1.5' AND status = 1 AND ROWNUM = 1),
        1, 45000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        2, 22000);
    
    COMMIT;
END;
/

-- Sale 5
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-05',
        (SELECT customer_id FROM customers WHERE customer_name = 'Begum Traders' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        5000, 4500
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'HIT-AC-2.0' AND status = 1 AND ROWNUM = 1),
        1, 65000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-FAN-56' AND status = 1 AND ROWNUM = 1),
        4, 2800);
    
    COMMIT;
END;
/

-- Sale 6
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-06',
        (SELECT customer_id FROM customers WHERE customer_name = 'Ali Enterprise' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        3500, 3000
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-LED-43' AND status = 1 AND ROWNUM = 1),
        1, 50000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-MOB-X7' AND status = 1 AND ROWNUM = 1),
        1, 22000);
    
    COMMIT;
END;
/

-- Sale 7
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-07',
        (SELECT customer_id FROM customers WHERE customer_name = 'Sultana Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        2000, 1500
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'MIN-REF-15' AND status = 1 AND ROWNUM = 1),
        1, 40000);
    
    COMMIT;
END;
/

-- Sale 8
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-08',
        (SELECT customer_id FROM customers WHERE customer_name = 'Ahmed Trading Co' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        1800, 1200
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-MW-23' AND status = 1 AND ROWNUM = 1),
        2, 10500);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'PAN-BL-1.5' AND status = 1 AND ROWNUM = 1),
        3, 3500);
    
    COMMIT;
END;
/

-- Sale 9
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-09',
        (SELECT customer_id FROM customers WHERE customer_name = 'Nasrin Stores' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        1500, 1000
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SIN-RC-2.8' AND status = 1 AND ROWNUM = 1),
        4, 4000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'PHI-IRON-2400' AND status = 1 AND ROWNUM = 1),
        3, 3200);
    
    COMMIT;
END;
/

-- Sale 10
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-10',
        (SELECT customer_id FROM customers WHERE customer_name = 'Kabir Electronics Hub' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        4500, 4000
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-HT-5.1' AND status = 1 AND ROWNUM = 1),
        1, 35000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-MW-25' AND status = 1 AND ROWNUM = 1),
        2, 15000);
    
    COMMIT;
END;
/

-- Sale 11
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-11',
        (SELECT customer_id FROM customers WHERE customer_name = 'Siddique Traders' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        3000, 2500
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-DES-I3' AND status = 1 AND ROWNUM = 1),
        1, 38000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'HP-LAP-I5' AND status = 1 AND ROWNUM = 1),
        1, 62000);
    
    COMMIT;
END;
/

-- Sale 12
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-12',
        (SELECT customer_id FROM customers WHERE customer_name = 'Fatema Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        1000, 800
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1),
        5, 1900);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-FAN-56' AND status = 1 AND ROWNUM = 1),
        3, 2800);
    
    COMMIT;
END;
/

-- Sale 13
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-13',
        (SELECT customer_id FROM customers WHERE customer_name = 'Mia Trading House' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        5500, 5000
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-WM-8T' AND status = 1 AND ROWNUM = 1),
        2, 33000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'LG-WM-7F' AND status = 1 AND ROWNUM = 1),
        1, 38000);
    
    COMMIT;
END;
/

-- Sale 14
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-14',
        (SELECT customer_id FROM customers WHERE customer_name = 'Chowdhury Electronics' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        2500, 2000
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1),
        3, 22000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SON-LED-43' AND status = 1 AND ROWNUM = 1),
        1, 50000);
    
    COMMIT;
END;
/

-- Sale 15
DECLARE
    v_invoice_id VARCHAR2(50);
BEGIN
    INSERT INTO sales_master (invoice_date, customer_id, sales_by, discount, vat)
    VALUES (
        DATE '2025-12-15',
        (SELECT customer_id FROM customers WHERE customer_name = 'Begum Trading Co' AND status = 1 AND ROWNUM = 1),
        (SELECT employee_id FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales and Marketing' AND status = 1 AND ROWNUM = 1) AND status = 1 AND ROWNUM = 1),
        6000, 5500
    )
    RETURNING invoice_id INTO v_invoice_id;
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'SAM-MOB-A54' AND status = 1 AND ROWNUM = 1),
        3, 48000);
    
    INSERT INTO sales_detail (invoice_id, product_id, quantity, purchase_price)
    VALUES (v_invoice_id,
        (SELECT product_id FROM products WHERE product_code = 'WAL-MOB-X7' AND status = 1 AND ROWNUM = 1),
        2, 22000);
    
    COMMIT;
END;
/

-- ------------------------------------------------
-- 3.2 Sales Returns (5 customer returns)
-- ------------------------------------------------
PROMPT Inserting sales returns...

-- Sales Return 1
DECLARE
    v_return_id VARCHAR2(50);
    v_invoice_id VARCHAR2(50);
BEGIN
    -- Get a recent invoice
    SELECT invoice_id INTO v_invoice_id 
    FROM sales_master 
    WHERE invoice_date = DATE '2025-12-01' AND status = 1 AND ROWNUM = 1;
    
    INSERT INTO sales_return_master (return_date, invoice_id, customer_id)
    VALUES (
        DATE '2025-12-05',
        v_invoice_id,
        (SELECT customer_id FROM customers WHERE customer_name = 'Rahman Electronics' AND status = 1 AND ROWNUM = 1))
    RETURNING sales_return_id INTO v_return_id;
    
    INSERT INTO sales_return_details (sales_return_id, product_id, quantity, purchase_price, reason)
    VALUES (v_return_id, (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1), 1, 1900, 'Customer return');
    
    COMMIT;
END;
/

-- Sales Return 2
DECLARE
    v_return_id VARCHAR2(50);
    v_invoice_id VARCHAR2(50);
BEGIN
    SELECT invoice_id INTO v_invoice_id 
    FROM sales_master 
    WHERE invoice_date = DATE '2025-12-04' AND status = 1 AND ROWNUM = 1;
    
    INSERT INTO sales_return_master (return_date, invoice_id, customer_id)
    VALUES (
        DATE '2025-12-08',
        v_invoice_id,
        (SELECT customer_id FROM customers WHERE customer_name = 'Hossain Electronics' AND status = 1 AND ROWNUM = 1))
    RETURNING sales_return_id INTO v_return_id;
    
    INSERT INTO sales_return_details (sales_return_id, product_id, quantity, purchase_price, reason)
    VALUES (v_return_id, (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1), 1, 22000, 'Customer return');
    
    COMMIT;
END;
/

-- Sales Return 3
DECLARE
    v_return_id VARCHAR2(50);
    v_invoice_id VARCHAR2(50);
BEGIN
    SELECT invoice_id INTO v_invoice_id 
    FROM sales_master 
    WHERE invoice_date = DATE '2025-12-09' AND status = 1 AND ROWNUM = 1;
    
    INSERT INTO sales_return_master (return_date, invoice_id, customer_id)
    VALUES (
        DATE '2025-12-12',
        v_invoice_id,
        (SELECT customer_id FROM customers WHERE customer_name = 'Nasrin Stores' AND status = 1 AND ROWNUM = 1))
    RETURNING sales_return_id INTO v_return_id;
    
    INSERT INTO sales_return_details (sales_return_id, product_id, quantity, purchase_price, reason)
    VALUES (v_return_id, (SELECT product_id FROM products WHERE product_code = 'PHI-IRON-2400' AND status = 1 AND ROWNUM = 1), 2, 3200, 'Customer return');
    
    COMMIT;
END;
/

-- Sales Return 4
DECLARE
    v_return_id VARCHAR2(50);
    v_invoice_id VARCHAR2(50);
BEGIN
    SELECT invoice_id INTO v_invoice_id 
    FROM sales_master 
    WHERE invoice_date = DATE '2025-12-14' AND status = 1 AND ROWNUM = 1;
    
    INSERT INTO sales_return_master (return_date, invoice_id, customer_id)
    VALUES (
        DATE '2025-12-16',
        v_invoice_id,
        (SELECT customer_id FROM customers WHERE customer_name = 'Chowdhury Electronics' AND status = 1 AND ROWNUM = 1))
    RETURNING sales_return_id INTO v_return_id;
    
    INSERT INTO sales_return_details (sales_return_id, product_id, quantity, purchase_price, reason)
    VALUES (v_return_id, (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1), 1, 22000, 'Customer return');
    
    COMMIT;
END;
/

-- Sales Return 5
DECLARE
    v_return_id VARCHAR2(50);
    v_invoice_id VARCHAR2(50);
BEGIN
    SELECT invoice_id INTO v_invoice_id 
    FROM sales_master 
    WHERE invoice_date = DATE '2025-12-15' AND status = 1 AND ROWNUM = 1;
    
    INSERT INTO sales_return_master (return_date, invoice_id, customer_id)
    VALUES (
        DATE '2025-12-18',
        v_invoice_id,
        (SELECT customer_id FROM customers WHERE customer_name = 'Begum Trading Co' AND status = 1 AND ROWNUM = 1))
    RETURNING sales_return_id INTO v_return_id;
    
    INSERT INTO sales_return_details (sales_return_id, product_id, quantity, purchase_price, reason)
    VALUES (v_return_id, (SELECT product_id FROM products WHERE product_code = 'WAL-MOB-X7' AND status = 1 AND ROWNUM = 1), 1, 22000, 'Customer return');
    
    COMMIT;
END;
/

-- ============================================================================
-- SECTION 4: FINANCIAL TRANSACTIONS
-- ============================================================================

-- ------------------------------------------------
-- 4.1 Supplier Payments (12 payments)
-- ------------------------------------------------
PROMPT Inserting supplier payments...

-- Payment 1: Vision
INSERT INTO payments (payment_date, supplier_id, amount, payment_type)
VALUES (
    DATE '2025-11-10',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
    250000,
    'BANK');

-- Payment 2: Samsung
INSERT INTO payments (payment_date, supplier_id, amount, payment_type)
VALUES (
    DATE '2025-11-12',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
    850000,
    'BANK');

-- Payment 3: LG
INSERT INTO payments (payment_date, supplier_id, amount, payment_type)
VALUES (
    DATE '2025-11-15',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%LG%' AND status = 1 AND ROWNUM = 1),
    384000,
    'BANK');

-- Payment 4: Sharp
INSERT INTO payments (payment_date, supplier_id, amount, payment_type)
VALUES (
    DATE '2025-11-18',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sharp%' AND status = 1 AND ROWNUM = 1),
    620000,
    'BANK');

-- Payment 5: Walton
INSERT INTO payments (payment_date, supplier_id, amount, payment_type)
VALUES (
    DATE '2025-11-20',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Walton%' AND status = 1 AND ROWNUM = 1),
    575000,
    'BANK');

-- Payment 6: Sony
INSERT INTO payments (payment_date, supplier_id, amount, payment_type)
VALUES (
    DATE '2025-11-22',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Sony%' AND status = 1 AND ROWNUM = 1),
    644000,
    'BANK');

-- Payment 7: Minister
INSERT INTO payments (payment_date, supplier_id, amount, payment_type)
VALUES (
    DATE '2025-11-25',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Minister%' AND status = 1 AND ROWNUM = 1),
    245000,
    'BANK');

-- Payment 8: Hitachi
INSERT INTO payments (payment_date, supplier_id, amount, payment_type)
VALUES (
    DATE '2025-11-28',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Hitachi%' AND status = 1 AND ROWNUM = 1),
    275000,
    'BANK');

-- Payment 9: Panasonic
INSERT INTO payments (payment_date, supplier_id, amount, payment_type)
VALUES (
    DATE '2025-11-30',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Panasonic%' AND status = 1 AND ROWNUM = 1),
    152400,
    'BANK');

-- Payment 10: Singer
INSERT INTO payments (payment_date, supplier_id, amount, payment_type)
VALUES (
    DATE '2025-12-02',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Singer%' AND status = 1 AND ROWNUM = 1),
    73000,
    'BANK');

-- Payment 11: Vision (Second payment)
INSERT INTO payments (payment_date, supplier_id, amount, payment_type)
VALUES (
    DATE '2025-12-05',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Vision%' AND status = 1 AND ROWNUM = 1),
    150000,
    'BANK');

-- Payment 12: Samsung (Second payment)
INSERT INTO payments (payment_date, supplier_id, amount, payment_type)
VALUES (
    DATE '2025-12-08',
    (SELECT supplier_id FROM suppliers WHERE supplier_name LIKE '%Samsung%' AND status = 1 AND ROWNUM = 1),
    500000,
    'BANK');

COMMIT;

-- ============================================================================
-- SECTION 5: SERVICE TRANSACTIONS (from insert_services.sql)
-- ============================================================================

-- ------------------------------------------------
-- 5.1 Service Requests (14 service records with details)
-- ------------------------------------------------
PROMPT Inserting service requests...

-- Service 1: Mobile phone repair (customer walk-in, no invoice link)
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2025-12-03',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Samsung Galaxy S24%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Mobile Service and Repair' AND status = 1 AND ROWNUM = 1),
    1,
    1000,
    1000,
    'N',
    'Screen replacement diagnosis and cleaning'
  );
END;
/

-- Service 2: Washing machine diagnosis (linked to invoice to test warranty)
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, invoice_id, service_by)
  VALUES (
    DATE '2025-12-07',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT invoice_id FROM sales_master WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Washing Machine%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Washing Machine Repair' AND status = 1 AND ROWNUM = 1),
    1,
    1800,
    1800,
    'Y',
    'General diagnosis and water inlet check'
  );
END;
/

-- Service 3: LED TV power board replacement (with parts)
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2025-12-15',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  -- Line 1: Diagnostic service
  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%LED%TV%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'TV Repair Service' AND status = 1 AND ROWNUM = 1),
    1,
    1500,
    1500,
    'N',
    'Power board faulty diagnosis'
  );

  -- Line 2: Parts replacement
  INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%LED%TV%' AND status = 1 AND ROWNUM = 1),
    (SELECT parts_id FROM parts WHERE parts_name LIKE '%Power Supply Board%' AND status = 1 AND ROWNUM = 1),
    1,
    2500,
    2500,
    'N',
    'Power board replaced'
  );
END;
/

-- Service 4: Refrigerator gas refill and check
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2025-12-20',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Refrigerator%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Refrigerator Repair' AND status = 1 AND ROWNUM = 1),
    1,
    2000,
    2000,
    'N',
    'Gas refill and condenser cleaning'
  );
END;
/

-- Service 5: Air Conditioner cleaning and servicing
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2025-12-22',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Air Conditioner%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'AC Servicing' AND status = 1 AND ROWNUM = 1),
    1,
    1500,
    1500,
    'N',
    'Complete AC servicing and filter cleaning'
  );
END;
/

-- Service 6: Mobile phone battery replacement (with parts)
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2025-12-25',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  -- Service charge
  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Samsung Galaxy S24%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Mobile Service and Repair' AND status = 1 AND ROWNUM = 1),
    1,
    1000,
    1000,
    'N',
    'Battery replacement and testing'
  );

  -- Parts cost
  INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Samsung Galaxy S24%' AND status = 1 AND ROWNUM = 1),
    (SELECT parts_id FROM parts WHERE parts_name LIKE '%Battery%' AND status = 1 AND ROWNUM = 1),
    1,
    1800,
    1800,
    'Y',
    'Original battery installed'
  );
END;
/

-- Service 7: Microwave oven repair (warranty service)
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, invoice_id, service_by)
  VALUES (
    DATE '2025-12-28',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT invoice_id FROM sales_master WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Microwave%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Microwave Oven Repair' AND status = 1 AND ROWNUM = 1),
    1,
    0,
    0,
    'Y',
    'Warranty service - turntable motor replacement'
  );
END;
/

-- Service 8: Laptop screen repair
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2026-01-03',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Laptop%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Laptop / Computer Repair' AND status = 1 AND ROWNUM = 1),
    1,
    2000,
    2000,
    'N',
    'Screen replacement (customer provided screen)'
  );
END;
/

-- Service 9: Washing machine motor replacement (complex repair)
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2026-01-08',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  -- Diagnosis
  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Washing Machine%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Washing Machine Repair' AND status = 1 AND ROWNUM = 1),
    1,
    1800,
    1800,
    'N',
    'Motor fault diagnosis and replacement'
  );

  -- Parts replacement
  INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Washing Machine%' AND status = 1 AND ROWNUM = 1),
    (SELECT parts_id FROM parts WHERE parts_name LIKE '%Belt%' AND status = 1 AND ROWNUM = 1),
    1,
    800,
    800,
    'Y',
    'Drum belt replaced with original parts'
  );
END;
/

-- Service 10: LED TV software update and tuning
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2026-01-12',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%LED%TV%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'TV Installation' AND status = 1 AND ROWNUM = 1),
    1,
    800,
    800,
    'N',
    'Software update and channel tuning'
  );
END;
/

-- Service 11: Refrigerator compressor issue diagnosis
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, invoice_id, service_by)
  VALUES (
    DATE '2026-01-15',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT invoice_id FROM sales_master WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Refrigerator%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Refrigerator Repair' AND status = 1 AND ROWNUM = 1),
    1,
    2000,
    2000,
    'Y',
    'Compressor noise diagnosis and lubrication'
  );
END;
/

-- Service 12: Mobile phone water damage repair
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2026-01-18',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  -- Cleaning service
  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Samsung Galaxy S24%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Mobile Service and Repair' AND status = 1 AND ROWNUM = 1),
    1,
    1000,
    1000,
    'N',
    'Water damage cleaning and component testing'
  );

  -- Parts replacement (if needed)
  INSERT INTO service_details (service_id, product_id, parts_id, quantity, parts_price, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Samsung Galaxy S24%' AND status = 1 AND ROWNUM = 1),
    (SELECT parts_id FROM parts WHERE parts_name LIKE '%Display%' AND status = 1 AND ROWNUM = 1),
    1,
    3500,
    3500,
    'N',
    'Display panel damaged - replaced'
  );
END;
/

-- Service 13: Desktop computer hardware upgrade
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2026-01-20',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE product_name LIKE '%Laptop%' AND status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Laptop / Computer Repair' AND status = 1 AND ROWNUM = 1),
    1,
    2000,
    2000,
    'N',
    'RAM upgrade and SSD installation service'
  );
END;
/

-- Service 14: Iron board heating element replacement
DECLARE
  v_service_id VARCHAR2(50);
BEGIN
  INSERT INTO service_master (service_date, customer_id, service_by)
  VALUES (
    DATE '2026-01-23',
    (SELECT customer_id FROM customers WHERE status = 1 AND ROWNUM = 1),
    (SELECT employee_id FROM employees WHERE department_id = 'SER51' AND status = 1 AND ROWNUM = 1)
  )
  RETURNING service_id INTO v_service_id;

  -- Diagnosis and repair
  INSERT INTO service_details (service_id, product_id, servicelist_id, quantity, service_charge, line_total, warranty_status, description)
  VALUES (
    v_service_id,
    (SELECT product_id FROM products WHERE status = 1 AND ROWNUM = 1),
    (SELECT servicelist_id FROM service_list WHERE service_name = 'Home Appliance Diagnosis' AND status = 1 AND ROWNUM = 1),
    1,
    500,
    500,
    'N',
    'Small appliance heating element repair'
  );
END;
/

-- ============================================================================
-- SECTION 6: EXPENSE TRANSACTIONS (from insert_expenses.sql)
-- ============================================================================

-- ------------------------------------------------
-- 6.1 Expense Records (16 expense masters with details)
-- ------------------------------------------------
PROMPT Inserting expense transactions...

-- Expense 1: Office Rent (Finance and Accounting)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-01',
    (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'OFF' AND status = 1 AND ROWNUM = 1),
    'Accounts Team'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'December office rent (main branch)', 30000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Service charge', 1500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Common area maintenance', 500);

-- Expense 2: Utility Bills (Finance and Accounting)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-05',
    (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'UTL' AND status = 1 AND ROWNUM = 1),
    'Accounts Team'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Electricity bill - Dec', 9000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Water bill - Dec', 2000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Gas bill - Dec', 4000);

-- Expense 3: Internet and Telephone (IT Infrastructure)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-06',
    (SELECT department_id FROM departments WHERE department_name = 'IT Infrastructure' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'INT' AND status = 1 AND ROWNUM = 1),
    'IT Officer'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Corporate Internet bill (100 Mbps)', 3500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Office landline bill', 1200);

-- Expense 4: Technician Allowance (After Sales Service)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-10',
    (SELECT department_id FROM departments WHERE department_name = 'After Sales Service' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'TEC' AND status = 1 AND ROWNUM = 1),
    'Service Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Uttara site visit allowance', 1500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Dhanmondi site visit allowance', 1800);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Transport (CNG/Bus)', 600);

-- Expense 5: Marketing and Promotion (Sales Department)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-12',
    (SELECT department_id FROM departments WHERE department_name = 'Sales Department' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'MKT' AND status = 1 AND ROWNUM = 1),
    'Sales Lead'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Facebook ads (Dhaka targeting)', 3000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Banner printing and setup', 2500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Local market promotion', 1200);

-- Expense 6: Staff Salary (Human Resources)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-31',
    (SELECT department_id FROM departments WHERE department_name = 'Human Resources' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'SAL' AND status = 1 AND ROWNUM = 1),
    'HR Officer'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Technician salary - Dec', 35000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Sales executive salary - Dec', 25000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Support staff salary - Dec', 20000);

-- Expense 7: Office Supplies (Finance and Accounting)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-15',
    (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'OFF' AND status = 1 AND ROWNUM = 1),
    'Office Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Printer paper and stationery', 4500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Printer ink cartridges', 6200);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Office supplies (pens, files, folders)', 2800);

-- Expense 8: Transportation Allowance (Sales Department)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-18',
    (SELECT department_id FROM departments WHERE department_name = 'Sales Department' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'TRN' AND status = 1 AND ROWNUM = 1),
    'Sales Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Field sales transport - Gulshan area', 2500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Field sales transport - Banani area', 2200);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Fuel allowance for sales team', 5000);

-- Expense 9: IT Equipment Maintenance (IT Infrastructure)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2025-12-20',
    (SELECT department_id FROM departments WHERE department_name = 'IT Infrastructure' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'REP' AND status = 1 AND ROWNUM = 1),
    'IT Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Server maintenance and backup', 12000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Software licenses renewal', 8500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Network equipment repair', 4500);

-- Expense 10: Training and Development (Human Resources)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-05',
    (SELECT department_id FROM departments WHERE department_name = 'Human Resources' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'OTH' AND status = 1 AND ROWNUM = 1),
    'HR Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Technical training for service staff', 15000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Sales training workshop', 10000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Training materials and refreshments', 3500);

-- Expense 11: Security Services (Finance and Accounting)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-10',
    (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'OFF' AND status = 1 AND ROWNUM = 1),
    'Accounts Officer'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Security guard salary - January', 18000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'CCTV maintenance', 3500);

-- Expense 12: Courier and Delivery (Sales Department)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-12',
    (SELECT department_id FROM departments WHERE department_name = 'Sales Department' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'TRN' AND status = 1 AND ROWNUM = 1),
    'Sales Coordinator'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Product delivery charges (Dhaka)', 7500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Courier service (document delivery)', 2500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Packaging materials', 3200);

-- Expense 13: Spare Parts Purchase (After Sales Service)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-15',
    (SELECT department_id FROM departments WHERE department_name = 'After Sales Service' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'PUR' AND status = 1 AND ROWNUM = 1),
    'Service Head'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Mobile phone spare parts', 25000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Refrigerator compressor parts', 15000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'LED TV panel replacement parts', 18000);

-- Expense 14: Professional Fees (Finance and Accounting)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-18',
    (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'OTH' AND status = 1 AND ROWNUM = 1),
    'Finance Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Legal consultation fees', 12000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Audit and accounting services', 20000);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Tax filing assistance', 8000);

-- Expense 15: Customer Entertainment (Sales Department)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-20',
    (SELECT department_id FROM departments WHERE department_name = 'Sales Department' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'MKT' AND status = 1 AND ROWNUM = 1),
    'Business Development Lead'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Client meeting refreshments', 4500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Business lunch expenses', 6200);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Corporate gifts for clients', 8500);

-- Expense 16: Building Maintenance (Finance and Accounting)
INSERT INTO expense_master (expense_date, department_id, expense_type_id, expense_by)
VALUES (
    DATE '2026-01-22',
    (SELECT department_id FROM departments WHERE department_name = 'Finance and Accounting' AND status = 1 AND ROWNUM = 1),
    (SELECT expense_type_id FROM expense_list WHERE expense_code = 'REP' AND status = 1 AND ROWNUM = 1),
    'Facility Manager'
);

INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'AC servicing and repair', 8500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Plumbing repairs', 3500);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Electrical maintenance', 5200);
INSERT INTO expense_details (expense_id, description, amount)
VALUES ('EXM' || TO_CHAR(exp_mst_seq.CURRVAL), 'Painting and cleaning', 7000);

-- ============================================================================
-- SECTION 7: DAMAGE RECORDS
-- ============================================================================

-- ------------------------------------------------
-- 7.1 Damage Transactions (8 damage records)
-- ------------------------------------------------
PROMPT Inserting damage records...

-- Damage 1: Water damaged fans
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date)
    VALUES (DATE '2025-11-08')
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, reason)
    VALUES (v_damage_id, (SELECT product_id FROM products WHERE product_code = 'VIS-FAN-16' AND status = 1 AND ROWNUM = 1), 2, 'Damaged product');
    
    COMMIT;
END;
/

-- Damage 2: Dropped microwave ovens
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date)
    VALUES (DATE '2025-11-12')
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, reason)
    VALUES (v_damage_id, (SELECT product_id FROM products WHERE product_code = 'PAN-MW-23' AND status = 1 AND ROWNUM = 1), 1, 'Damaged product');
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, reason)
    VALUES (v_damage_id, (SELECT product_id FROM products WHERE product_code = 'SHA-MW-25' AND status = 1 AND ROWNUM = 1), 1, 'Damaged product');
    
    COMMIT;
END;
/

-- Damage 3: Power surge
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date)
    VALUES (DATE '2025-11-18')
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, reason)
    VALUES (v_damage_id, (SELECT product_id FROM products WHERE product_code = 'SHA-LED-32' AND status = 1 AND ROWNUM = 1), 1, 'Damaged product');
    
    COMMIT;
END;
/

-- Damage 4: Shipping accident
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date)
    VALUES (DATE '2025-11-22')
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, reason)
    VALUES (v_damage_id, (SELECT product_id FROM products WHERE product_code = 'WAL-MOB-X7' AND status = 1 AND ROWNUM = 1), 3, 'Damaged product');
    
    COMMIT;
END;
/

-- Damage 5: Manufacturing defect
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date)
    VALUES (DATE '2025-11-25')
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, reason)
    VALUES (v_damage_id, (SELECT product_id FROM products WHERE product_code = 'PAN-BL-1.5' AND status = 1 AND ROWNUM = 1), 5, 'Damaged product');
    
    COMMIT;
END;
/

-- Damage 6: Fire in showroom
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date)
    VALUES (DATE '2025-11-28')
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, reason)
    VALUES (v_damage_id, (SELECT product_id FROM products WHERE product_code = 'SIN-RC-2.8' AND status = 1 AND ROWNUM = 1), 3, 'Damaged product');
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, reason)
    VALUES (v_damage_id, (SELECT product_id FROM products WHERE product_code = 'PHI-IRON-2400' AND status = 1 AND ROWNUM = 1), 2, 'Damaged product');
    
    COMMIT;
END;
/

-- Damage 7: Expired warranty products
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date)
    VALUES (DATE '2025-12-01')
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, reason)
    VALUES (v_damage_id, (SELECT product_id FROM products WHERE product_code = 'WAL-FAN-56' AND status = 1 AND ROWNUM = 1), 1, 'Damaged product');
    
    COMMIT;
END;
/

-- Damage 8: Theft
DECLARE
    v_damage_id VARCHAR2(50);
BEGIN
    INSERT INTO damage (damage_date)
    VALUES (DATE '2025-12-05')
    RETURNING damage_id INTO v_damage_id;
    
    INSERT INTO damage_detail (damage_id, product_id, damage_quantity, reason)
    VALUES (v_damage_id, (SELECT product_id FROM products WHERE product_code = 'SAM-MOB-A54' AND status = 1 AND ROWNUM = 1), 2, 'Damaged product');
    
    COMMIT;
END;
/

-- ============================================================================
-- FINAL COMMIT AND VERIFICATION
-- ============================================================================

COMMIT;
/*
PROMPT ========================================================================
PROMPT Comprehensive insert data completed successfully!
PROMPT ========================================================================
PROMPT Summary:
PROMPT - 15 new customers added
PROMPT - 8 new suppliers added
PROMPT - 20 new products added
PROMPT - 10 product orders with 23 order details
PROMPT - 10 product receives with 23 receive details
PROMPT - 5 product returns with 5 return details
PROMPT - 15 additional sales with 31 sales details
PROMPT - 5 sales returns with 5 return details
PROMPT - 14 service requests with 22 service details (from insert_services.sql)
PROMPT - 16 expense masters with 51 expense details (from insert_expenses.sql)
PROMPT - 12 supplier payments added
PROMPT - 8 damage records with 13 damage details
PROMPT ========================================================================
PROMPT Total Records Added: 241 records across all transactional tables
PROMPT ========================================================================
PROMPT Run verification queries to check data integrity:
PROMPT SELECT COUNT(*) FROM customers;
PROMPT SELECT COUNT(*) FROM suppliers;
PROMPT SELECT COUNT(*) FROM products;
PROMPT SELECT COUNT(*) FROM sales_master;
PROMPT SELECT COUNT(*) FROM service_master;
PROMPT SELECT COUNT(*) FROM expense_master;
PROMPT ========================================================================
*/
