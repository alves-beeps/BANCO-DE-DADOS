 04_audit_setup.sql: Trilha de Auditoria com Trigger Security Definer e JSONB

CREATE TABLE audit.logged_actions (
    id SERIAL PRIMARY KEY,
    schema_name TEXT NOT NULL,
    table_name TEXT NOT NULL,
    session_user_name TEXT NOT NULL DEFAULT SESSION_USER,
    action_tstamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    action TEXT NOT NULL CHECK (action IN ('I', 'U', 'D')),
    original_data JSONB,
    new_data JSONB
);

CREATE OR REPLACE FUNCTION audit.if_modified_func()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO audit.logged_actions (schema_name, table_name, action, original_data)
        VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, 'D', to_jsonb(OLD));
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit.logged_actions (schema_name, table_name, action, original_data, new_data)
        VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, 'U', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO audit.logged_actions (schema_name, table_name, action, new_data)
        VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, 'I', to_jsonb(NEW));
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_audit_movimentacoes
AFTER INSERT OR UPDATE OR DELETE ON workflow.movimentacoes
FOR EACH ROW EXECUTE FUNCTION audit.if_modified_func();

CREATE TRIGGER trg_audit_contas
AFTER INSERT OR UPDATE OR DELETE ON workflow.contas_workflow
FOR EACH ROW EXECUTE FUNCTION audit.if_modified_func();

GRANT USAGE ON SCHEMA audit TO role_admin_workflow, role_gestao;
GRANT SELECT ON audit.logged_actions TO role_admin_workflow, role_gestao;
