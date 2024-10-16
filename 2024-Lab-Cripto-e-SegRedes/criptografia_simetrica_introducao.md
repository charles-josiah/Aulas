# Criptografia Assimétrica: Conceitos Básicos, Usabilidade, Casos de Uso e Exemplos em Ubuntu

## 1. Introdução à Criptografia Assimétrica

A criptografia assimétrica, também conhecida como criptografia de chave pública, é um método de criptografia que utiliza um par de chaves para proteger dados. Esses pares de chaves consistem em:

- **Chave pública**: Pode ser distribuída livremente. É usada para criptografar dados ou para verificar assinaturas digitais.
- **Chave privada**: Deve ser mantida em segredo. É usada para descriptografar dados criptografados com a chave pública correspondente ou para assinar digitalmente mensagens.

A segurança desse método baseia-se na dificuldade computacional de fatorar grandes números primos (para algoritmos como RSA) ou resolver problemas de logaritmo discreto (para algoritmos como ECC - Curva Elíptica).

## 2. Conceitos Básicos

- **Criptografia**: Processo de codificar informações para que apenas as partes autorizadas possam lê-las.
- **Chave Pública**: Usada para criptografar mensagens. Pode ser compartilhada publicamente sem comprometer a segurança.
- **Chave Privada**: Mantida em segredo, usada para descriptografar mensagens criptografadas com a chave pública correspondente.
- **Assinatura Digital**: Usada para garantir a integridade e a autenticidade de uma mensagem ou documento. É criada com a chave privada e verificada com a chave pública.
- **Certificados Digitais**: Documentos eletrônicos que associam uma chave pública a uma identidade, geralmente emitidos por uma Autoridade Certificadora (CA).

## 3. Usabilidade

A criptografia assimétrica é amplamente utilizada em diversos cenários, como:

- **Comunicação segura (TLS/SSL)**: A criptografia assimétrica é usada para estabelecer conexões seguras na web. O protocolo HTTPS usa certificados digitais para autenticar servidores e criptografar dados transmitidos.
- **Assinaturas digitais**: As assinaturas digitais garantem que uma mensagem ou documento não foi alterado e foi enviado por uma fonte autenticada.
- **Troca de chaves seguras**: O protocolo de troca de chaves Diffie-Hellman permite que duas partes gerem uma chave de sessão compartilhada para comunicação segura.
- **Autenticação**: Utilizada em sistemas de autenticação multifatorial, como SSH, onde a chave pública do usuário é armazenada no servidor e a chave privada é usada para autenticação.

## 4. Casos de Uso

- **Comunicação Segura na Web**: A maioria dos sites utiliza criptografia assimétrica para proteger dados transmitidos, como senhas e informações de pagamento, por meio do HTTPS.
- **Autenticação SSH**: Para acessar servidores de forma segura, utiliza-se a autenticação baseada em chaves SSH.
- **Assinatura de Software**: Os desenvolvedores assinam pacotes de software digitalmente para garantir que não foram adulterados.
- **Email Seguro (PGP/GPG)**: O PGP (Pretty Good Privacy) utiliza criptografia assimétrica para proteger o conteúdo dos e-mails e garantir a autenticidade do remetente.
- **VPN**: Criptografia do tráfego de rede para proteger a privacidade dos usuários.
- **Infraestrutura de chave pública (PKI)**: Gerenciamento de certificados digitais e hierarquias de confiança.

## 5. Exemplos Práticos em Ubuntu

A seguir, alguns exemplos de comandos para usar criptografia assimétrica em uma máquina Ubuntu.

### 5.1. Gerando um Par de Chaves RSA com OpenSSL

Para gerar um par de chaves RSA com comprimento de 2048 bits:

```bash
openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in private_key.pem -out public_key.pem
```
- `private_key.pem` será o arquivo contendo a chave privada.
- `public_key.pem` será o arquivo contendo a chave pública correspondente.

### 5.2. Criptografando e Descriptografando com OpenSSL

- **Criptografar** um arquivo de texto com a chave pública:
```bash
openssl rsautl -encrypt -inkey public_key.pem -pubin -in arquivo_original.txt -out arquivo_encriptado.bin
```
- **Descriptografar** o arquivo com a chave privada:
```bash
openssl rsautl -decrypt -inkey private_key.pem -in arquivo_encriptado.bin -out arquivo_decriptado.txt
```

### 5.3. Criando e Verificando Assinaturas Digitais com OpenSSL

- **Assinar** um arquivo com a chave privada:
```bash
openssl dgst -sha256 -sign private_key.pem -out assinatura.bin arquivo_original.txt
```
- **Verificar**  a assinatura com a chave pública:
```bash
openssl dgst -sha256 -verify public_key.pem -signature assinatura.bin arquivo_original.txt
```

### 5.4. Gerenciamento de Chaves SSH

- **Gerar um par de chaves SSH:**

```bash
ssh-keygen -t rsa -b 4096 -C "seu_email@exemplo.com"
```

- Isso criará dois arquivos:
  - `~/.ssh/id_rsa`: Chave privada.
  - `~/.ssh/id_rsa.pub`: Chave pública.
- Adicionar a chave pública ao servidor:

```bash
ssh-copy-id usuario@servidor
```

### 5.5. Usando GPG para Criptografia e Assinatura de Emails

- **Gerar** um par de chaves GPG:

```bash
gpg --full-generate-key
```

- **Criptografar** um arquivo:

```bash
gpg --encrypt --recipient "email@exemplo.com" arquivo.txt
```

- **Assinar** um arquivo:

```bash
gpg --sign arquivo.txt
```

- **Verificar** uma assinatura:

```bash
gpg --verify arquivo.txt.gpg
```

<hr> 

### 6. Conclusão

A criptografia assimétrica é fundamental para a segurança digital moderna. 
Entender seus conceitos básicos e como utilizá-la em sistemas baseados em Linux, como o Ubuntu, pode aumentar significativamente a segurança de sistemas e dados. 
É amplamente aplicada em várias áreas, como comunicação segura, autenticação e proteção de dados, fornecendo uma camada adicional de proteção contra ataques e acessos não autorizados.

**Referências:**
- [Documentação do OpenSSL](https://www.openssl.org/docs/)
- [Manual do SSH no Ubuntu](https://manpages.ubuntu.com/manpages/bionic/en/man1/ssh.1.html)
- [Documentação do GPG](https://gnupg.org/documentation/)







:wq!
