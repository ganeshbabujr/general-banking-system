CREATE OR REPLACE PROCEDURE icici_transaction_sp (p_from_account 	IN accounts_tb.account_no%TYPE
												, p_to_account   	IN accounts_tb.account_no%TYPE
												, p_transfer_amount IN NUMBER
												, p_status 	   		OUT VARCHAR2
												, p_err_msg 	  	OUT VARCHAR2)
AS
v_from_account_no 		accounts_tb.account_no%TYPE;
v_from_account_type     accounts_tb.account_type%TYPE;
v_from_current_balance  accounts_tb.current_balance%TYPE;
v_from_min_bal_amount   accounts_tb.min_bal_amount%TYPE;
v_from_status        	accounts_tb.status%TYPE;  
v_to_account_no 		accounts_tb.account_no%TYPE;
v_to_account_type       accounts_tb.account_type%TYPE;
v_to_current_balance    accounts_tb.current_balance%TYPE;
v_to_min_bal_amount     accounts_tb.min_bal_amount%TYPE;
v_to_status             accounts_tb.status%TYPE;  
v_act_lmt_typ			trans_limit_tb.account_type%TYPE;
v_act_min_bal           trans_limit_tb.minimum_bal_main%TYPE;
v_act_day_lmt           trans_limit_tb.daily_trans_limit%TYPE;
v_act_mon_lmt           trans_limit_tb.monthly_max_trans_limit%TYPE;	
v_mon_trans_hst			NUMBER;	
v_alt_frm_current_bal	NUMBER;
v_amount_debt  			NUMBER;
v_amount_credit			NUMBER;
v_trans_id				VARCHAR2(30);
v_day_trans_count		NUMBER;
v_day_trans_hist    	NUMBER;
time_lmt_ex				EXCEPTION;
from_acct_null_ex		EXCEPTION;
to_acct_null_ex			EXCEPTION;
trans_amt_null_ex		EXCEPTION;
day_lmt_ex				EXCEPTION;
day_trns_lmt_ex			EXCEPTION;
mon_trns_lmt_ex			EXCEPTION;
self_trans_ex			EXCEPTION;
minbal_ex				EXCEPTION;
from_acct_ex			EXCEPTION;
to_acct_ex				EXCEPTION;

                    
BEGIN


	SELECT account_no
	     , account_type
		 , current_balance
		 , min_bal_amount
		 , status
	  INTO v_from_account_no 
	     , v_from_account_type
         , v_from_current_balance
         , v_from_min_bal_amount
		 , v_from_status
	  FROM accounts_tb
	WHERE account_no = p_from_account;
	
	SELECT account_no
	     , account_type
		 , current_balance
		 , min_bal_amount
		 , status
	  INTO v_to_account_no 
	     , v_to_account_type
         , v_to_current_balance
         , v_to_min_bal_amount
		 , v_to_status
	  FROM accounts_tb
	WHERE account_no = p_to_account;
			
	IF p_from_account IS NULL THEN
		RAISE from_acct_null_ex;
	END IF;
	
	IF p_to_account IS NULL THEN
		RAISE to_acct_null_ex;
	END IF;
	
	IF p_transfer_amount IS NULL THEN
		RAISE trans_amt_null_ex;
	END IF;
	
	IF p_from_account = p_to_account THEN
		RAISE self_trans_ex;
	END IF;
	
	IF v_from_status <> 'ACTIVE' THEN
		RAISE from_acct_ex;
	END IF;
	
	IF v_to_status <> 'ACTIVE' THEN
		RAISE to_acct_ex;
	END IF;
	
	IF TO_CHAR(SYSDATE,'HH24:MM') NOT BETWEEN '09:01' AND '17:00' THEN
     RAISE time_lmt_ex;
	END IF;
	
	SELECT COUNT(*) 
	  INTO v_day_trans_count
	  FROM transaction_tb
	WHERE from_account = p_from_account
	  AND transaction_type = 'DEBIT'
      AND TO_CHAR(transaction_dttm,'DDMMYYYY') = TO_CHAR(SYSDATE,'DDMMYYYY');
		
	IF v_day_trans_count >= 5 THEN
		RAISE day_lmt_ex;
	END IF;
	
	
	
	SELECT 'IMPS' || trans_id_seq.NEXTVAL INTO v_trans_id FROM dual;
	
	SELECT account_type
		 , minimum_bal_main
		 , daily_trans_limit
		 , monthly_max_trans_limit
	  INTO v_act_lmt_typ
	     , v_act_min_bal
	     , v_act_day_lmt
		 , v_act_mon_lmt
	FROM trans_limit_tb
	WHERE account_type = v_from_account_type;
	
	SELECT SUM(transaction_amount)
	  INTO v_day_trans_hist
	  FROM transaction_tb
	WHERE from_account = p_from_account
	AND transaction_type = 'DEBIT'
	AND TO_CHAR(transaction_dttm,'DDMMYYYY') = TO_CHAR(SYSDATE,'DDMMYYYY');
	
	SELECT SUM(transaction_amount)
	  INTO v_mon_trans_hst
       FROM transaction_tb
    WHERE from_account = p_from_account
      AND transaction_type = 'DEBIT'
      AND TO_CHAR(transaction_dttm,'MMYYYY') = TO_CHAR(SYSDATE,'MMYYYY');
	  
	  
	
----------------- Restrict Daily Transaction Limit START -----------------
	
	IF (v_day_trans_hist + p_transfer_amount) > v_act_day_lmt THEN
		RAISE day_trns_lmt_ex;
	END IF;
	
