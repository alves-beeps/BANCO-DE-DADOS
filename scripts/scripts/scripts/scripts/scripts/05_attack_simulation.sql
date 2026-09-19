05_attack_simulation.sql: Bateria de Testes Ofensivos

estes como Operador Operacional
SET ROLE usr_auditor_op;

CENÁRIO A: Tentativa de Adulteração de Histórico (DEVE FALHAR - Erro 42501)
DELETE FROM workflow.movimentacoes WHERE id = 1;

CENÁRIO B: Tentativa de Acesso a Coluna Restrita/PII (DEVE FALHAR - Erro 42501)
SELECT credencial FROM workflow.usuarios;

CENÁRIO C: Operação Válida com Rastreamento (DEVE FUNCIONAR)
INSERT INTO workflow.movimentacoes (conta_id, setor_origem_id, setor_destino_id, usuario_executor_id, observacoes) 
VALUES (1, 1, 2, 1, 'Transferência válida realizada pela auditoria');

INSERT INTO workflow.comentarios (conta_id, usuario_autor_id, descricao) 
VALUES (1, 1, 'Anotação técnica de conformidade adicionada');

RESET ROLE;
