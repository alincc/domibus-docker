create user domibus identified by "DOMIBUS_PASSWORD";
grant all privileges to domibus;
grant execute on dbms_xa to domibus;
grant select on pending_trans$ to domibus;
grant select on dba_2pc_pending to domibus;
grant select on dba_pending_transactions to domibus;
connect domibus/"DOMIBUS_PASSWORD"
@/docker-entrypoint-initdb.d/oracle10g-DOMIBUS_SHORT_VERSION.ddl
@/docker-entrypoint-initdb.d/oracle10g-DOMIBUS_SHORT_VERSION-data.ddl
