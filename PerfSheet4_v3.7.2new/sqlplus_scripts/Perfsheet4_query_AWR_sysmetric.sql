--
-- Perfsheet4's query to extract data in html format
-- Perfsheet4_query_AWR_sysmetric.sql -> Extracts data from dba_hist_sysmetric_summary 
-- output is in csv format
-- Luca Canali, Oct 2012
--

-- Usage:
--   Run the script from sql*plus connected as a priviledged user (need to be able to read AWR tables)
--   Can run it over sql*net from client machine or locally on db server
--   Customize the file perfsheet4_definitions.sql before running this, in particular define there the interval of analysis

@@Perfsheet4_definitions.sql

set termout on
prompt 
prompt Dumping AWR data to file Perfsheet4_AWR_sysmetric_&myfilesuffix..csv, please wait
prompt 
set termout off

col METRIC_NAME_UNIT for a75
-- reduce white space waste by sql*plus, the calculated max length for this on 11.2.0.3 is 73

spool Perfsheet4_AWR_sysmetric_&myfilesuffix..csv

select cast(min(sn.begin_interval_time) over (partition by sn.dbid,sn.snap_id) as date) snap_time,  --workaround to uniform snap_time over all instances in RAC
	--ss.dbid,  --uncomment if you have multiple dbid in your AWR
	sn.instance_number,
	ss.metric_name||' - '||ss.metric_unit metric_name_unit,
	ss.maxval,
	ss.average,
	ss.standard_deviation
from dba_hist_sysmetric_summary ss,
     dba_hist_snapshot sn
where
  sn.snap_id = ss.snap_id
 and sn.dbid = ss.dbid
 and sn.instance_number = ss.instance_number
 and sn.begin_interval_time &delta_time_where_clause
 --and (
 --     sn.begin_interval_time between to_date('23-FEB-15 07:01:00','DD-MON-YY HH24:MI:SS') and to_date('23-FEB-15 18:01:00','DD-MON-YY HH24:MI:SS')
 --OR   sn.begin_interval_time between to_date('24-FEB-15 07:01:00','DD-MON-YY HH24:MI:SS') and to_date('24-FEB-15 18:01:00','DD-MON-YY HH24:MI:SS')
 --OR   sn.begin_interval_time between to_date('25-FEB-15 07:01:00','DD-MON-YY HH24:MI:SS') and to_date('25-FEB-15 18:01:00','DD-MON-YY HH24:MI:SS')
 --OR   sn.begin_interval_time between to_date('26-FEB-15 07:01:00','DD-MON-YY HH24:MI:SS') and to_date('26-FEB-15 18:01:00','DD-MON-YY HH24:MI:SS')
 --OR   sn.begin_interval_time between to_date('27-FEB-15 07:01:00','DD-MON-YY HH24:MI:SS') and to_date('27-FEB-15 18:01:00','DD-MON-YY HH24:MI:SS')
 --OR   sn.begin_interval_time between to_date('25-MAR-15 07:01:00','DD-MON-YY HH24:MI:SS') and to_date('25-MAR-15 18:01:00','DD-MON-YY HH24:MI:SS')
 --OR   sn.begin_interval_time between to_date('26-MAR-15 07:01:00','DD-MON-YY HH24:MI:SS') and to_date('26-MAR-15 18:01:00','DD-MON-YY HH24:MI:SS')
 --OR   sn.begin_interval_time between to_date('27-MAR-15 07:01:00','DD-MON-YY HH24:MI:SS') and to_date('27-MAR-15 18:01:00','DD-MON-YY HH24:MI:SS')
 --OR   sn.begin_interval_time between to_date('30-MAR-15 07:01:00','DD-MON-YY HH24:MI:SS') and to_date('30-MAR-15 18:01:00','DD-MON-YY HH24:MI:SS')
 --OR   sn.begin_interval_time between to_date('31-MAR-15 07:01:00','DD-MON-YY HH24:MI:SS') and to_date('31-MAR-15 18:01:00','DD-MON-YY HH24:MI:SS'))
 --and ss.metric_name = 'SQL Service Response Time'
 --and ss.metric_name = 'Response Time Per Txn'
 --and ss.metric_name = 'CPU Usage Per Sec'
 --and ss.metric_name = 'Logical Reads Per Sec'
 --and ss.metric_name = 'Physical Read Total IO Requests Per Sec'
 --and ss.metric_name = 'Executions Per Sec'
order by sn.snap_id;

spool off
