Markdown
Atividade Prática - Administração, Segurança e Governança de Dados
Instituição: Hospital Universitário  
Sistema Satélite: Movimentador de Contas e Rastreabilidade   
Disciplina: Administração de Banco de Dados (DBA)
1. Integrantes do Grupo
- Rudson Rafael Alves Ribeiro
2. Guia de Instalação e Execução dos Scripts
Para provisionar, configurar e auditar o ambiente no PostgreSQL, execute os scripts presentes na pasta "scripts/" rigorosamente na seguinte ordem cronológica:
1. "scripts/01_setup_database.sql" — Provisionamento dos esquemas lógicos ("workflow" e "audit") e criação das tabelas relacionais do sistema.
2. "scripts/02_seed_data.sql" — Carga inicial de dados simulando setores hospitalares, usuários e contas em trânsito.
3. "scripts/03_security_rbac.sql" — Higienização do esquema "PUBLIC", criação das roles funcionais, concessão sob menor privilégio e view restrita LGPD.
4. "scripts/04_audit_setup.sql" — Estruturação da tabela "audit.logged_actions" e criação das triggers de auditoria automática em "JSONB".
5. "scripts/05_attack_simulation.sql" — Bateria de testes ofensivos e simulação de violação de acesso.
6. "scripts/06_forensic_queries.sql" — Consultas analíticas investigativas na trilha de auditoria forense.
3. Dicionário e Justificativa Arquitetural
Segregação e Não Interferência (Zero Trust)
- Esquema "workflow": Contém toda a lógica de negócios da esteira do hospital (faturas, trânsito de contas e comentários), isolando os dados operacionais.
- "Esquema "audit": Mantém a tabela de auditoria "audit.logged_actions" estritamente separada das tabelas de negócio para evitar qualquer contaminação ou adulteração por usuários de aplicação.
RBAC e Proteção de Dados (LGPD)
- Papéis (Roles):
  - "role_operacional": Permissão apenas para consulta e inserção de movimentações/comentários. Possui acesso bloqueado para exclusão ("DELETE") e para colunas com credenciais/dados confidenciais na tabela "usuarios".
  - "role_gestao": Leitura restrita focada em visões consolidadas e relatórios gerenciais sem exibição de dados pessoais.
  - "role_admin_workflow': Acesso administrativo completo de DBA.
- Minimização de Dados: As permissões de "SELECT" na tabela de usuários excluem colunas sensíveis (como "credencial"), além do uso da view "vw_desempenho_setores" para métricas agregadas sem exposição de identificadores de pacientes.
4. Relatório de Incidentes e Parecer Forense
Evidências de Bloqueio de Acesso Indevido (SGBD)
Durante a execução do script "05_attack_simulation.sql", foram testadas tentativas de violação com o usuário operacional "usr_auditor_op":
Cenário A (Tentativa de Adulteração de Histórico): A tentativa de deletar um registro em "workflow.movimentacoes" foi rejeitada pelo SGBD:
  > "ERROR: permission denied for table movimentacoes" 
  > "SQL state: 42501"
Cenário B (Acesso a Dados Confidenciais / PII): A tentativa de consultar a coluna "credencial" da tabela "workflow.usuarios" resultou em bloqueio:
  > "ERROR: permission denied for table usuarios"  
  > "SQL state: 42501"
Análise e Rastreabilidade (Trilha de Auditoria)
A execução do script "06_forensic_queries.sql" comprovou a eficiência da trigger* com função "SECURITY DEFINER". Todas as inserções válidas capturaram com exatidão:
- Timestamp exato da transação;
- Usuário da sessão ("session_user");
- Operação realizada ("I" para Insert);
- Estado dos dados codificado em formato estruturado "JSONB" no campo "new_data".
