-- 06_forensic_queries.sql: Consultas para Investigação Forense

SET ROLE usr_dba_admin;

-- 1. Consultar todas as ações capturadas na trilha de auditoria
SELECT 
    id, 
    schema_name, 
    table_name, 
    session_user_name, 
    action_tstamp, 
    action, 
    new_data 
FROM audit.logged_actions 
ORDER BY action_tstamp DESC;

-- 2. Identificar alterações em contas de valor elevado (> 5000)
SELECT 
    session_user_name, 
    action_tstamp, 
    new_data->>'codigo_fatura' AS fatura,
    new_data->>'valor_aproximado' AS valor
FROM audit.logged_actions
WHERE table_name = 'contas_workflow' 
  AND (new_data->>'valor_aproximado')::numeric > 5000;

RESET ROLE;
