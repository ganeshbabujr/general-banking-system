CREATE OR REPLACE PROCEDURE icici_transaction_report_sp(p_account_no IN transaction_tb.from_account%TYPE
													  , p_status	 OUT VARCHAR2
													  , p_err_msg 	 OUT VARCHAR2)
AS
v_file UTL_FILE.FILE_TYPE;
v_file_name 		VARCHAR2(60) 	:= 'ICICI_Bank_Statement' || '_' || TO_CHAR(SYSDATE,'Mon_YYYY') || '_' || p_account_no || '.txt' ;
v_header 			VARCHAR2(80) 	:= 'ICICI_Bank'	|| '_' ||'Statement_' ||  TO_CHAR(SYSDATE,'Mon_YYYY');
v_acct				VARCHAR2(50)	:= 'Account Number : ' || p_account_no;
v_footer 			VARCHAR2(50) 	:= 'End_Of_The_Statement';
v_data 				VARCHAR2(300);
v_column_name 		VARCHAR2(200);
v_count 			NUMBER := 0;
v_customer_id 	 	NUMBER;
v_account_no		NUMBER;
v_acc_main_branch 	VARCHAR2(30);
v_ifsc_code			VARCHAR2(30);
v_account_type	 	VARCHAR2(30);
v_status			VARCHAR2(30);
v_name				VARCHAR2(30);
v_mobile			NUMBER;
v_email				VARCHAR2(30);
v_debit_amt			NUMBER;
v_credit_amt		NUMBER;

CURSOR rbi_trans_c
IS
SELECT transaction_id
     , transaction_dttm
	 , from_account
	 , to_account
	 , transaction_type
	 , transaction_mode
	 , transaction_amount
	 , status
  FROM transaction_tb
 WHERE from_account	= p_account_no;
  
BEGIN

	SELECT customer_id 	 	 
         , account_no		 
		 , acc_main_branch 
         , ifsc_code		 
		 , account_type	 
		 , status
      INTO v_customer_id 	 			
	     , v_account_no		
	     , v_acc_main_branch 
	     , v_ifsc_code		
	     , v_account_type	 
	     , v_status
	  FROM accounts_tb
	WHERE account_no = p_account_no;
	
	
	SELECT name
	     , mobile
		 , email_id
	  INTO v_name
	     , v_mobile
		 , v_email
	   FROM customer_tb
	WHERE account_no = p_account_no;
	
	
	SELECT SUM(transaction_amount)
	  INTO v_debit_amt
	  FROM transaction_tb
	WHERE transaction_type ='DEBIT'
	  AND from_account = p_account_no;
	  
	SELECT SUM(transaction_amount)
	  INTO v_credit_amt
	  FROM transaction_tb
	WHERE transaction_type ='CREDIT'
	  AND from_account = p_account_no;
		
	v_file := UTL_FILE.FOPEN('UTL_DIR',v_file_name,'W');
	UTL_FILE.PUT_LINE(v_file,LPAD(' ',60,' ') 	 	||	v_header);
	UTL_FILE.PUT_LINE(v_file,'Name            : ' 	||  v_name);
	UTL_FILE.PUT_LINE(v_file,'Mobile          : ' 	||  v_mobile);
	UTL_FILE.PUT_LINE(v_file,'Email           : ' 	||  v_email);
	UTL_FILE.PUT_LINE(v_file,'Customer_id     : ' 	||  v_customer_id);	
	UTL_FILE.PUT_LINE(v_file,'Account Number  : ' 	||	v_account_no);
	UTL_FILE.PUT_LINE(v_file,'IFSC Code       : ' 	||  v_ifsc_code);
	UTL_FILE.PUT_LINE(v_file,'Branch          : ' 	||  v_acc_main_branch);
	UTL_FILE.PUT_LINE(v_file,'Account Type    : '  	||	v_account_type);
	UTL_FILE.PUT_LINE(v_file,'Account Status  : ' 	|| 	v_status);
	
	/*FOR i IN (SELECT column_name FROM user_tab_columns WHERE table_name = 'TRANSACTION_TB')
	LOOP
		v_column_name :=	v_column_name || RPAD(i.column_name,20,' ');
	END LOOP;
	
	UTL_FILE.PUT_LINE(v_file,v_column_name);
				    
	*/
	
	UTL_FILE.PUT_LINE(v_file,RPAD('-',166,'-'));
	
	UTL_FILE.PUT_LINE(v_file,
	                  RPAD('TRANSACTION_ID',19,' ')		||
					  RPAD('TRANSACTION_DATE',35,' ')   ||
					  RPAD('FROM_ACCOUNT',20,' ')	    ||
					  RPAD('TO_ACCOUNT',20,' ')	        ||
					  RPAD('TRANSACTION_TYPE',20,' ')   ||
					  RPAD('TRANSACTION_MODE',23,' ')   ||
					  RPAD('TRANSACTION_AMOUNT',22,' ') ||
					  RPAD('STATUS',10, ' '));		 
					  		  
	
	UTL_FILE.PUT_LINE(v_file,RPAD('-',166,'-'));
	
	FOR i IN rbi_trans_c
	LOOP
		v_data := RPAD(i.transaction_id,19,' ')						||
                  RPAD(i.transaction_dttm,35,' ')   				||
	              RPAD(NVL(TO_CHAR(i.from_account),'Nil'),20,' ') 	||
	              RPAD(NVL(TO_CHAR(i.to_account),'Nil'),20,' ')   	||
	              RPAD(i.transaction_type,20,' ')   				||
	              RPAD(i.transaction_mode,23,' ')   				||
	              RPAD(i.transaction_amount,22,' ') 				||
	              RPAD(i.status,10,' ');            
	UTL_FILE.PUT_LINE(v_file,v_data);			  
	v_count := v_count+1;
	END LOOP;  
	
	UTL_FILE.PUT_LINE(v_file,RPAD('-',166,'-'));
		
	UTL_FILE.PUT_LINE(v_file,'Total No of Transactions :  ' ||  v_count);
	UTL_FILE.PUT_LINE(v_file,'Total Amount Credited    :  ' || 	NVL(v_credit_amt,0));
	UTL_FILE.PUT_LINE(v_file,'Total Amount Debited     :  ' || 	NVL(v_debit_amt,0));
	UTL_FILE.PUT_LINE(v_file,LPAD(' ',60,' ') || v_footer);
	UTL_FILE.FCLOSE(v_file);	
	
	p_status := 'SUCCESS';
	
END icici_transaction_report_sp;
/
