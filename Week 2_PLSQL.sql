1.
Exercise 1: Control Structures

BEGIN
    FOR customer_rec IN (
        SELECT customer_id, age, loan_id, current_interest_rate
        FROM customers
        JOIN loans ON customers.customer_id = loans.customer_id
    ) LOOP
        IF customer_rec.age > 60 THEN
            UPDATE loans
            SET current_interest_rate = current_interest_rate - 0.01
            WHERE loan_id = customer_rec.loan_id;
            
            DBMS_OUTPUT.PUT_LINE('Applied 1% discount for loan ID: ' || customer_rec.loan_id || ' for customer ID: ' || customer_rec.customer_id);
        END IF;
    END LOOP;
END;


BEGIN
    FOR customer_rec IN (
        SELECT customer_id, balance
        FROM customers
    ) LOOP
        IF customer_rec.balance > 10000 THEN
            UPDATE customers
            SET is_vip = TRUE
            WHERE customer_id = customer_rec.customer_id;
            
            DBMS_OUTPUT.PUT_LINE('Customer ID: ' || customer_rec.customer_id || ' promoted to VIP status.');
        END IF;
    END LOOP;
END;

BEGIN
    FOR loan_rec IN (
        SELECT loan_id, customer_id, due_date
        FROM loans
        WHERE due_date BETWEEN SYSDATE AND SYSDATE + 30
    ) LOOP
       
        DBMS_OUTPUT.PUT_LINE('Reminder: Loan ID ' || loan_rec.loan_id || ' for customer ID ' || loan_rec.customer_id || ' is due on ' || loan_rec.due_date);
    END LOOP;
END;



2.
Exercise 2: Error Handling


CREATE OR REPLACE PROCEDURE SafeTransferFunds (
    p_from_account_id IN NUMBER,
    p_to_account_id IN NUMBER,
    p_amount IN NUMBER
) AS
    v_from_balance NUMBER;
    v_to_balance NUMBER;
BEGIN
 
    SAVEPOINT before_transfer;

    SELECT balance INTO v_from_balance
    FROM accounts
    WHERE account_id = p_from_account_id;
    
    SELECT balance INTO v_to_balance
    FROM accounts
    WHERE account_id = p_to_account_id;

    IF v_from_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds in account ' || p_from_account_id);
    END IF;

    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_from_account_id;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_to_account_id;

  
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Funds transferred successfully from account ' || p_from_account_id || ' to account ' || p_to_account_id);

EXCEPTION
    WHEN OTHERS THEN
       
        ROLLBACK TO before_transfer;


CREATE OR REPLACE PROCEDURE UpdateSalary (
    p_employee_id IN NUMBER,
    p_percentage IN NUMBER
) AS
    v_current_salary NUMBER;
BEGIN
   
    SELECT salary INTO v_current_salary
    FROM employees
    WHERE employee_id = p_employee_id;

    UPDATE employees
    SET salary = salary * (1 + p_percentage / 100)
    WHERE employee_id = p_employee_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Salary updated successfully for employee ID: ' || p_employee_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
   
        DBMS_OUTPUT.PUT_LINE('Error: Employee ID ' || p_employee_id || ' does not exist.');
    WHEN OTHERS THEN
      
        DBMS_OUTPUT.PUT_LINE('Error updating salary: ' || SQLERRM);
END UpdateSalary;
      
        DBMS_OUTPUT.PUT_LINE('Error during fund transfer: ' || SQLERRM);
END SafeTransferFunds;


CREATE OR REPLACE PROCEDURE AddNewCustomer (
    p_customer_id IN NUMBER,
    p_name IN VARCHAR2,
    p_balance IN NUMBER
) AS
BEGIN
    BEGIN
       
        INSERT INTO customers (customer_id, name, balance)
        VALUES (p_customer_id, p_name, p_balance);

        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Customer added successfully with ID: ' || p_customer_id);

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          
            DBMS_OUTPUT.PUT_LINE('Error: Customer ID ' || p_customer_id || ' already exists.');
            ROLLBACK;
        WHEN OTHERS THEN
          
            DBMS_OUTPUT.PUT_LINE('Error adding customer: ' || SQLERRM);
            ROLLBACK;
    END;
END AddNewCustomer;



3.
Exercise 3: Stored Procedures



CREATE OR REPLACE PROCEDURE ProcessMonthlyInterest AS
    v_account_id NUMBER;
    v_current_balance NUMBER;
