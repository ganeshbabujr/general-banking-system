PROMPT *-*-*-*-*-*-*-*-*-*-*  Customer Table Creation START *-*-*-*-*-*-*-*-*-*-*-*-*-*
	
DROP TABLE customer_tb;

CREATE TABLE customer_tb(customer_id 	  NUMBER
                       , account_no	      NUMBER
					   , name			  VARCHAR2(30)
					   , father_name	  VARCHAR2(30)
					   , mobile		      NUMBER
					   , gender			  VARCHAR2(10)
					   , DOB			  DATE
					   , email_id	      VARCHAR2(30)
					   , address	      VARCHAR2(100)
					   , aadhar_no	      NUMBER
					   , pan_no		      VARCHAR2(20)
					   , driving_licence  VARCHAR2(20)
					   , voter_id		  VARCHAR2(20)
					   , status			  VARCHAR2(15)
					   , PRIMARY KEY(customer_id,account_no,mobile,aadhar_no,pan_no)
					   , UNIQUE (email_id,driving_licence,voter_id)
					   , CHECK(UPPER(gender) IN('M','F')));
					   
PROMPT *-*-*-*-*-*-*-*-*-*-*  Customer Table Creation  END *-*-*-*-*-*-*-*-*-*-*-*-*-*-


PROMPT *-*-*-*-*-*-*-*-*-*-*  Accounts Table Creation START *-*-*-*-*-*-*-*-*-*-*-*-*-*

DROP TABLE accounts_tb;

CREATE TABLE accounts_tb(customer_id 	  NUMBER
                       , account_no		  NUMBER
					   , acc_main_branch  VARCHAR2(20)
                       , ifsc_code		  VARCHAR2(20)
					   , account_type	  VARCHAR2(20)
					   , current_balance  NUMBER
					   , login_id		  VARCHAR2(20)
					   , password		  VARCHAR2(15)
					   , acc_created_dttm TIMESTAMP
					   , min_bal_amount   NUMBER				
					   , status			  VARCHAR2(15));


PROMPT *-*-*-*-*-*-*-*-*-*-*  Accounts Table Creation END *-*-*-*-*-*-*-*-*-*-*-*-*-*

					   
PROMPT *-*-*-*-*-*-*-*-*-*-*  Customer Table Sequence START *-*-*-*-*-*-*-*-*-*-*-*-*-*
					   
DROP SEQUENCE cust_id_seq;

CREATE SEQUENCE cust_id_seq
START WITH 182386
MINVALUE 182386
MAXVALUE 9999999999
INCREMENT BY 1
NOCYCLE
NOCACHE;

PROMPT *-*-*-*-*-*-*-*-*-*-*  Customer Table Sequence  END *-*-*-*-*-*-*-*-*-*-*-*-*-*-

PROMPT *-*-*-*-*-*-*-*-*-*-*  Accounts Table Sequence  START *-*-*-*-*-*-*-*-*-*-*-*-*-*-

DROP SEQUENCE acc_no_seq;

CREATE SEQUENCE acc_no_seq
START WITH 5767
MINVALUE 5767
MAXVALUE 999999999
INCREMENT BY 1
NOCYCLE
NOCACHE;

DROP SEQUENCE login_seq;

CREATE SEQUENCE login_seq
START WITH 92372887
MINVALUE 92372887
MAXVALUE 999999999
INCREMENT BY 13
NOCYCLE
NOCACHE;
					   			   
PROMPT *-*-*-*-*-*-*-*-*-*-*  Accounts Table Sequence  END *-*-*-*-*-*-*-*-*-*-*-*-*-*-
																					
												
PROMPT *-*-*-*-*-*-*-*-*-*-*  Balance Table Creation  START *-*-*-*-*-*-*-*-*-*-*-*-*-*

DROP TABLE balance_tb;

CREATE TABLE balance_tb(customer_id   	NUMBER
                      , account_no		NUMBER
					  , current_balance	NUMBER);
					  																		
PROMPT *-*-*-*-*-*-*-*-*-*-*  Balance Table Creation  END *-*-*-*-*-*-*-*-*-*-*-*-*-*-*

																					
PROMPT *-*-*-*-*-*-*-*-*-*-*  Bank Table Creation  START *-*-*-*-*-*-*-*-*-*-*-*-*-

DROP TABLE icici_bank_tb;

CREATE TABLE icici_bank_tb(bank_account_no	 NUMBER
                       , ifsc_code			 VARCHAR2(20)
					   , branch				 VARCHAR2(30)
					   , bank_funds  		 NUMBER);

INSERT INTO icici_bank_tb(bank_account_no
                        , ifsc_code
                        , branch
                        , bank_funds) VALUES(112233445566
                                           , 'ICIC0002393'
                                           , 'Chennai'
                                           , 10000000);
										   						  
														
PROMPT *-*-*-*-*-*-*-*-*-*-*  Bank Table Creation  END *-*-*-*-*-*-*-*-*-*-*-*-*-*-
																					
																					
PROMPT *-*-*-*-*-*-*-*-*-*-*  Transaction Table Creation  START *-*-*-*-*-*-*-*-*-*-*-*


DROP TABLE trans_limit_tb;
					   
CREATE TABLE trans_limit_tb(account_type    	 	VARCHAR2(20)
						  , minimum_bal_main	 	NUMBER
					      , daily_trans_limit  	  	NUMBER
					      , monthly_max_trans_limit NUMBER);
						  
BEGIN
INSERT INTO trans_limit_tb(account_type    	 	
                         , minimum_bal_main	 	
                         , daily_trans_limit  	  	
                         , monthly_max_trans_limit)VALUES('SAVING'
                                                        , 5000
                                                        , 100000
														, 1000000);
INSERT INTO trans_limit_tb(account_type    	 	
                         , minimum_bal_main	 	
                         , daily_trans_limit  	  	
                         , monthly_max_trans_limit)VALUES('CURRENT'
														, 10000
														, 1000000
														, 10000000);
END;
/


DROP TABLE transaction_tb;

CREATE TABLE transaction_tb(transaction_id		VARCHAR2(30)
                          , transaction_dttm	TIMESTAMP
						  , from_account		NUMBER
						  , to_account			NUMBER
						  , transaction_type	VARCHAR2(20)
						  , transaction_mode	VARCHAR2(30)
						  , transaction_amount	NUMBER
						  , status				VARCHAR2(20));
																					
PROMPT *-*-*-*-*-*-*-*-*-*-*  Transaction Table Creation  END *-*-*-*-*-*-*-*-*-*-*-*-*
																					

PROMPT *-*-*-*-*-*-*-*-*-*-*  Transaction Table Sequence  START *-*-*-*-*-*-*-*-*-*-*-*

DROP SEQUENCE trans_id_seq;

CREATE SEQUENCE trans_id_seq
START WITH 6000
MINVALUE 6000
MAXVALUE 999999
INCREMENT BY 9
NOCYCLE
NOCACHE;

PROMPT *-*-*-*-*-*-*-*-*-*-*  Transaction Table Sequence  END *-*-*-*-*-*-*-*-*-*-*-*