CREATE OR REPLACE PROCEDURE icici_withdraw_deposit_sp(p_account_no      IN  accounts_tb.account_no%TYPE
													, p_transaction_typ IN  VARCHAR2
													, p_amount	        IN  accounts_tb.current_balance%TYPE
													, p_status	        OUT VARCHAR2
													, p_err_msg			OUT VARCHAR2)
AS
	v_old_amount 	NUMBER;
	v_account_no 	NUMBER;
	v_withdraw   	NUMBER;
	v_deposit    	NUMBER;
	v_trans_id   	VARCHAR2(30);
	v_trans_typ1 	VARCHAR2(10);
	v_trans_mode 	VARCHAR2(30);
	v_from_acct  	NUMBER;
	v_to_acct   	NUMBER;
	v_acct_status	VARCHAR2(15);
	v_min_bal		NUMBER;
	v_alt_cur_bal	NUMBER;
	acct_inact_ex	EXCEPTION;
	tran_typ_ex  	EXCEPTION;
	tran_typ_ex1 	EXCEPTION;
	limit_ex     	EXCEPTION;
	amount_ex    	EXCEPTION;
		
BEGIN
	
	SELECT account_no, current_balance, status, min_bal_amount
	  INTO v_account_no, v_old_amount, v_acct_status, v_min_bal
	  FROM accounts_tb
	WHERE account_no = p_account_no;
	
	IF v_acct_status = 'INACTIVE' THEN
		RAISE acct_inact_ex;
	END IF;
	
	SELECT 'IMPS' || trans_id_seq.NEXTVAL INTO v_trans_id FROM dual;
	
	IF UPPER(p_transaction_typ) NOT IN ('W','D') THEN
		RAISE tran_typ_ex;
	END IF;
	
	IF p_transaction_typ IS NULL THEN
		RAISE tran_typ_ex1;
	END IF;
	IF p_amount IS NULL THEN
		RAISE amount_ex;
	END IF;
	
	v_alt_cur_bal := v_old_amount - v_min_bal;
	
	IF p_amount > v_alt_cur_bal AND UPPER(p_transaction_typ) ='W' THEN
		RAISE limit_ex;
	END IF;
	
	v_withdraw := v_old_amount - p_amount;
	v_deposit  := v_old_amount + p_amount;
	
		
	IF UPPER(p_transaction_typ) ='W' THEN
	   UPDATE balance_tb
	     SET current_balance = v_withdraw
	   WHERE account_no = p_account_no;
	ELSE
		UPDATE balance_tb
	     SET current_balance = v_deposit
	   WHERE account_no = p_account_no;
	END IF;
	
	IF UPPER(p_transaction_typ) ='W' THEN
		v_trans_typ1 := 'DEBIT';
		v_trans_mode := 'ATM Cash Withdrawal';
	    v_from_acct  := v_account_no;
		v_to_acct    := NULL;
	ELSE
		v_trans_typ1 := 'CREDIT';
		v_trans_mode := 'ATM Cash Deposit';
        v_from_acct  := NULL;
		v_to_acct    := v_account_no;
	END IF;
	
	INSERT INTO transaction_tb(transaction_id		
	                         , transaction_dttm	
	                         , from_account		
	                         , to_account			
	                         , transaction_type	
							 , transaction_mode
	                         , transaction_amount	
	                         , status)VALUES(v_trans_id
                                            , SYSTIMESTAMP
											, v_from_acct
											, v_to_acct
											, v_trans_typ1
											, v_trans_mode
											, p_amount
											, 'SUCCESS');
											
	UPDATE accounts_tb a
	  SET a.current_balance = (SELECT b.current_balance FROM balance_tb b WHERE b.account_no = a.account_no)
	WHERE a.account_no = p_account_no;
		
	IF UPPER(p_transaction_typ) ='W' THEN
		p_status := 'Cash Debited Sucessfully Please Collect Your cash';
	ELSE
		p_status := 'Cash Debosited To Your Account Sucessfully';
	END IF;
	
	p_err_msg := '-';
	
	COMMIT;
	
EXCEPTION
		WHEN no_data_found THEN
			p_status := 'Fail';
			p_err_msg := 'Enter valid Account Number';
		WHEN acct_inact_ex THEN
			p_status := 'Fail';
			p_err_msg := 'Your Account is Inactive Transaction Not Possible';
		WHEN tran_typ_ex1 THEN
			p_status := 'Fail';
			p_status := 'Transaction Type is Mandatory';
		WHEN tran_typ_ex THEN
			p_status := 'Fail';
			p_status := 'Transaction Should be W / D';
		WHEN amount_ex THEN
			p_status := 'Fail';
			p_status := 'Amount is Mandatory';
		WHEN limit_ex THEN
			p_status := 'Fail';
			p_status := 'Minimum Balance Cannot Withdraw';
			
END icici_withdraw_deposit_sp;
/