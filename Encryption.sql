-- --------------------------------------------

USE BMS;

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'BMS@6210';
GO

-- Verify that the master key exists
-- SELECT name KeyName,
-- symmetric_key_id KeyID,
-- key_length KeyLength,
-- algorithm_desc KeyAlgorithm
-- FROM sys.symmetric_keys;

-- Create a Certificate
CREATE CERTIFICATE SalaryCert
WITH SUBJECT = 'Employee Salary Encryption';
GO

-- drop certificate SalaryCert;

-- Create a Symmetric Key
CREATE SYMMETRIC KEY SalaryKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE SalaryCert;
GO

-- drop symmetric key SalaryKey

ALTER TABLE Employee
ALTER COLUMN salary VARBINARY(400);
GO

-- open the symmetric key with which to encrypt the data
OPEN SYMMETRIC KEY SalaryKey
DECRYPTION BY CERTIFICATE SalaryCert;


UPDATE Employee
SET salary = EncryptByKey(Key_GUID('SalaryKey'), CONVERT(VARBINARY,salary));

CLOSE SYMMETRIC KEY SalaryKey;
GO

OPEN SYMMETRIC KEY SalaryKey
DECRYPTION BY CERTIFICATE SalaryCert;

SELECT emp_first_name, emp_last_name, 
       CONVERT(DECIMAL,DecryptByKey(salary)) AS DecryptedSalary
FROM Employee;

CLOSE SYMMETRIC KEY SalaryKey;
GO