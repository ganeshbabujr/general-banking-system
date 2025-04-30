   CREATE OR REPLACE PROCEDURE icici_account_creation_sp(p_customer_id     OUT customer_tb.customer_id%TYPE
													, p_account_no      OUT	customer_tb.account_no%TYPE
													, p_ifsc_code		OUT icici_bank_tb.ifsc_code%TYPE
													, p_name 		     IN customer_tb.name%TYPE
                                                    , p_father_name      IN customer_tb.father_name%TYPE
													, p_mobile		     IN customer_tb.mobile%TYPE
													, p_gender		     IN customer_tb.gender%TYPE
													, p_dob				 IN customer_tb.DOB%TYPE
													, p_email_id         IN customer_tb.email_id%TYPE
													, p_address		     IN customer_tb.address%TYPE
													, p_aadhar_no	     IN customer_tb.aadhar_no%TYPE
													, p_pan_no		     IN customer_tb.pan_no%TYPE
													, p_driving_licence  IN customer_tb.driving_licence%TYPE
													, p_voter_id 		 IN customer_tb.voter_id%TYPE
													, p_account_type	 IN accounts_tb.account_type%TYPE
													, p_min_bal_amount   IN accounts_tb.min_bal_amount%TYPE
													, p_status			OUT VARCHAR2
													, p_err_msg 		OUT VARCHAR2)
AS

v_login			VARCHAR2(30);
v_password  	VARCHAR2(30);
v_acc_branch	VARCHAR2(30);
v_trans_id		VARCHAR2(30);
name_ex 		EXCEPTION;
fname_ex		EXCEPTION;
mobile_ex 		EXCEPTION;
mobile_ex1  	EXCEPTION;
gender_ex   	EXCEPTION;
gender_ex1  	EXCEPTION;
dob_ex			EXCEPTION;
address_ex  	EXCEPTION;
aadhar_ex   	EXCEPTION;
aadhar_ex1  	EXCEPTION;
pan_no_ex   	EXCEPTION;
pan_no_ex1  	EXCEPTION; 
kyc_ex      	EXCEPTION;
acc_typ_ex  	EXCEPTION;
acc_typ_ex1 	EXCEPTION;
min_bal_ex  	EXCEPTION;
min_bal_ex1 	EXCEPTION;
min_bal_ex2		EXCEPTION;
   

BEGIN
	IF p_name IS NULL THEN
		RAISE name_ex;
	END IF;
	
	IF p_father_name IS NULL THEN
		RAISE fname_ex;
	END IF;
	
	IF p_mobile IS NULL THEN
		RAISE mobile_ex;
	END IF;
	
	IF LENGTH(p_mobile) <> 10 THEN
		RAISE mobile_ex1;
	END IF;
	
	IF p_gender IS NULL THEN
		RAISE gender_ex1;
	END IF;
	
	IF UPPER(p_gender) NOT IN ('M','F') THEN
		RAISE gender_ex;
	END IF;
	
	IF p_dob IS NULL THEN
		RAISE dob_ex;
	END IF;
	
	IF p_address IS NULL THEN
		RAISE address_ex;
	END IF;
		
	IF p_aadhar_no IS NULL THEN
		RAISE aadhar_ex;
	END IF;
	
	IF LENGTH(p_aadhar_no) <> 12 THEN
		RAISE aadhar_ex1;
	END IF;
			
	IF p_pan_no IS NULL THEN
		RAISE pan_no_ex;
	END IF;
	
	IF LENGTH(p_pan_no) <> 10 THEN
		RAISE pan_no_ex1;
	END IF;
	
	IF p_driving_licence IS NULL AND p_voter_id IS NULL THEN
		RAISE kyc_ex;
	END IF;
	
	IF p_account_type IS NULL THEN
		RAISE acc_typ_ex;
	END IF;
	
	IF UPPER(p_account_type) NOT IN ('SAVING','CURRENT') THEN
		RAISE acc_typ_ex1;
	END IF;
	
	IF p_min_bal_amount IS NULL THEN
		RAISE min_bal_ex;
	END IF;
	
	IF p_account_type = 'SAVING' AND p_min_bal_amount<5000 THEN
		RAISE min_bal_ex1;
	END IF;
	
	IF p_account_type = 'CURRENT' AND p_min_bal_amount<10000 THEN
		RAISE min_bal_ex2;
	END IF;
	
	SELECT 6 || LPAD(cust_id_seq.NEXTVAL,5,0) INTO p_customer_id FROM dual;
	
	SELECT 1040 || LPAD(acc_no_seq.NEXTVAL,11,0) INTO p_account_no FROM dual;
	
	SELECT ifsc_code INTO p_ifsc_code FROM icici_bank_tb;
	
	SELECT SUBSTR(p_account_type,1,1) || login_seq.NEXTVAL INTO v_login FROM dual;
	
	SELECT DBMS_RANDOM.STRING('A',10) INTO v_password FROM DUAL;
	
	SELECT branch INTO v_acc_branch FROM icici_bank_tb;
	
	SELECT 'IMPS' || trans_id_seq.NEXTVAL INTO v_trans_id FROM dual;
	
	INSERT INTO customer_tb(customer_id
	                      , account_no
	                      , name	
	                      , father_name
	                      , mobile
						  , gender
						  , DOB
	                      , email_id    
	                      , address 
	                      , aadhar_no	    
	                      , pan_no 
	                      , driving_licence
	                      , voter_id		
	                      , status) VALUES(p_customer_id
                                         , p_account_no	
										 , p_name
										 , p_father_name    
										 , p_mobile	
										 , UPPER(p_gender)
										 , p_dob
										 , p_email_id       
										 , p_address		   
										 , p_aadhar_no	   
										 , p_pan_no		   
										 , p_driving_licence
										 , p_voter_id 		
										 , 'ACTIVE');
	
	INSERT INTO accounts_tb(customer_id 	 
						  ,	account_no	
                    	  , acc_main_branch				  
						  , ifsc_code		 			 
						  , account_type	 			 
	                      , current_balance 
	                      , login_id		 
	                      , password		 
	                      , acc_created_dttm
	                      , min_bal_amount 
	                      , status)	VALUES(p_customer_id
						                 , p_account_no
										 , v_acc_branch
										 , p_ifsc_code
										 , UPPER(p_account_type)
										 , p_min_bal_amount
										 , v_login
										 , v_password
										 , SYSTIMESTAMP
										 , p_min_bal_amount
										 , 'ACTIVE');
										 
	INSERT INTO balance_tb(customer_id
                         , account_no
						 , current_balance) VALUES(p_customer_id
						                         , p_account_no
												 , p_min_bal_amount);
												 
	INSERT INTO transaction_tb(transaction_id
	                        ,  transaction_dttm
	                        ,  from_account
	                        ,  to_account
	                        ,  transaction_type
	                        ,  transaction_mode
	                        ,  transaction_amount
	                        ,  status) VALUES(v_trans_id
                                            , SYSTIMESTAMP
											, NULL
											, p_account_no
											, 'CREDIT'
											, 'Minimum Amount'
											, p_min_bal_amount
											, 'SUCCESS');
											 
	
	p_status  := 'Account Created Sucessfully';
	p_err_msg := '-';
	
	COMMIT;
