# **Plano de Tarefas de Desenvolvimento: MikroTik SSH Script Runner**

Este documento detalha as tarefas necessárias para construir o aplicativo, com base na **Especificação Técnica v1.1**. As tarefas estão organizadas em fases para um desenvolvimento progressivo.

### **Fase 1: Configuração do Projeto e Estrutura Base**
* [x] **Tarefa 1.1: Inicializar Projeto Flutter**
* [x] **Tarefa 1.2: Definir a Arquitetura de Estado**
* [x] **Tarefa 1.3: Construir a Interface de Usuário (UI) Estática**

### **Fase 2: Lógica de Configuração e Dados**
* [x] **Tarefa 2.1: Implementar o Módulo de Criptografia**
* [x] **Tarefa 2.2: Leitura e Processamento do config.yml**
* [x] **Tarefa 2.3: Gerenciamento do Cache de Scripts (JSON)**

### **Fase 3: Conectividade SSH e Lógica Principal**
* [x] **Tarefa 3.1: Implementar o Serviço de Conexão SSH**
* [x] **Tarefa 3.2: Desenvolver a Lógica de "Atualizar Scripts"**
* [x] **Tarefa 3.3: Desenvolver a Lógica de "Executar Script"**

### **Fase 4: Integração da UI e Experiência do Usuário (Binding)**
* [x] **Tarefa 4.1: Conectar a Lógica ao Painel "Connection"**
* [x] **Tarefa 4.2: Conectar a Lógica ao Painel de Ações**
* [x] **Tarefa 4.3: Conectar a Lógica ao Painel "Script Execution"**
* [x] **Tarefa 4.4: Conectar os Painéis de Saída**

### **Fase 5: Finalização e Empacotamento**
* [x] **Tarefa 5.1: Testes Funcionais**
* [x] **Tarefa 5.2: Polimento da UI/UX**
* [x] **Tarefa 5.3: Compilação e Empacotamento**
* [x] **Tarefa 5.4: Documentação Final (README.md)**

### **Fase 6: Expansão Mobile e Gestão Avançada (v2.1.0)**
* [x] **Tarefa 6.1: Portabilidade Android**
  * [x] Implementação de LayoutManager para UI adaptativa.
  * [x] Configuração de permissões e ciclo de vida Android.
* [x] **Tarefa 6.2: Editor de Configuração Integrado**
  * [x] Desenvolvimento de painel YAML com validação.
  * [x] Sistema de backups automáticos e restauração.
* [x] **Tarefa 6.3: Atualização de Infraestrutura**
  * [x] Migração para Flutter **3.41.4**.
  * [x] Otimização de pacotes e dependências.
* [x] **Tarefa 6.4: Sincronização e Documentação**
  * [x] Sincronização de ramos Git (`main` e `android`).
  * [x] Atualização de todos os guias Markdown.