BEGIN
  
    FOR account_rec IN (
        SELECT account_id, balance
        FROM accounts
        WHERE account_type = 'Savings'
    ) LOOP
        v_account_id := account_rec.account_id;
        v_current_balance := account_rec.balance;

       
        UPDATE accounts
        SET balance = v_current_balance * 1.01
        WHERE account_id = v_account_id;

        DBMS_OUTPUT.PUT_LINE('Updated balance for savings account ID: ' || v_account_id);
    END LOOP;

  
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Monthly interest processed for all savings accounts.');
EXCEPTION
    WHEN OTHERS THEN
       
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error processing monthly interest: ' || SQLERRM);
END ProcessMonthlyInterest;


CREATE OR REPLACE PROCEDURE UpdateEmployeeBonus (
    p_department_id IN NUMBER,
    p_bonus_percentage IN NUMBER
) AS
BEGIN
   
    UPDATE employees
    SET salary = salary * (1 + p_bonus_percentage / 100)
    WHERE department_id = p_department_id;

  
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Salaries updated with a bonus of ' || p_bonus_percentage || '% for department ID: ' || p_department_id);
EXCEPTION
    WHEN OTHERS THEN
      
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error updating employee bonus: ' || SQLERRM);
END UpdateEmployeeBonus;

CREATE OR REPLACE PROCEDURE TransferFunds (
    p_from_account_id IN NUMBER,
    p_to_account_id IN NUMBER,
    p_amount IN NUMBER
) AS
    v_from_balance NUMBER;
BEGIN
   
    SELECT balance INTO v_from_balance
    FROM accounts
    WHERE account_id = p_from_account_id;

    IF v_from_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds in account ' || p_from_account_id);
    END IF;

 
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_from_account_id;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_to_account_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Transferred ' || p_amount || ' from account ID: ' || p_from_account_id || ' to account ID: ' || p_to_account_id);
EXCEPTION
    WHEN OTHERS THEN
   
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error during fund transfer: ' || SQLERRM);
END TransferFunds;


4.
Exercise 4: Functions


CREATE OR REPLACE FUNCTION CalculateAge (
    p_date_of_birth DATE
) RETURN NUMBER IS
    v_current_date DATE := SYSDATE;
    v_age NUMBER;
BEGIN
    v_age := FLOOR(MONTHS_BETWEEN(v_current_date, p_date_of_birth) / 12);

    RETURN v_age;
EXCEPTION
    WHEN OTHERS THEN
     
        DBMS_OUTPUT.PUT_LINE('Error calculating age: ' || SQLERRM);
        RETURN NULL;
END CalculateAge;


CREATE OR REPLACE FUNCTION CalculateMonthlyInstallment (
    p_loan_amount NUMBER,
    p_annual_interest_rate NUMBER,
    p_loan_duration_years NUMBER
) RETURN NUMBER IS
    v_monthly_interest_rate NUMBER;
    v_total_months NUMBER;
    v_monthly_installment NUMBER;
BEGIN
    v_monthly_interest_rate := p_annual_interest_rate / 12 / 100;
    v_total_months := p_loan_duration_years * 12;

    IF v_monthly_interest_rate = 0 THEN
        v_monthly_installment := p_loan_amount / v_total_months;
    ELSE
        v_monthly_installment := p_loan_amount * (v_monthly_interest_rate * POWER(1 + v_monthly_interest_rate, v_total_months)) / (POWER(1 + v_monthly_interest_rate, v_total_months) - 1);
    END IF;

    RETURN v_monthly_installment;
EXCEPTION
    WHEN OTHERS THEN
      
        DBMS_OUTPUT.PUT_LINE('Error calculating monthly installment: ' || SQLERRM);
        RETURN NULL;
END CalculateMonthlyInstallment;


CREATE OR REPLACE FUNCTION HasSufficientBalance (
    p_account_id NUMBER,
    p_amount NUMBER
) RETURN BOOLEAN IS
    v_balance NUMBER;
BEGIN
 
    SELECT balance INTO v_balance
    FROM accounts
    WHERE account_id = p_account_id;

    IF v_balance >= p_amount THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      
        DBMS_OUTPUT.PUT_LINE('Error: Account ID ' || p_account_id || ' does not exist.');
        RETURN FALSE;
    WHEN OTHERS THEN
      
        DBMS_OUTPUT.PUT_LINE('Error checking balance: ' || SQLERRM);
        RETURN FALSE;
END HasSufficientBalance;



5.
Exercise 5: Triggers


CREATE OR REPLACE TRIGGER UpdateCustomerLastModified
BEFORE UPDATE ON Customers
FOR EACH ROW
BEGIN
    :NEW.LastModified := SYSDATE;
END UpdateCustomerLastModified;


CREATE OR REPLACE TRIGGER LogTransaction
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (TransactionID, TransactionDate, Amount, Action)
    VALUES (:NEW.TransactionID, :NEW.TransactionDate, :NEW.Amount, 'INSERT');