----------------- Restrict Daily Transaction Limit END ---------------------	


----------------- Restrict Monthly Transaction Limit START -----------------

	IF (v_mon_trans_hst + p_transfer_amount) > v_act_mon_lmt THEN
		RAISE mon_trns_lmt_ex;
	END IF;

----------------- Restrict Monthly Transaction Limit END -------------------
						
	v_alt_frm_current_bal := v_from_current_balance - v_from_min_bal_amount;
		
	IF v_alt_frm_current_bal < p_transfer_amount THEN
		RAISE minbal_ex;
	END IF; 
	 
/*	 
---------  Debit 500 for each Daily transaction limit exceeds START ---------------------------
	
	 IF (v_day_trans_hist + p_transfer_amount) > v_act_day_lmt THEN			
			v_amount_debt   :=  (v_from_current_balance  - p_transfer_amount) - 500;
		
		UPDATE icici_bank_tb
		   SET bank_funds = bank_funds + 500;
		
		INSERT INTO transaction_tb(transaction_id
                                 , transaction_dttm	
						         , from_account
						         , to_account
						         , transaction_type
						         , transaction_mode
						         , transaction_amount
						         , status) VALUES(v_trans_id
										        , SYSTIMESTAMP
											     , v_from_account_no
											     , 112233445566
											     , 'DEBIT'
											     , 'Online'
											     , 500
											     , 'SUCCESS');
		
		INSERT INTO transaction_tb(transaction_id
                                 , transaction_dttm	
						         , from_account
						         , to_account
						         , transaction_type
						         , transaction_mode
						         , transaction_amount
						         , status) VALUES(v_trans_id
										        , SYSTIMESTAMP
											    , v_from_account_no
											    , 112233445566
											    , 'CREDIT'
											    , 'Online'
											    , 500
											    , 'SUCCESS');
			
				
	ELSE 
			v_amount_debt   :=  v_from_current_balance  - p_transfer_amount;
	END IF;

---------  Debit 500 for each trans limit exceeds END ----------------------------	
*/	
	
	v_amount_debt   :=  v_from_current_balance  - p_transfer_amount;	--  Disable to Debit 500
	 
	v_amount_credit := p_transfer_amount + v_to_current_balance;
	
	UPDATE accounts_tb
	  SET current_balance = v_amount_debt
	WHERE account_no = p_from_account;
	
	UPDATE accounts_tb
	  SET current_balance = v_amount_credit
	WHERE account_no = p_to_account;
	
	UPDATE balance_tb
	  SET current_balance = v_amount_debt
	 WHERE account_no = p_from_account;
	
	UPDATE balance_tb
	  SET current_balance = v_amount_credit
	 WHERE account_no = p_to_account;
		
	INSERT INTO transaction_tb(transaction_id
                             , transaction_dttm	
						     , from_account
						     , to_account
						     , transaction_type
						     , transaction_mode
						     , transaction_amount
						     , status) VALUES(v_trans_id
							                , SYSTIMESTAMP
											, v_from_account_no
											, v_to_account_no
											, 'DEBIT'
											, 'Online'
											, p_transfer_amount
											, 'SUCCESS');
	
	INSERT INTO transaction_tb(transaction_id
                             , transaction_dttm	
						     , from_account
						     , to_account
						     , transaction_type
						     , transaction_mode
						     , transaction_amount
						     , status) VALUES(v_trans_id
							                , SYSTIMESTAMP
											, v_from_account_no
											, v_to_account_no
											, 'CREDIT'
											, 'Online'
											, p_transfer_amount
											, 'SUCCESS');
			 
	COMMIT;	 
	
	p_status := 'Success';
	
EXCEPTION
	WHEN no_data_found THEN
		p_status  :=  'F'; 
		p_err_msg :=  'Enter a Valid Account Number'; 
	WHEN from_acct_ex  THEN
		p_status  :=  'F'; 
		p_err_msg :=  'Your Account is Inavctive Transaction Not Possible';
	WHEN from_acct_null_ex 	THEN
		p_status  :=  'F'; 
		p_err_msg :=  'From Account is Mandatory';
	WHEN to_acct_null_ex THEN
		p_status  :=  'F'; 
		p_err_msg :=  'Beneficiary Account is Mandatory';
	WHEN trans_amt_null_ex 	THEN
		p_status  :=  'F'; 
		p_err_msg :=  'Amount is Mandatory';
	WHEN self_trans_ex 	THEN
		p_status  :=  'F'; 
		p_err_msg :=  'Self Transfer Not Possible';
	WHEN day_lmt_ex    THEN
		p_status  :=  'F'; 
		p_err_msg :=  'You have Exceeded your Daily Transaction Limit';
	WHEN day_trns_lmt_ex THEN
		p_status  :=  'F'; 
		p_err_msg :=  'Your Daily Limit : '   || v_act_day_lmt || ' Exceeded';
	WHEN mon_trns_lmt_ex THEN
		p_status  :=  'F'; 
		p_err_msg :=  'Your Monthly Limit : ' || v_act_mon_lmt || ' Exceeded';
	WHEN minbal_ex 	   THEN
		p_status  :=  'F'; 
		p_err_msg :=  'Minimum Balance Cannot Transfer';
	WHEN to_acct_ex    THEN
		p_status  :=  'F'; 
		p_err_msg :=  'Beneficiary Account is Inactive Transaction Not Possible';
	WHEN time_lmt_ex THEN
		p_status  :=  'F'; 
		p_err_msg :=  'Transaction Not Possible in Non Business Hours';
		 
END icici_transaction_sp;
/