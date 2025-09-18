# **Plano de Tarefas de Desenvolvimento: MikroTik SSH Script Runner**

Este documento detalha as tarefas necessárias para construir o aplicativo, com base na **Especificação Técnica v1.1**. As tarefas estão organizadas em fases para um desenvolvimento progressivo.

### **Fase 1: Configuração do Projeto e Estrutura Base**

O objetivo desta fase é criar o esqueleto do aplicativo, configurar o ambiente e construir a UI estática de forma detalhada.

* \[ \] **Tarefa 1.1: Inicializar Projeto Flutter**  
  * Criar um novo projeto Flutter para desktop.  
  * Configurar as dependências: flutter\_bloc (ou provider), yaml, dartssh2, encrypt.  
* \[ \] **Tarefa 1.2: Definir a Arquitetura de Estado**  
  * Implementar a estrutura básica do gerenciador de estado.  
  * Definir os estados principais da aplicação: Initial, Connecting, Connected, LoadingScripts, ExecutingScript, Error.  
* \[ \] **Tarefa 1.3: Construir a Interface de Usuário (UI) Estática e Componentizada**  
  * **1.3.1:** Criar o widget para o painel **"Connection"**, contendo o DropdownButton para "Router" e os TextFields (somente leitura) para "Host", "Port", "Username" e "Password".  
  * **1.3.2:** Criar o widget para o painel **"Script Execution"**, contendo o DropdownButton para "Script" e o TextField (somente leitura) para "Description".  
  * **1.3.3:** Criar o widget para o **Painel de Ações**, contendo os botões Connect, Atualizar Scripts, Execute, e Close.  
  * **1.3.4:** Criar os widgets para os painéis de saída, com áreas de texto roláveis para **"Command Results"** e **"Information Log"**.  
  * **1.3.5:** Implementar a **Barra de Status** na parte inferior da janela principal.

### **Fase 2: Lógica de Configuração e Dados**

Esta fase foca em fazer o aplicativo ler e manipular os arquivos de configuração e cache.

* \[ \] **Tarefa 2.1: Implementar o Módulo de Criptografia**  
  * Criar uma classe de serviço para criptografar/descriptografar senhas (AES).  
  * *Opcional: Criar um script auxiliar para gerar senhas criptografadas para o config.yml.*  
* \[ \] **Tarefa 2.2: Leitura e Processamento do config.yml**  
  * Implementar a lógica para ler o config.yml da pasta do executável.  
  * Desenvolver o parser para transformar o YAML em objetos Dart.  
  * Integrar o módulo de criptografia para descriptografar as senhas em memória.  
* \[ \] **Tarefa 2.3: Gerenciamento do Cache de Scripts (JSON)**  
  * Implementar funções para ler e escrever os arquivos scripts\_\[router\_name\].json.

### **Fase 3: Conectividade SSH e Lógica Principal**

Aqui, o núcleo da funcionalidade do aplicativo é desenvolvido.

* \[ \] **Tarefa 3.1: Implementar o Serviço de Conexão SSH**  
  * Criar uma classe para gerenciar a sessão SSH (conectar, executar comandos, desconectar).  
* \[ \] **Tarefa 3.2: Desenvolver a Lógica de "Atualizar Scripts"**  
  * Implementar a função que executa /system script print detail, faz o parse da saída, extrai a descrição da primeira linha do source, filtra por user\_level e salva o resultado no cache JSON.  
* \[ \] **Tarefa 3.3: Desenvolver a Lógica de "Executar Script"**  
  * Implementar a função que executa /system script run "script\_name" e captura o seu output.

### **Fase 4: Integração da UI e Experiência do Usuário (Binding)**

O objetivo é conectar toda a lógica de backend ao frontend, tornando o aplicativo funcional e interativo.

* \[ \] **Tarefa 4.1: Conectar a Lógica ao Painel "Connection"**  
  * **Dropdown Router:** Ao ser populado a partir do config.yml, a seleção de um item deve:  
    * Disparar um evento para o gerenciador de estado.  
    * O estado resultante deve preencher os campos Host, Port, etc.  
    * O app deve tentar carregar o cache de scripts (.json) para este roteador.  
* \[ \] **Tarefa 4.2: Conectar a Lógica ao Painel de Ações**  
  * **Botão Connect:**  
    * Ao clicar, chamar o serviço SSH e mudar o estado para Connecting. A UI deve mostrar um loading spinner e desabilitar outros botões.  
    * Em caso de sucesso, mudar o estado para Connected, atualizar o log, e ajustar a visibilidade/estado dos botões (Close e Atualizar Scripts habilitados, Connect desabilitado).  
    * Em caso de falha, mudar para o estado Error, mostrar um pop-up e registrar no log.  
  * **Botão Atualizar Scripts:**  
    * Habilitado apenas no estado Connected.  
    * Ao clicar, chamar a lógica da Tarefa 3.2 e mudar o estado para LoadingScripts.  
    * Após a conclusão, o novo estado deve atualizar a lista no dropdown Script.  
  * **Botão Execute:**  
    * Habilitado apenas em Connected e com um script selecionado.  
    * Ao clicar, chamar a lógica da Tarefa 3.3, mudar o estado para ExecutingScript.  
    * A saída do comando deve ser enviada para o painel "Command Results".  
  * **Botão Close:**  
    * Habilitado apenas em Connected.  
    * Ao clicar, chamar a função de desconexão e resetar o estado da aplicação para Initial.  
* \[ \] **Tarefa 4.3: Conectar a Lógica ao Painel "Script Execution"**  
  * **Dropdown Script:**  
    * Deve ser populado a partir do cache (seja na seleção do roteador ou após "Atualizar Scripts").  
    * A seleção de um item deve exibir sua descrição no campo correspondente.  
* \[ \] **Tarefa 4.4: Conectar os Painéis de Saída**  
  * **"Command Results" e "Information Log":** Devem "ouvir" as mudanças de estado e adicionar novas entradas de texto conforme elas são geradas pela lógica do aplicativo.  
  * **Barra de Status:** Deve exibir mensagens contextuais baseadas no estado atual (ex: "Conectado a Router Matriz", "Pronto para conectar", "Erro de autenticação").

### **Fase 5: Finalização e Empacotamento**

* \[ \] **Tarefa 5.1: Testes Funcionais**  
* \[ \] **Tarefa 5.2: Polimento da UI/UX**  
* \[ \] **Tarefa 5.3: Compilação e Empacotamento**  
* \[ \] **Tarefa 5.4: Documentação Final (README.md)**