# MikroTik SSH Script Runner

Este é um aplicativo de desktop feito em Flutter que fornece uma interface gráfica para executar scripts `.txt` em múltiplos roteadores MikroTik via SSH.

O objetivo é simplificar a administração de vários dispositivos, permitindo que o usuário selecione um roteador, escolha um script e o execute com um clique, visualizando a saída diretamente na tela.

![Screenshot da Aplicação](https://github.com/danieldoalto/MKT_flutter_scripts/blob/main/assets/screenshot.png?raw=true)

---

## Funcionalidades Principais

*   **Gerenciamento Centralizado de Roteadores**: Carrega a lista de roteadores a partir de um arquivo `config.yml`, mantendo suas credenciais seguras.
*   **Descoberta Automática de Scripts**: Encontra e lista todos os scripts `.txt` localizados em uma pasta `scripts/`.
*   **Conexão SSH Segura**: Conecta-se aos roteadores MikroTik usando o protocolo SSH.
*   **Execução de Scripts com Um Clique**: Permite executar qualquer script selecionado no roteador conectado.
*   **Visualização de Saída**: Mostra o resultado (output) do script executado em um painel de texto.
*   **Segurança de Credenciais**: As senhas no `config.yml` são armazenadas de forma criptografada e são descriptografadas em tempo de execução usando uma chave de ambiente.
*   **Feedback Visual**: A interface é bloqueada e exibe um indicador de progresso durante operações demoradas (conexão, execução).
*   **Log de Informações**: Registra os passos da aplicação, como tentativas de conexão e execução de scripts, para facilitar o debug.

## Como Configurar e Executar

Siga estes passos para configurar o ambiente e rodar o projeto.

### Pré-requisitos

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado.
*   Um editor de código como [Visual Studio Code](https://code.visualstudio.com/).

### 1. Clone o Repositório

```bash
git clone https://github.com/danieldoalto/MKT_flutter_scripts.git
cd MKT_flutter_scripts
```

### 2. Crie o Arquivo `config.yml`

Na raiz do projeto, crie um arquivo chamado `config.yml`. Este arquivo conterá a lista dos seus roteadores.

**Estrutura do `config.yml`:**

```yaml
routers:
  - name: "Router 1 - Matriz"
    host: "192.168.1.1"
    port: 22
    username: "admin"
    password: "SUA_SENHA_AQUI_1" # Use a senha em texto plano por enquanto

  - name: "Router 2 - Filial"
    host: "10.0.0.1"
    port: 22
    username: "admin"
    password: "SUA_SENHA_AQUI_2"
```

Substitua os valores de exemplo pelos dados reais dos seus roteadores.

### 3. Crie a Pasta e os Scripts

1.  Na raiz do projeto, crie uma pasta chamada `scripts`.
2.  Dentro da pasta `scripts/`, crie arquivos de texto (ex: `get_info.txt`, `reboot.txt`) com os comandos MikroTik que você deseja executar.

**Exemplo de `get_info.txt`:**
```
/system resource print
```

### 4. Criptografe suas Senhas

Para segurança, as senhas no `config.yml` devem ser criptografadas.

1.  **Defina a Chave de Criptografia:**
    Defina uma variável de ambiente no seu sistema chamada `SCRIPT_RUNNER_KEY`. Esta será a chave mestra para criptografar e descriptografar suas senhas.
    ```bash
    # Exemplo para Linux/macOS
    export SCRIPT_RUNNER_KEY="uma-chave-secreta-muito-forte-123"

    # Exemplo para Windows (PowerShell)
    $env:SCRIPT_RUNNER_KEY="uma-chave-secreta-muito-forte-123"
    ```
    **Importante:** Você precisará ter esta variável de ambiente configurada sempre que for rodar a aplicação.

2.  **Execute o Script de Criptografia:**
    Rode a ferramenta que acompanha o projeto para criptografar as senhas que estão no `config.yml`.
    ```bash
    dart run tool/encrypt_passwords.dart
    ```
    O script irá ler o `config.yml`, encontrar as senhas em texto plano, criptografá-las e salvar o arquivo `config.yml` atualizado. Suas senhas agora estarão seguras.

### 5. Execute a Aplicação

Finalmente, com tudo configurado, execute o aplicativo:

```bash
flutter run
```

## Arquitetura e Tecnologias

*   **Framework**: Flutter
*   **Linguagem**: Dart
*   **Gerenciamento de Estado**: Provider
*   **Biblioteca SSH**: [dartssh2](https://pub.dev/packages/dartssh2)
*   **Criptografia**: [encrypt](https://pub.dev/packages/encrypt) (AES)
*   **Parsing de Configuração**: [yaml](https://pub.dev/packages/yaml)
