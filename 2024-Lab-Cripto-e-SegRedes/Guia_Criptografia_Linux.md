# Usando Criptografia em Linux com Diversos Algoritmos

Este documento apresenta um guia abrangente e passo a passo sobre a utilização de algoritmos de criptografia no sistema Linux, com ênfase em algoritmos de bloco e de fluxo. Serão explorados os seguintes algoritmos: **DES**, **3DES**, **AES** (128, 192 e 256 bits), **IDEA**, **Blowfish**, **Twofish**, **RC4** e **ChaCha20**. Para cada um desses algoritmos, serão fornecidas instruções detalhadas sobre como criptografar e descriptografar arquivos utilizando a ferramenta OpenSSL.

Este documento apresenta um guia abrangente e passo a passo sobre a utilização de algoritmos de criptografia no sistema Linux, com ênfase em algoritmos de bloco e de fluxo.

Relembrando... 

### Criptografia de Bloco
A criptografia de bloco é um método que processa dados em unidades fixas de tamanho específico, conhecidas como blocos. Cada bloco é criptografado de forma independente, permitindo que grandes volumes de dados sejam manipulados de maneira eficiente. Esse tipo de criptografia é particularmente eficaz para proteger dados em repouso e em ambientes onde a integridade e a confidencialidade das informações são essenciais. Exemplos de algoritmos de criptografia de bloco incluem **DES**, **3DES**, **AES**, **IDEA**, **Blowfish** e **Twofish**.

### Criptografia de Fluxo
A criptografia de fluxo, por sua vez, opera em dados de maneira contínua, criptografando um bit ou byte de cada vez. Essa abordagem é ideal para aplicações que requerem um fluxo constante de dados, como transmissões de vídeo e áudio, onde a latência deve ser minimizada. Ao permitir que os dados sejam processados em tempo real, a criptografia de fluxo oferece flexibilidade e eficiência em cenários dinâmicos. Algoritmos de criptografia de fluxo populares incluem **RC4** e **ChaCha20**.

<br><br>
Bora meter a mão na massa....
<hr>

## Pré-requisitos

Antes de começar, certifique-se de ter o **OpenSSL** instalado em sua máquina Linux. Você pode instalar o OpenSSL com o seguinte comando:

```bash
### Debian like
sudo apt-get update
sudo apt-get install openssl

### Redhat like
sudo yum install openssl
sudo dnf install openssl
```

## 1. Algoritmos de Criptografia de Bloco

Os algoritmos de criptografia de bloco dividem os dados em blocos fixos e os criptografam.

### 1.1 DES (Data Encryption Standard)

#### Criptografar

```bash
openssl enc -des -in arquivo.txt -out arquivo_encrypted.des -k "sua_senha"
```

#### Descriptografar

```bash
openssl enc -des -d -in arquivo_encrypted.des -out arquivo_decrypted.txt -k "sua_senha"
```

### 1.2 3DES (Triple DES)

#### Criptografar

```bash
openssl enc -des3 -in arquivo.txt -out arquivo_encrypted.des3 -k "sua_senha"
```

#### Descriptografar

```bash
openssl enc -des3 -d -in arquivo_encrypted.des3 -out arquivo_decrypted.txt -k "sua_senha"
```

### 1.3 AES (Advanced Encryption Standard)

#### AES-128

##### Criptografar

```bash
openssl enc -aes-128-cbc -in arquivo.txt -out arquivo_encrypted.aes128 -k "sua_senha"
```

##### Descriptografar

```bash
openssl enc -aes-128-cbc -d -in arquivo_encrypted.aes128 -out arquivo_decrypted.txt -k "sua_senha"
```

#### AES-192

##### Criptografar

```bash
openssl enc -aes-192-cbc -in arquivo.txt -out arquivo_encrypted.aes192 -k "sua_senha"
```

##### Descriptografar

```bash
openssl enc -aes-192-cbc -d -in arquivo_encrypted.aes192 -out arquivo_decrypted.txt -k "sua_senha"
```

#### AES-256

##### Criptografar

```bash
openssl enc -aes-256-cbc -in arquivo.txt -out arquivo_encrypted.aes256 -k "sua_senha"
```

##### Descriptografar

```bash
openssl enc -aes-256-cbc -d -in arquivo_encrypted.aes256 -out arquivo_decrypted.txt -k "sua_senha"
```

