
# Aula sobre OpenSSL para Criptografia Assimétrica

## Objetivo
O objetivo desta aula é mostrar como realizar criptografia assimétrica usando o OpenSSL. Vamos aprender a gerar chaves públicas e privadas, criptografar e descriptografar arquivos, assinar digitalmente arquivos e verificar a assinatura. Tudo isso utilizando comandos do OpenSSL no ambiente Linux.


### 1. Introdução à Criptografia Assimétrica

A criptografia assimétrica, também conhecida como criptografia de chave pública, é um método de criptografia que utiliza um par de chaves para proteger dados. Esses pares de chaves consistem em:

- **Chave pública**: Pode ser distribuída livremente. É usada para criptografar dados ou para verificar assinaturas digitais.
- **Chave privada**: Deve ser mantida em segredo. É usada para descriptografar dados criptografados com a chave pública correspondente ou para assinar digitalmente mensagens.

A segurança desse método baseia-se na dificuldade computacional de fatorar grandes números primos (para algoritmos como RSA) ou resolver problemas de logaritmo discreto (para algoritmos como ECC - Curva Elíptica).

### 2. Conceitos Básicos

- **Criptografia**: Processo de codificar informações para que apenas as partes autorizadas possam lê-las.
- **Chave Pública**: Usada para criptografar mensagens. Pode ser compartilhada publicamente sem comprometer a segurança.
- **Chave Privada**: Mantida em segredo, usada para descriptografar mensagens criptografadas com a chave pública correspondente.
- **Assinatura Digital**: Usada para garantir a integridade e a autenticidade de uma mensagem ou documento. É criada com a chave privada e verificada com a chave pública.
- **Certificados Digitais**: Documentos eletrônicos que associam uma chave pública a uma identidade, geralmente emitidos por uma Autoridade Certificadora (CA).

### 3. Usabilidade

A criptografia assimétrica é amplamente utilizada em diversos cenários, como:

- **Comunicação segura (TLS/SSL)**: A criptografia assimétrica é usada para estabelecer conexões seguras na web. O protocolo HTTPS usa certificados digitais para autenticar servidores e criptografar dados transmitidos.
- **Assinaturas digitais**: As assinaturas digitais garantem que uma mensagem ou documento não foi alterado e foi enviado por uma fonte autenticada.
- **Troca de chaves seguras**: O protocolo de troca de chaves Diffie-Hellman permite que duas partes gerem uma chave de sessão compartilhada para comunicação segura.
- **Autenticação**: Utilizada em sistemas de autenticação multifatorial, como SSH, onde a chave pública do usuário é armazenada no servidor e a chave privada é usada para autenticação.

### 4. Casos de Uso

- **Comunicação Segura na Web**: A maioria dos sites utiliza criptografia assimétrica para proteger dados transmitidos, como senhas e informações de pagamento, por meio do HTTPS.
- **Autenticação SSH**: Para acessar servidores de forma segura, utiliza-se a autenticação baseada em chaves SSH.
- **Assinatura de Software**: Os desenvolvedores assinam pacotes de software digitalmente para garantir que não foram adulterados.
- **Email Seguro (PGP/GPG)**: O PGP (Pretty Good Privacy) utiliza criptografia assimétrica para proteger o conteúdo dos e-mails e garantir a autenticidade do remetente.
- **VPN**: Criptografia do tráfego de rede para proteger a privacidade dos usuários.
- **Infraestrutura de chave pública (PKI)**: Gerenciamento de certificados digitais e hierarquias de confiança.

## Exemplos Práticos no Linux

A seguir, alguns exemplos de comandos para usar criptografia assimétrica em uma máquina Ubuntu.


### 1. Criação de Chaves Públicas e Privadas

Primeiro, vamos gerar um par de chaves (privada e pública), o qual será usado em todos os exemplos seguintes.

#### Passos:
1. **Gerar a chave privada**:
   Para criar a chave privada, use o comando abaixo. A chave será armazenada no arquivo `private.key`.

   ```bash
   openssl genpkey -algorithm RSA -out private.key -aes256
   ```
   A opção `-aes256` adiciona criptografia à chave privada gerada (se preferir uma chave sem criptografia, omita esta opção).

