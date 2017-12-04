create user edelivery identified by edelivery;  
grant all privileges to edelivery;
grant execute on dbms_xa to edelivery;
grant select on pending_trans$ to edelivery; 
grant select on dba_2pc_pending to edelivery;
grant select on dba_pending_transactions to edelivery;

connect edelivery/edelivery
--remove hardcoding and take the ddl script from the distributed sql zip
@/u01/app/oracle/scripts/setup/oracle10g-3.3.ddl