END LogTransaction;


CREATE OR REPLACE TRIGGER CheckTransactionRules
BEFORE INSERT ON Transactions
FOR EACH ROW
DECLARE
    v_balance NUMBER;
BEGIN
    
    IF :NEW.TransactionType = 'WITHDRAWAL' THEN
      
        SELECT balance INTO v_balance
        FROM accounts
        WHERE account_id = :NEW.AccountID;

        IF :NEW.Amount > v_balance THEN
            RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds for withdrawal.');
        END IF;


    ELSIF :NEW.TransactionType = 'DEPOSIT' THEN
   
        IF :NEW.Amount <= 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Deposit amount must be positive.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Invalid transaction type.');
    END IF;
END CheckTransactionRules;


6.
Exercise 6: Cursors


DECLARE
    CURSOR transaction_cursor IS
        SELECT customer_id, transaction_date, amount, transaction_type
        FROM transactions
        WHERE EXTRACT(MONTH FROM transaction_date) = EXTRACT(MONTH FROM SYSDATE)
          AND EXTRACT(YEAR FROM transaction_date) = EXTRACT(YEAR FROM SYSDATE);

    v_customer_id transactions.customer_id%TYPE;
    v_transaction_date transactions.transaction_date%TYPE;
    v_amount transactions.amount%TYPE;
    v_transaction_type transactions.transaction_type%TYPE;
BEGIN
    OPEN transaction_cursor;

    LOOP
        FETCH transaction_cursor INTO v_customer_id, v_transaction_date, v_amount, v_transaction_type;
        EXIT WHEN transaction_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Customer ID: ' || v_customer_id);
        DBMS_OUTPUT.PUT_LINE('Date: ' || v_transaction_date);
        DBMS_OUTPUT.PUT_LINE('Amount: ' || v_amount);
        DBMS_OUTPUT.PUT_LINE('Type: ' || v_transaction_type);
        DBMS_OUTPUT.PUT_LINE('---');

    END LOOP;

    CLOSE transaction_cursor;

    DBMS_OUTPUT.PUT_LINE('Monthly statements generated for all customers.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error generating monthly statements: ' || SQLERRM);
END GenerateMonthlyStatements;


DECLARE
    CURSOR account_cursor IS
        SELECT account_id, balance
        FROM accounts;

    v_account_id accounts.account_id%TYPE;
    v_balance accounts.balance%TYPE;
    v_annual_fee NUMBER := 50;  -- Example fee amount
BEGIN
    OPEN account_cursor;

    LOOP
        FETCH account_cursor INTO v_account_id, v_balance;
        EXIT WHEN account_cursor%NOTFOUND;

     
        UPDATE accounts
        SET balance = balance - v_annual_fee
        WHERE account_id = v_account_id;

        DBMS_OUTPUT.PUT_LINE('Applied annual fee to account ID: ' || v_account_id);

    END LOOP;

    CLOSE account_cursor;

    DBMS_OUTPUT.PUT_LINE('Annual fee applied to all accounts.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error applying annual fee: ' || SQLERRM);
END ApplyAnnualFee;


DECLARE
    CURSOR loan_cursor IS
        SELECT loan_id, current_interest_rate
        FROM loans;

    v_loan_id loans.loan_id%TYPE;
    v_current_interest_rate loans.current_interest_rate%TYPE;
    v_new_interest_rate NUMBER;
BEGIN
    OPEN loan_cursor;

    LOOP
        FETCH loan_cursor INTO v_loan_id, v_current_interest_rate;
        EXIT WHEN loan_cursor%NOTFOUND;

       
        v_new_interest_rate := v_current_interest_rate * 1.05; -- Example policy: increase by 5%

       
        UPDATE loans
        SET current_interest_rate = v_new_interest_rate
        WHERE loan_id = v_loan_id;

        DBMS_OUTPUT.PUT_LINE('Updated interest rate for loan ID: ' || v_loan_id);

    END LOOP;

    CLOSE loan_cursor;

    DBMS_OUTPUT.PUT_LINE('Interest rates updated for all loans.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating loan interest rates: ' || SQLERRM);
END UpdateLoanInterestRates;


7.
Exercise 7: Packages


CREATE OR REPLACE PACKAGE CustomerManagement AS
    PROCEDURE AddCustomer(p_customer_id IN NUMBER, p_name IN VARCHAR2, p_balance IN NUMBER);
    PROCEDURE UpdateCustomer(p_customer_id IN NUMBER, p_name IN VARCHAR2, p_balance IN NUMBER);
    FUNCTION GetCustomerBalance(p_customer_id IN NUMBER) RETURN NUMBER;
END CustomerManagement;