2. **Gerar a chave pública**:
   A chave pública será derivada da chave privada. Para gerar a chave pública, use o comando abaixo:

   ```bash
   openssl rsa -pubout -in private.key -out public.key
   ```
   Aqui, `private.key` é a chave privada que criamos antes e o comando gera a chave pública em `public.key`.

### 2. Exemplo 1: Criptografia e Descriptografia de Arquivos

Neste exemplo, vamos criptografar e descriptografar arquivos usando o par de chaves.

#### Passos:
1. **Criptografar um arquivo com a chave pública**:
   Digamos que temos um arquivo `data.txt` que queremos criptografar. Para criptografar o arquivo com a chave pública, usamos o comando:

   ```bash
   openssl rsautl -encrypt -inkey public.key -pubin -in data.txt -out encrypted_data.bin
   ```

   Isso vai criptografar o arquivo `data.txt` e gerar o arquivo criptografado `encrypted_data.bin`.

2. **Descriptografar o arquivo com a chave privada**:
   Agora, para descriptografar o arquivo, você deve usar a chave privada:

   ```bash
   openssl rsautl -decrypt -inkey private.key -in encrypted_data.bin -out decrypted_data.txt
   ```

   O arquivo `decrypted_data.txt` conterá o conteúdo original de `data.txt`.

**Comportamento esperado**:
- A criptografia com a chave pública só pode ser descriptografada com a chave privada correspondente.
- Isso garante que apenas o destinatário que possui a chave privada correta pode acessar os dados.

### 3. Exemplo 2: Assinatura Digital de Arquivo

Agora vamos mostrar como assinar digitalmente um arquivo. A assinatura digital serve para garantir a integridade e autenticidade de um arquivo, ou seja, que ele foi realmente criado pelo proprietário da chave privada.

#### Passos:
1. **Gerar a assinatura digital**:
   Primeiro, vamos assinar um arquivo (`data.txt`) com nossa chave privada. Isso é feito com o seguinte comando:

   ```bash
   openssl dgst -sha256 -sign private.key -out signature.bin data.txt
   ```

   Aqui, estamos assinando o arquivo `data.txt` com a chave privada, e a assinatura é armazenada em `signature.bin`.

2. **Verificar a assinatura com a chave pública**:
   Para verificar a assinatura, qualquer pessoa com a chave pública pode usar o comando:

   ```bash
   openssl dgst -sha256 -verify public.key -signature signature.bin data.txt
   ```

   Se a assinatura for válida, o OpenSSL mostrará algo como:

   ```bash
   Verified OK
   ```

**Comportamento esperado**:
- A assinatura digital prova que o arquivo não foi alterado e que foi assinado pela chave privada correspondente à chave pública.
- Se o arquivo for alterado, a assinatura digital não será mais válida.

3. **Alterar o arquivo e verificar novamente a assinatura**:
   Para verificar a integridade, altere o arquivo `data.txt` (por exemplo, edite o conteúdo do arquivo) e execute o comando de verificação da assinatura novamente:

   ```bash
   openssl dgst -sha256 -verify public.key -signature signature.bin data.txt
   ```

   O OpenSSL retornará:

   ```bash
   Verification Failure
   ```

   Isso mostra que a assinatura não é mais válida, já que o arquivo foi alterado.

### 4. Exemplo 3: Envio Seguro de Mensagem

Uma utilização comum da criptografia assimétrica é enviar mensagens seguras. Neste exemplo, vamos criptografar uma mensagem com a chave pública de um destinatário, garantindo que apenas o destinatário com a chave privada correspondente possa descriptografá-la.

#### Passos:
1. **Criptografar uma mensagem com a chave pública**:
   Suponha que você tem a mensagem no arquivo `message.txt` e quer enviá-la de forma segura. Você pode criptografá-la com a chave pública do destinatário:

   ```bash
   openssl rsautl -encrypt -inkey recipient_public.key -pubin -in message.txt -out encrypted_message.bin
   ```

2. **Descriptografar a mensagem com a chave privada do destinatário**:
   O destinatário, ao receber a mensagem criptografada, pode usar sua chave privada para descriptografar o conteúdo:

   ```bash
   openssl rsautl -decrypt -inkey recipient_private.key -in encrypted_message.bin -out decrypted_message.txt
   ```

### 5. Exemplo 4: Assinar e Criptografar Arquivo com Chave Privada e Pública

