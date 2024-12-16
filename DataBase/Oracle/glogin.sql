/*
 * glogin.sql
 * Copyright (C) 2024  <@THEDARKSTAR>
 *
 * Distributed under terms of the MIT license.
 */

define _editor=vim
set serveroutput on size 1000000
set trimspool on
set long 5000
set linesize 100
set pagesize 9999
set timing on
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
column plan_plus_exp format a80
column session_info new_value _session format a12

select s.sid ||','|| p.spid as session_info from v$session s, v$process p where p.addr = s.paddr and s.sid = (select sid from v$mystat where rownum = 1) ;

set sqlprompt '&_user.@&_connect_identifier. &_session. SQL> '


-- vim:et
