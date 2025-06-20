select * from {{ full_table_name("fedramp_ksis") }}
where SPLIT(identifier, ':')[SAFE_OFFSET(4)] IN ({{ to_sql_list(var('ksi_cna_07_account_ids')) }})
