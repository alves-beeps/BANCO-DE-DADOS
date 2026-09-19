02_seed_data.sql: Carga Inicial do Hospital Universitário

INSERT INTO workflow.setores (nome) VALUES 
('Auditoria'), 
('Central de Guias'), 
('Faturamento'), 
('Recurso de Glosa');

INSERT INTO workflow.usuarios (login, nome, setor_id, credencial, perfil) VALUES 
('auditor_op', 'Dr. Carlos Andrade', 1, 'scram_hash_123', 'OPERACIONAL'),
('coord_gestao', 'Dra. Maria Souza', 2, 'scram_hash_456', 'GESTAO'),
('dba_admin', 'Rudson Ribeiro', 3, 'scram_hash_789', 'ADMIN');

INSERT INTO workflow.contas_workflow (codigo_fatura, convenio, valor_aproximado, setor_detentor_id) VALUES 
('FAT-2026-001', 'Unimed', 12500.00, 1),
('FAT-2026-002', 'Bradesco Saúde', 8400.50, 2),
('FAT-2026-003', 'SUS', 3100.00, 3);

INSERT INTO workflow.movimentacoes (conta_id, setor_origem_id, setor_destino_id, usuario_executor_id, observacoes) VALUES 
(1, 1, 2, 1, 'Encaminhado para verificação de guia'),
(2, 2, 3, 2, 'Pronto para faturamento');

INSERT INTO workflow.comentarios (conta_id, usuario_autor_id, descricao) VALUES 
(1, 1, 'Aguardando guia de autorização especial'),
(2, 2, 'Conferido com sucesso');
