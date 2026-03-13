# **Especificação Técnica: MikroTik SSH Script Runner**

Versão: 2.1.0 (Mobile & Admin Update)
Data: 13 de março de 2026

## **1. Visão Geral do Projeto**

O projeto consiste no desenvolvimento de um aplicativo multiplataforma (Windows Desktop e Android Mobile) utilizando o framework Flutter. O objetivo principal é fornecer uma interface gráfica (GUI) robusta e adaptativa para administradores de rede gerenciarem roteadores MikroTik via SSH.

## **2. Requisitos Funcionais (RF)**

| ID | Requisito | Descrição Detalhada |
|:---|:---|:---|
| **RF-01** | **Gerenciamento de Conexões** | Leitura de `config.yml` (Local no Desktop / App Docs no Android). Dropdown para seleção de roteadores. |
| **RF-02** | **Conexão SSH Segura** | Estabelecimento de túnel SSH com as credenciais do YAML. |
| **RF-03** | **Otimização de Scripts** | Descoberta rápida via comandos `:foreach` e extração de descrição do campo `comment`. |
| **RF-04** | **Níveis de Acesso (RBAC)** | Filtragem `mkt1_` (Nível 1+2) e `mkt2_` (Apenas Nível 2) baseada no `user_level`. |
| **RF-05** | **Cache Cross-Platform** | Persistência JSON de scripts descoberta para acesso offline ou rápido. |
| **RF-06** | **Editor de Configuração** | Interface interna para editar o `config.yml` com validação de sintaxe YAML. |
| **RF-07** | **Sistema de Backup** | Criação automática de snapshots do `config.yml` antes de qualquer alteração salva. |
| **RF-08** | **Layout Adaptativo** | Detecção dinâmica de plataforma: Abas para Desktop e Navegação Inferior para Android. |
| **RF-09** | **Logging Detalhado** | Auditoria completa de comandos SSH em arquivos de log datados na pasta `/logs`. |
| **RF-10** | **Criptografia AES-256** | Proteção de senhas em repouso com chave derivada de ambiente ou fallback. |

## **3. Arquitetura e Tecnologias**

*   **Framework**: Flutter 3.41.4
*   **Estado**: Provider (Centralizado em `app_state.dart`)
*   **Comunicação**: `dartssh2` (Protocolo SSH2)
*   **Layout**: `LayoutManager` (Custom Adaptive System)
*   **Segurança**: `encrypt` (AES-256-CBC)
*   **Persistência**: `path_provider` + `shared_preferences`