EXCEPTION
	WHEN name_ex THEN
		p_status  := 'Fail';
	    p_err_msg := 'Customer Name is Mandatory';
	WHEN fname_ex THEN
		p_status  := 'Fail';
	    p_err_msg := 'Customer Fathe Name is Mandatory';
	WHEN mobile_ex THEN
		p_status  := 'Fail';
	    p_err_msg := 'Customer Mobile is Mandatory';
	WHEN mobile_ex1 THEN
		p_status  := 'Fail';
	    p_err_msg := 'Enter a Valid Mobile Number';
	WHEN gender_ex1 THEN
		p_status  := 'Fail';
	    p_err_msg := 'Gender M / F is Mandatory';
	WHEN gender_ex THEN
		p_status  := 'Fail';
	    p_err_msg := 'Enter a Valid Gender M / F';
	WHEN dob_ex THEN
		p_status  := 'Fail';
	    p_err_msg := 'Date of Birth is Mandatory';
	WHEN address_ex THEN
		p_status  := 'Fail';
	    p_err_msg := 'Customer Address is Mandatory';
	WHEN aadhar_ex THEN
		p_status  := 'Fail';
	    p_err_msg := 'Customer Aadhar Number is Mandatory';
	WHEN aadhar_ex1 THEN
		p_status  := 'Fail';
	    p_err_msg := 'Enter a Valid Aadhar Number';
	WHEN pan_no_ex THEN
		p_status  := 'Fail';
	    p_err_msg := 'Customer PAN is Mandatory';
	WHEN pan_no_ex1 THEN
		p_status  := 'Fail';
	    p_err_msg := 'Enter Valid PAN Number';
	WHEN kyc_ex THEN
		p_status  := 'Fail';
	    p_err_msg := 'Driving Licence OR Voter_Id is Mandatory';
	WHEN acc_typ_ex THEN
		p_status  := 'Fail';
	    p_err_msg := 'Account Type is Mandatory';
	WHEN acc_typ_ex1 THEN
		p_status  := 'Fail';
	    p_err_msg := 'Account Type Should be SAVING / CURRENT';
	WHEN min_bal_ex THEN
		p_status  := 'Fail';
	    p_err_msg := 'Minimum Balance is Mandatory';
	WHEN min_bal_ex1 THEN
		p_status  := 'Fail';
	    p_err_msg := 'Minimum Balance should be 5000 for Savings Account';
	WHEN min_bal_ex2 THEN
		p_status  := 'Fail';
	    p_err_msg := 'Minimum Balance should be 10000 for Current Account ';
END icici_account_creation_sp;
/