Neste exemplo, vamos passar por um processo onde um arquivo será assinado digitalmente, criptografado com a chave pública do destinatário, e depois, no destino, o arquivo será descriptografado com a chave privada do destinatário e a assinatura será validada.

### Fluxo do Processo:

1. **Assinar Digitalmente o Arquivo**: O arquivo é assinado digitalmente para garantir sua autenticidade e integridade.
2. **Criptografar o Arquivo com a Chave Pública do Destinatário**: Após a assinatura, o arquivo é criptografado com a chave pública do destinatário.
3. **Descriptografar o Arquivo com a Chave Privada do Destinatário**: O destinatário usa sua chave privada para descriptografar o arquivo.
4. **Validar a Assinatura Digital**: O destinatário usa a chave pública do remetente para validar a assinatura digital.

#### Passo 1: Assinar Digitalmente o Arquivo com a Sua Chave Privada

Para assinar o arquivo (por exemplo, `documento.txt`) com sua chave privada, use o seguinte comando:

```bash
openssl dgst -sha256 -sign private.key -out signature.bin documento.txt
```

- `private.key`: sua chave privada.
- `documento.txt`: o arquivo que você deseja assinar.
- `signature.bin`: a assinatura digital gerada.

#### Passo 2: Criptografar o Arquivo com a Chave Pública do Destinatário

Agora, para garantir que somente o destinatário possa ler o arquivo, criptografe-o com a chave pública do destinatário:

```bash
openssl rsautl -encrypt -inkey recipient_public.key -pubin -in documento.txt -out encrypted_document.bin
```

- `recipient_public.key`: a chave pública do destinatário.
- `documento.txt`: o arquivo a ser criptografado.
- `encrypted_document.bin`: o arquivo criptografado gerado.

#### Passo 3: Descriptografar o Arquivo com a Chave Privada do Destinatário

O destinatário, ao receber o arquivo criptografado, pode usar sua chave privada para descriptografá-lo:

```bash
openssl rsautl -decrypt -inkey recipient_private.key -in encrypted_document.bin -out decrypted_document.txt
```

- `recipient_private.key`: a chave privada do destinatário (que será usada para descriptografar o arquivo).
- `encrypted_document.bin`: o arquivo criptografado recebido.
- `decrypted_document.txt`: o arquivo descriptografado, que deve ser igual ao arquivo original `documento.txt`.

#### Passo 4: Validar a Assinatura Digital com a Sua Chave Pública

Por fim, o destinatário pode verificar a autenticidade do arquivo descriptografado usando sua chave pública. Isso garantirá que o arquivo não foi alterado e foi assinado por você.

```bash
openssl dgst -sha256 -verify public.key -signature signature.bin decrypted_document.txt
```

- `public.key`: sua chave pública (que você deve fornecer ao destinatário).
- `signature.bin`: a assinatura digital gerada na etapa 1.
- `decrypted_document.txt`: o arquivo que foi descriptografado e que deve ser validado.

Se a assinatura for válida, o OpenSSL mostrará:

```
Verified OK
```

Se a assinatura não for válida, será retornado:

```
Verification Failure
```

#### Conclusão

Esse fluxo de trabalho garante que:

1. O arquivo foi assinado digitalmente, garantindo autenticidade e integridade.
2. O arquivo foi criptografado com a chave pública do destinatário, garantindo confidencialidade.
3. O destinatário pode descriptografar o arquivo com sua chave privada e validar a assinatura com a chave pública do remetente.

### 6. Exemplo 5: Assinatura Digital, Criptografia com Chave Pública, Descriptografia com Chave Privada e Verificação de Integridade com Hash

Neste exemplo, vamos passar por um processo onde:

1. Um **arquivo é assinado digitalmente** para garantir a autenticidade.
2. O **arquivo é criptografado** com a **chave pública do destinatário** para garantir que apenas o destinatário possa lê-lo.
3. O **arquivo criptografado é enviado** ao destinatário.
4. No destino, o **arquivo é descriptografado** com a **chave privada do destinatário**.
5. A **assinatura digital é verificada** para garantir que o arquivo não foi alterado.
6. Finalmente, a **integridade do arquivo é validada** utilizando um **hash SHA-256**.

### Passo a Passo:

#### 1. **Assinar Digitalmente o Arquivo com Sua Chave Privada**

