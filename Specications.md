# **Especificação Técnica: MikroTik SSH Script Runner**

Versão: 1.1  
Data: 18 de setembro de 2025

## **1\. Visão Geral do Projeto**

O projeto consiste no desenvolvimento de um aplicativo multiplataforma (desktop) utilizando o framework Flutter. O objetivo principal do aplicativo é fornecer uma interface gráfica (GUI) para administradores de rede se conectarem a roteadores MikroTik via SSH e executarem scripts pré-definidos de forma segura e controlada.

## **2\. Requisitos Funcionais (RF)**

| ID        | Requisito                                    | Descrição Detalhada                                                                                                                                                                                                                                                                                                                                 |
|:--------- |:-------------------------------------------- |:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **RF-01** | **Gerenciamento de Conexões via config.yml** | O aplicativo deve iniciar lendo um arquivo config.yml localizado **na mesma pasta do seu executável**. Este arquivo conterá uma lista de roteadores. A UI deve popular um seletor (dropdown) com os nomes dos roteadores.                                                                                                                           |
| **RF-02** | **Conexão SSH**                              | O usuário poderá selecionar um roteador na lista e clicar em "Conectar". O aplicativo deve usar as informações do config.yml para estabelecer uma conexão SSH. O estado da conexão deve ser claramente visível na UI.                                                                                                                               |
| **RF-03** | **Descoberta e Processamento de Scripts**    | Após conectar, um botão **"Atualizar Scripts"** ficará visível. Ao ser clicado, o app executará /system script print detail no MikroTik. Para cada script retornado, o app irá extrair o conteúdo (source) para ler a primeira linha. Se a primeira linha for um comentário (iniciando com \#), seu conteúdo será usado como a descrição do script. |
| **RF-04** | **Filtragem e Níveis de Acesso a Scripts**   | O aplicativo deve filtrar os scripts com base na convenção de nomenclatura: mkt\<NIVEL\>\_nomescript, usando o user\_level do config.yml. \- Usuário Nível 1: Acessa scripts mkt1\_\* e mkt2\_\*. \- Usuário Nível 2: Acessa apenas scripts mkt2\_\*.                                                                                               |
| **RF-05** | **Cache Local de Scripts**                   | A lista de scripts processada (com nome, nível e descrição) deve ser salva localmente em um arquivo JSON para cada roteador (ex: scripts\_Router\_Matriz.json).                                                                                                                                                                                     |
| **RF-06** | **Execução de Script**                       | O usuário poderá selecionar um script e clicar em "Executar". O app enviará o comando /system script run "\<nome\_do\_script\>" via SSH.                                                                                                                                                                                                            |
| **RF-07** | **Visualização de Resultados**               | A saída (output) do comando executado deve ser exibida na área de "Command Results".                                                                                                                                                                                                                                                                |
| **RF-08** | **Log de Informações**                       | O aplicativo deve manter um log de suas próprias operações na área "Information Log".                                                                                                                                                                                                                                                               |
| **RF-09** | **Desconexão**                               | Um botão "Fechar" deve encerrar a sessão SSH ativa de forma segura.                                                                                                                                                                                                                                                                                 |
| **RF-10** | **Segurança de Credenciais**                 | As senhas no config.yml devem estar criptografadas. O aplicativo deve descriptografá-las em memória no momento do uso. A chave de descriptografia estará embutida no código da aplicação.                                                                                                                                                           |

## **3\. Estrutura de Dados**

### **3.1. config.yml**

routers:  
  \- name: "Router Matriz"  
    host: "192.168.1.1"  
    port: 22  
    username: "admin"  
    \# A senha deve ser armazenada de forma criptografada (ex: AES)  
    password: "ENCRYPTED\_PASSWORD\_1"  
    user\_level: 1

  \- name: "Router Filial 01"  
    host: "10.0.1.1"  
    port: 2222  
    username: "suporte"  
    password: "ENCRYPTED\_PASSWORD\_2"  
    user\_level: 2

### **3.2. scripts\_\[router\_name\].json**

\[  
  {  
    "name": "mkt1\_backup\_config",  
    "description": "Realiza o backup completo das configurações do roteador.",  
    "level": 1  
  },  
  {  
    "name": "mkt2\_reboot\_device",  
    "description": "Reinicia o roteador de forma segura.",  
    "level": 2  
  }  
\]

## **4\. Detalhamento da Interface do Usuário (UI)**

* **Painel "Connection"**:  
  * **Router (Dropdown)**: Lista os roteadores do config.yml.  
  * **Host, Port, Username, Password**: Campos somente leitura, preenchidos ao selecionar um roteador. A senha é ofuscada.  
* **Painel "Script Execution"**:  
  * **Script (Dropdown)**: Lista os scripts do cache local (JSON), filtrados por permissão.  
  * **Description**: Exibe a descrição do script selecionado.  
* **Painel de Ações**:  
  * **Connect**: Inicia a conexão.  
  * **Atualizar Scripts**: (Novo Botão) Fica visível e habilitado somente após a conexão. Dispara a busca e processamento de scripts (RF-03).  
  * **Execute**: Executa o script selecionado.  
  * **Close**: Encerra a conexão.  
* **Painéis de Saída**:  
  * **Command Results**: Exibe o output dos scripts.  
  * **Information Log**: Exibe os logs do aplicativo.  
* **Barra de Status**:  
  * Exibe o estado atual e contagem de roteadores.

## **5\. Tratamento de Erros e Feedback ao Usuário**

* **Feedback Visual para Ações Longas**: Durante operações que podem demorar (Conectar, Atualizar Scripts, Executar), a **UI deve ser bloqueada** e um indicador de progresso (ex: loading spinner) deve ser exibido para informar o usuário que o app está trabalhando.  
* **Erros Críticos**: Falhas de conexão, autenticação inválida ou falha ao ler o config.yml devem gerar um **diálogo de alerta (pop-up)** para o usuário.  
* **Erros Não-Críticos e Status**: Outras informações, como a falha na execução de um script ou a impossibilidade de encontrar a descrição, devem ser registradas no painel **"Information Log"**.

## **6\. Arquitetura e Tecnologias**

* **Framework**: Flutter  
* **Linguagem**: Dart  
* **Gerenciamento de Estado**: Provider / BLoC  
* **Biblioteca SSH**: dartssh2  
* **Criptografia**: encrypt ou similar para AES.  
* **Parsing**: yaml para config.yml e dart:convert para JSON.