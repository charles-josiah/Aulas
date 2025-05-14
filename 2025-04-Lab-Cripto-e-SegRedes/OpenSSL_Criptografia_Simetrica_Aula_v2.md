
# OpenSSL para Criptografia Simétrica

### Objetivo
O objetivo desta aula é mostrar como realizar criptografia simétrica utilizando o **OpenSSL**. Vamos aprender a gerar uma chave secreta, criptografar e descriptografar arquivos, e verificar a integridade dos arquivos usando **hashes**.

### 1. Criação de Chaves Simétricas

A criptografia simétrica usa a mesma chave para criptografar e descriptografar. Para gerar uma chave secreta, vamos usar **AES** (Advanced Encryption Standard).

#### Passos:

1. **Gerar uma chave secreta com OpenSSL (AES-256)**:

   Você pode gerar uma chave secreta com o comando `openssl rand` para criptografia simétrica. Vamos gerar uma chave de 256 bits:

   ```bash
   openssl rand -out secret.key 32
   ```

   - `secret.key`: nome do arquivo onde a chave secreta será armazenada.
   - `32`: tamanho da chave em bytes (256 bits).

   Esta chave será usada para criptografar e descriptografar os arquivos.

### 2. Exemplo 1: Criptografia e Descriptografia de Arquivos com AES

Agora, vamos criptografar e descriptografar um arquivo usando **AES-256-CBC** (modo CBC de AES, que é um dos modos mais comuns e seguros).

#### Passos:

1. **Criptografar um arquivo com AES-256-CBC**:

   Vamos criptografar o arquivo `data.txt` com a chave secreta gerada (`secret.key`):

   ```bash
   openssl enc -aes-256-cbc -salt -in data.txt -out encrypted_data.bin -pass file:./secret.key
   ```

   - `aes-256-cbc`: o algoritmo de criptografia AES no modo CBC com chave de 256 bits.
   - `-salt`: adiciona um salt para dificultar ataques de força bruta.
   - `-in data.txt`: o arquivo a ser criptografado.
   - `-out encrypted_data.bin`: o arquivo criptografado resultante.
   - `-pass file:./secret.key`: passa a chave secreta para o comando.

2. **Descriptografar o arquivo com a chave secreta**:

   Agora, para descriptografar o arquivo `encrypted_data.bin`:

   ```bash
   openssl enc -d -aes-256-cbc -in encrypted_data.bin -out decrypted_data.txt -pass file:./secret.key
   ```

   - `-d`: indica que estamos fazendo a descriptografia.
   - `-in encrypted_data.bin`: o arquivo criptografado.
   - `-out decrypted_data.txt`: o arquivo resultante após a descriptografia.
   - `-pass file:./secret.key`: a chave secreta usada para a descriptografia.
<br>
   **Obs:** a chave secreta gerada precisa ser compartilhada com o destino da mensagem.

### 3. Exemplo 2: Gerar e Verificar Hash de Arquivo

Para garantir a integridade do arquivo, podemos gerar um **hash** (resumo do conteúdo) do arquivo antes de criptografá-lo. O hash pode ser usado para verificar se o arquivo foi alterado durante a transmissão.

#### Passos:

1. **Gerar o hash SHA-256 de um arquivo**:

   Para gerar o hash do arquivo `data.txt`:

   ```bash
   openssl dgst -sha256 data.txt > data_hash.txt
   ```

   - `data_hash.txt`: arquivo contendo o hash SHA-256 do arquivo `data.txt`.

2. **Verificar a integridade do arquivo usando o hash**:

   Depois de descriptografar o arquivo, podemos gerar o hash novamente e compará-lo com o hash original para verificar se o arquivo foi alterado.

   ```bash
   openssl dgst -sha256 decrypted_data.txt
   ```

   Se o hash gerado coincidir com o hash original armazenado no arquivo `data_hash.txt`, a integridade do arquivo foi mantida.

### 4. Exemplo 3: Criptografar Arquivo e Verificar Integridade com HMAC (Hash-based Message Authentication Code)

O HMAC é uma combinação de hash e chave secreta, usada para garantir tanto a integridade quanto a autenticidade de um arquivo. Neste exemplo, vamos usar o HMAC para validar um arquivo criptografado.

#### Passos:

1. **Gerar o HMAC de um arquivo**:

   Vamos gerar o HMAC de um arquivo (`data.txt`) com a chave secreta gerada anteriormente (`secret.key`):

   ```bash
   openssl dgst -sha256 -mac HMAC -macopt key:./secret.key data.txt
   ```

2. **Verificar o HMAC de um arquivo**:

   Para verificar a integridade do arquivo criptografado, podemos comparar o HMAC do arquivo descriptografado com o HMAC original. O comando seria semelhante ao anterior, mas usado no arquivo descriptografado.

### 5. Exemplo 4: Criptografar Arquivo com uma Senha e Usar OpenSSL para Verificação

Agora vamos usar uma **senha** para criptografar e descriptografar arquivos, sem a necessidade de gerar uma chave secreta aleatória.

#### Passos:

1. **Criptografar com senha**:

   Para criptografar o arquivo `data.txt` com uma senha fornecida diretamente:

   ```bash
   openssl enc -aes-256-cbc -salt -in data.txt -out encrypted_data.bin -pass stdin
   ```

   Aqui, o **OpenSSL** solicitará que você digite a senha interativamente no terminal. O comando `-pass stdin` diz ao OpenSSL para esperar a senha ser fornecida diretamente na entrada padrão (stdin).

2. **Descriptografar com senha**:

   Para descriptografar o arquivo criptografado com a mesma senha, você digita a senha quando solicitado:

   ```bash
   openssl enc -d -aes-256-cbc -in encrypted_data.bin -out decrypted_data.txt -pass stdin
   ```

   Quando o comando for executado, o OpenSSL solicitará que você insira a senha para poder descriptografar o arquivo.
   <br>
   **Obs:** a chave secreta gerada precisa ser compartilhada com o destino da mensagem.

### 6. Exemplo 5: Criptografar Arquivo com Senha (Sem Necessidade de Gerar Arquivo de Chave)

Neste exemplo, vamos usar o OpenSSL para criptografar e descriptografar um arquivo diretamente com uma senha fornecida pelo usuário.

#### Passos:

1. **Criptografar um arquivo com senha**:

   Quando você executa o comando abaixo, o OpenSSL solicitará que você digite a senha para criptografar o arquivo `data.txt`.

   ```bash
   openssl enc -aes-256-cbc -salt -in data.txt -out encrypted_data.bin -pass pass:mysecretpassword
   ```

2. **Descriptografar o arquivo com senha**:

   Agora, para descriptografar o arquivo com a senha fornecida anteriormente:

   ```bash
   openssl enc -d -aes-256-cbc -in encrypted_data.bin -out decrypted_data.txt -pass pass:mysecretpassword
   ```

### Conclusão

A criptografia simétrica com **OpenSSL** oferece um conjunto de ferramentas poderosas para proteger arquivos e garantir sua integridade. As operações de **criptografar** e **descriptografar** arquivos com uma **chave secreta** são rápidas e eficientes. Além disso, a **verificação de integridade** com **hashes** e **HMAC** pode garantir que os arquivos não foram alterados durante a transmissão ou armazenamento.

Esses exemplos cobrem operações comuns de **criptografia simétrica** e **verificação de integridade** com o OpenSSL. Se você tiver mais dúvidas ou precisar de ajustes, fique à vontade para perguntar!
