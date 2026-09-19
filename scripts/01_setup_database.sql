01_setup_database.sql: Provisionamento de Schemas e Tabelas do Workflow Hospitalar

CREATE SCHEMA IF NOT EXISTS workflow;
CREATE SCHEMA IF NOT EXISTS audit;

CREATE TABLE workflow.setores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    status VARCHAR(20) DEFAULT 'ATIVO'
);

CREATE TABLE workflow.usuarios (
    id SERIAL PRIMARY KEY,
    login VARCHAR(50) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    setor_id INT REFERENCES workflow.setores(id),
    credencial VARCHAR(255) NOT NULL, -- Senha/Hash
    perfil VARCHAR(50) NOT NULL
);

CREATE TABLE workflow.contas_workflow (
    id SERIAL PRIMARY KEY,
    codigo_fatura VARCHAR(50) NOT NULL UNIQUE,
    convenio VARCHAR(100) NOT NULL,
    valor_aproximado NUMERIC(15, 2) NOT NULL CHECK (valor_aproximado >= 0),
    setor_detentor_id INT REFERENCES workflow.setores(id),
    data_entrada TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE workflow.movimentacoes (
    id SERIAL PRIMARY KEY,
    conta_id INT REFERENCES workflow.contas_workflow(id),
    setor_origem_id INT REFERENCES workflow.setores(id),
    setor_destino_id INT REFERENCES workflow.setores(id),
    usuario_executor_id INT REFERENCES workflow.usuarios(id),
    data_hora TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    observacoes TEXT
);

CREATE TABLE workflow.comentarios (
    id SERIAL PRIMARY KEY,
    conta_id INT REFERENCES workflow.contas_workflow(id),
    usuario_autor_id INT REFERENCES workflow.usuarios(id),
    data_hora TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    descricao TEXT NOT NULL
);