### 1.4 IDEA

#### Criptografar

```bash
openssl enc -idea -in arquivo.txt -out arquivo_encrypted.idea -k "sua_senha"
```

#### Descriptografar

```bash
openssl enc -idea -d -in arquivo_encrypted.idea -out arquivo_decrypted.txt -k "sua_senha"
```

### 1.5 Blowfish

#### Criptografar

```bash
openssl enc -bf -in arquivo.txt -out arquivo_encrypted.blowfish -k "sua_senha"
```

#### Descriptografar

```bash
openssl enc -bf -d -in arquivo_encrypted.blowfish -out arquivo_decrypted.txt -k "sua_senha"
```

### 1.6 Twofish

**Nota:** O **OpenSSL** não suporta **Twofish** diretamente. Você pode usar outras ferramentas, como o **GPG**, ou bibliotecas como **libgcrypt** para implementá-lo. Aqui está como usar o GPG.

#### Criptografar com GPG

```bash
gpg --symmetric --cipher-algo TWOFISH arquivo.txt
```

#### Descriptografar com GPG

```bash
gpg --decrypt arquivo.txt.gpg
```

## 2. Algoritmos de Criptografia de Fluxo

Os algoritmos de criptografia de fluxo processam os dados de forma contínua, criptografando um byte de cada vez.

### 2.1 RC4

#### Criptografar

```bash
openssl enc -rc4 -in arquivo.txt -out arquivo_encrypted.rc4 -k "sua_senha"
```

#### Descriptografar

```bash
openssl enc -rc4 -d -in arquivo_encrypted.rc4 -out arquivo_decrypted.txt -k "sua_senha"
```

### 2.2 ChaCha20

**Nota:** O **OpenSSL** oferece suporte ao ChaCha20. 

#### Criptografar

```bash
openssl enc -chacha20 -in arquivo.txt -out arquivo_encrypted.chacha20 -k "sua_senha"
```

#### Descriptografar

```bash
openssl enc -chacha20 -d -in arquivo_encrypted.chacha20 -out arquivo_decrypted.txt -k "sua_senha"
```
<br>
<hr>

# Tabela Comparativa de Algoritmos de Criptografia

| Algoritmo        | Tipo           | Resistência a Ataques            | Nível de Segurança         |
|------------------|----------------|-----------------------------------|---------------------------|
| DES              |  Bloco          | Baixo                             | Baixo (obsoleto)          |
| 3DES             |  Bloco          | Médio                             | Moderado                  |
| AES-128          |  Bloco          | Alto                              | Alto                      |
| AES-192          |  Bloco          | Alto                              | Alto                      |
| AES-256          |  Bloco          | Muito Alto                        | Muito Alto                |
| IDEA             |  Bloco          | Médio                             | Moderado                  |
| Blowfish         |  Bloco          | Alto                              | Alto                      |
| Twofish          |  Bloco          | Alto                              | Alto                      |
| RC4              |  Fluxo          | Médio                             | Baixo (vulnerável a ataques) |
| ChaCha20         |  Fluxo          | Alto                              | Alto                      |
| Twofish (GPG)    |  Fluxo          | Alto                              | Alto                      |

## Considerações:

- **DES** e **3DES** são considerados obsoletos devido ao seu baixo nível de segurança. O DES, em particular, é vulnerável a ataques de força bruta.
- **AES** é amplamente aceito como um dos algoritmos mais seguros, especialmente nas variantes de 256 bits.
- **RC4** é vulnerável a várias técnicas de ataque, tornando-o inadequado para muitas aplicações de segurança.
- **ChaCha20** é considerado um algoritmo seguro e eficiente, especialmente em dispositivos móveis e ambientes com recursos limitados.
- **IDEA**, **Blowfish** e **Twofish** oferecem um bom nível de segurança e são respeitados, mas suas aplicações podem ser limitadas em comparação com o AES.

Essas avaliações podem variar conforme o contexto de uso, as implementações específicas e os avanços nas técnicas de quebra de criptografia. É sempre importante usar algoritmos atualizados e seguir as melhores práticas de segurança.


## Considerações Finais

Este guia fornece uma visão geral de como usar diferentes algoritmos de criptografia em Linux, tanto para criptografia de bloco quanto de fluxo. Lembre-se de sempre usar senhas fortes e manter suas chaves seguras.


:wq!