CREATE OR REPLACE PACKAGE BODY CustomerManagement AS

    PROCEDURE AddCustomer(p_customer_id IN NUMBER, p_name IN VARCHAR2, p_balance IN NUMBER) IS
    BEGIN
        INSERT INTO Customers (customer_id, name, balance)
        VALUES (p_customer_id, p_name, p_balance);
        DBMS_OUTPUT.PUT_LINE('Customer added: ' || p_name);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error adding customer: ' || SQLERRM);
    END AddCustomer;

    PROCEDURE UpdateCustomer(p_customer_id IN NUMBER, p_name IN VARCHAR2, p_balance IN NUMBER) IS
    BEGIN
        UPDATE Customers
        SET name = p_name, balance = p_balance
        WHERE customer_id = p_customer_id;
        DBMS_OUTPUT.PUT_LINE('Customer updated: ' || p_name);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error updating customer: ' || SQLERRM);
    END UpdateCustomer;

    FUNCTION GetCustomerBalance(p_customer_id IN NUMBER) RETURN NUMBER IS
        v_balance NUMBER;
    BEGIN
        SELECT balance INTO v_balance
        FROM Customers
        WHERE customer_id = p_customer_id;
        RETURN v_balance;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error fetching customer balance: ' || SQLERRM);
            RETURN NULL;
    END GetCustomerBalance;

END CustomerManagement;


CREATE OR REPLACE PACKAGE EmployeeManagement AS
    PROCEDURE HireEmployee(p_employee_id IN NUMBER, p_name IN VARCHAR2, p_salary IN NUMBER);
    PROCEDURE UpdateEmployee(p_employee_id IN NUMBER, p_name IN VARCHAR2, p_salary IN NUMBER);
    FUNCTION CalculateAnnualSalary(p_salary IN NUMBER) RETURN NUMBER;
END EmployeeManagement;


CREATE OR REPLACE PACKAGE BODY EmployeeManagement AS

    PROCEDURE HireEmployee(p_employee_id IN NUMBER, p_name IN VARCHAR2, p_salary IN NUMBER) IS
    BEGIN
        INSERT INTO Employees (employee_id, name, salary)
        VALUES (p_employee_id, p_name, p_salary);
        DBMS_OUTPUT.PUT_LINE('Employee hired: ' || p_name);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error hiring employee: ' || SQLERRM);
    END HireEmployee;

    PROCEDURE UpdateEmployee(p_employee_id IN NUMBER, p_name IN VARCHAR2, p_salary IN NUMBER) IS
    BEGIN
        UPDATE Employees
        SET name = p_name, salary = p_salary
        WHERE employee_id = p_employee_id;
        DBMS_OUTPUT.PUT_LINE('Employee updated: ' || p_name);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error updating employee: ' || SQLERRM);
    END UpdateEmployee;

    FUNCTION CalculateAnnualSalary(p_salary IN NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN p_salary * 12;
    END CalculateAnnualSalary;

END EmployeeManagement;


CREATE OR REPLACE PACKAGE AccountOperations AS
    PROCEDURE OpenAccount(p_account_id IN NUMBER, p_customer_id IN NUMBER, p_initial_balance IN NUMBER);
    PROCEDURE CloseAccount(p_account_id IN NUMBER);
    FUNCTION GetTotalBalance(p_customer_id IN NUMBER) RETURN NUMBER;
END AccountOperations;


CREATE OR REPLACE PACKAGE BODY AccountOperations AS

    PROCEDURE OpenAccount(p_account_id IN NUMBER, p_customer_id IN NUMBER, p_initial_balance IN NUMBER) IS
    BEGIN
        INSERT INTO Accounts (account_id, customer_id, balance)
        VALUES (p_account_id, p_customer_id, p_initial_balance);
        DBMS_OUTPUT.PUT_LINE('Account opened: ' || p_account_id);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error opening account: ' || SQLERRM);
    END OpenAccount;

    PROCEDURE CloseAccount(p_account_id IN NUMBER) IS
    BEGIN
        DELETE FROM Accounts
        WHERE account_id = p_account_id;
        DBMS_OUTPUT.PUT_LINE('Account closed: ' || p_account_id);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error closing account: ' || SQLERRM);
    END CloseAccount;

    FUNCTION GetTotalBalance(p_customer_id IN NUMBER) RETURN NUMBER IS
        v_total_balance NUMBER;
    BEGIN
        SELECT SUM(balance) INTO v_total_balance
        FROM Accounts
        WHERE customer_id = p_customer_id;
        RETURN NVL(v_total_balance, 0);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error fetching total balance: ' || SQLERRM);
            RETURN NULL;
    END GetTotalBalance;

END AccountOperations;