Primeiro, você assina o arquivo (`documento.txt`) para garantir a autenticidade e integridade do arquivo.

```bash
openssl dgst -sha256 -sign private.key -out signature.bin documento.txt
```

- `private.key`: sua chave privada.
- `documento.txt`: o arquivo que você deseja assinar.
- `signature.bin`: a assinatura digital gerada.

#### 2. **Gerar um Hash do Arquivo para Verificação de Integridade**

Agora, vamos gerar um hash SHA-256 do arquivo original. Isso garantirá que o arquivo não tenha sido alterado durante a transmissão.

```bash
openssl dgst -sha256 documento.txt > document_hash.txt
```

- `document_hash.txt`: arquivo contendo o hash SHA-256 do arquivo `documento.txt`.

#### 3. **Criptografar o Arquivo com a Chave Pública do Destinatário**

Depois de assinar o arquivo e gerar o hash para verificação de integridade, criptografe o arquivo com a **chave pública do destinatário** para garantir que apenas ele possa ler o conteúdo.

```bash
openssl rsautl -encrypt -inkey recipient_public.key -pubin -in documento.txt -out encrypted_document.bin
```

- `recipient_public.key`: a chave pública do destinatário.
- `documento.txt`: o arquivo a ser criptografado.
- `encrypted_document.bin`: o arquivo criptografado gerado.

#### 4. **Descriptografar o Arquivo com a Chave Privada do Destinatário**

O destinatário recebe o arquivo criptografado e o descriptografa usando sua chave privada:

```bash
openssl rsautl -decrypt -inkey recipient_private.key -in encrypted_document.bin -out decrypted_document.txt
```

- `recipient_private.key`: a chave privada do destinatário.
- `encrypted_document.bin`: o arquivo criptografado recebido.
- `decrypted_document.txt`: o arquivo descriptografado, que deve ser igual ao arquivo original `documento.txt`.

#### 5. **Verificar a Assinatura Digital com a Sua Chave Pública**

Agora, o destinatário pode verificar a assinatura digital do arquivo descriptografado usando sua chave pública:

```bash
openssl dgst -sha256 -verify public.key -signature signature.bin decrypted_document.txt
```

- `public.key`: sua chave pública (que você deve fornecer ao destinatário).
- `signature.bin`: a assinatura digital gerada na etapa 1.
- `decrypted_document.txt`: o arquivo descriptografado que será validado.

Se a assinatura for válida, o OpenSSL mostrará:

```
Verified OK
```

Caso contrário, ele retornará:

```
Verification Failure
```

#### 6. **Verificar a Integridade do Arquivo com o Hash**

Por fim, o destinatário pode verificar a integridade do arquivo usando o hash gerado anteriormente. Para isso, ele gera o hash do arquivo descriptografado e compara com o hash original.

1. **Gerar o hash SHA-256 do arquivo descriptografado**:

```bash
openssl dgst -sha256 decrypted_document.txt
```

2. **Comparar com o hash original**:

Se o hash gerado do arquivo descriptografado corresponder ao hash armazenado no arquivo `document_hash.txt`, a integridade do arquivo está garantida. O comando seria:

```bash
diff document_hash.txt <(openssl dgst -sha256 decrypted_document.txt)
```

Se os hashes coincidirem, isso confirma que o arquivo não foi alterado.

### Resumo do Fluxo:

1. **Assinatura Digital**:
   - `openssl dgst -sha256 -sign private.key -out signature.bin documento.txt`
   
2. **Gerar Hash para Verificação de Integridade**:
   - `openssl dgst -sha256 documento.txt > document_hash.txt`
   
3. **Criptografar com a Chave Pública do Destinatário**:
   - `openssl rsautl -encrypt -inkey recipient_public.key -pubin -in documento.txt -out encrypted_document.bin`
   
4. **Descriptografar com a Chave Privada do Destinatário**:
   - `openssl rsautl -decrypt -inkey recipient_private.key -in encrypted_document.bin -out decrypted_document.txt`
   
5. **Verificar a Assinatura Digital**:
   - `openssl dgst -sha256 -verify public.key -signature signature.bin decrypted_document.txt`
   
6. **Verificar a Integridade com o Hash**:
   - `openssl dgst -sha256 decrypted_document.txt`
   - `diff document_hash.txt <(openssl dgst -sha256 decrypted_document.txt)`
