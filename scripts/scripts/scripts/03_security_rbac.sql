03_security_rbac.sql: Limpeza do Public, RBAC, Roles e Visões Seguras (LGPD)

REVOKE ALL ON SCHEMA public FROM PUBLIC;

Roles NOLOGIN
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'role_operacional') THEN CREATE ROLE role_operacional NOLOGIN; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'role_gestao') THEN CREATE ROLE role_gestao NOLOGIN; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'role_admin_workflow') THEN CREATE ROLE role_admin_workflow NOLOGIN; END IF;
END $$;

Criar Usuários
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'usr_auditor_op') THEN CREATE USER usr_auditor_op WITH PASSWORD 'Senha_Op_123'; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'usr_coordenador_gestao') THEN CREATE USER usr_coordenador_gestao WITH PASSWORD 'Senha_Gestao_123'; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'usr_dba_admin') THEN CREATE USER usr_dba_admin WITH PASSWORD 'Senha_Admin_123'; END IF;
END $$;

GRANT role_operacional TO usr_auditor_op;
GRANT role_gestao TO usr_coordenador_gestao;
GRANT role_admin_workflow TO usr_dba_admin;

Permissões de Esquema
GRANT USAGE ON SCHEMA workflow TO role_operacional, role_gestao, role_admin_workflow;

Permissões role_operacional (sem DELETE)
GRANT SELECT ON workflow.contas_workflow, workflow.setores, workflow.movimentacoes, workflow.comentarios TO role_operacional;
GRANT INSERT ON workflow.movimentacoes, workflow.comentarios TO role_operacional;
GRANT SELECT (id, login, nome, setor_id, perfil) ON workflow.usuarios TO role_operacional; -- Proteção LGPD (Sem credencial)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA workflow TO role_operacional;

Permissões role_gestao
GRANT SELECT ON ALL TABLES IN SCHEMA workflow TO role_gestao;

Permissões role_admin_workflow
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA workflow TO role_admin_workflow;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA workflow TO role_admin_workflow;

View Segura (LGPD / Gestão)
CREATE OR REPLACE VIEW workflow.vw_desempenho_setores AS
SELECT 
    s.nome AS setor,
    COUNT(c.id) AS total_contas_atuais,
    COALESCE(SUM(c.valor_aproximado), 0) AS valor_total_em_transito
FROM workflow.setores s
LEFT JOIN workflow.contas_workflow c ON s.id = c.setor_detentor_id
GROUP BY s.nome;

GRANT SELECT ON workflow.vw_desempenho_setores TO role_gestao;
