# Aula sobre OpenSSL para Criptografia Assimétrica

## 1) Objetivo
O objetivo desta aula é mostrar como realizar criptografia assimétrica usando o OpenSSL. Vamos aprender a gerar chaves públicas e privadas, criptografar e descriptografar arquivos, assinar digitalmente arquivos e verificar a assinatura. Tudo isso utilizando comandos do OpenSSL no ambiente Linux.

## 2) Introdução à Criptografia Assimétrica
A criptografia assimétrica, também conhecida como criptografia de chave pública, é um método de criptografia que utiliza um par de chaves para proteger dados. Esses pares de chaves consistem em:

- **Chave pública**: Pode ser distribuída livremente. É usada para criptografar dados ou para verificar assinaturas digitais.
- **Chave privada**: Deve ser mantida em segredo. É usada para descriptografar dados criptografados com a chave pública correspondente ou para assinar digitalmente mensagens.

A segurança desse método baseia-se na dificuldade computacional de fatorar grandes números primos (para algoritmos como RSA) ou resolver problemas de logaritmo discreto (para algoritmos como ECC - Curva Elíptica).

## 3) Conceitos Básicos
- **Criptografia**: Processo de codificar informações para que apenas as partes autorizadas possam lê-las.
- **Chave Pública**: Usada para criptografar mensagens. Pode ser compartilhada publicamente sem comprometer a segurança.
- **Chave Privada**: Mantida em segredo, usada para descriptografar mensagens criptografadas com a chave pública correspondente.
- **Assinatura Digital**: Usada para garantir a integridade e a autenticidade de uma mensagem ou documento. É criada com a chave privada e verificada com a chave pública.
- **Certificados Digitais**: Documentos eletrônicos que associam uma chave pública a uma identidade, geralmente emitidos por uma Autoridade Certificadora (CA).

## 4) Infraestrutura de Chave Pública (PKI)
A **Infraestrutura de Chave Pública (PKI)** é o alicerce da criptografia assimétrica no mundo real. Ela é um conjunto de ferramentas e processos para criar, gerenciar e revogar **certificados digitais**.

Em essência, a PKI cria uma cadeia de confiança digital. Ela nos ajuda a responder a uma pergunta crucial: "Como posso ter certeza de que a chave pública que recebi realmente pertence à pessoa ou entidade que a enviou?". A estrutura principal da PKI inclui:

- **Autoridade Certificadora (CA)**: A CA é a entidade de maior confiança na PKI, como um "cartório digital". Ela verifica a identidade de uma pessoa ou empresa e, se a identidade for validada, emite um certificado digital assinado. A assinatura da CA é a garantia de que a chave pública no certificado pertence à entidade correta.
- **Certificado Digital**: É um documento eletrônico que conecta uma **chave pública** a uma identidade. O certificado contém informações como o nome do proprietário (ex: `banco.com`), a chave pública, a validade e a assinatura da CA.
- **Autoridade de Registro (RA)**: Uma entidade opcional que auxilia a CA na validação da identidade dos solicitantes, ajudando a garantir que o processo seja seguro.
- **Repositório de Certificados**: Um banco de dados público onde os certificados digitais emitidos são armazenados para que possam ser verificados.
- **Lista de Revogação de Certificados (CRL)**: Uma lista pública com os números de série de todos os certificados que foram revogados. A CRL é vital para anular a confiança em um certificado antes de sua data de expiração.

## 5) Pontos Cruciais do Certificado Digital
O certificado digital é a base de um sistema de confiança que garante a validade de uma identidade no mundo digital. Ele vai muito além de um simples arquivo de segurança, sendo o principal responsável por pontos inquestionáveis da nossa comunicação online.

1. **Assinatura da Autoridade Certificadora (CA)**
   - **Ponto Crucial**: A principal garantia de um certificado é a **assinatura digital de uma Autoridade Certificadora (CA) de confiança**. A CA é uma entidade neutra e rigorosa, como um "cartório digital", que verifica a identidade do emissor do certificado.
   - **Por que é Inquestionável**: Você não precisa confiar diretamente na empresa ou pessoa que te enviou o certificado, mas sim na reputação da CA. Seu navegador ou sistema operacional já vem com uma lista de CAs pré-aprovadas. A assinatura digital da CA é a prova de que ela validou a identidade e que o certificado não foi adulterado.

2. **Não Repúdio (Non-Repudiation)**
   - **Ponto Crucial**: O **não repúdio** garante que o emissor de um documento ou mensagem **não pode negar a autoria**. Quando alguém assina digitalmente algo com sua chave privada, o certificado digital vincula a assinatura inequivocamente à sua identidade.
   - **Por que é Inquestionável**: O processo de assinatura digital com a chave privada é criptograficamente único. Apenas o proprietário da chave privada pode gerar uma assinatura que corresponda à sua chave pública. Uma vez que a assinatura é feita, é impossível para o signatário negar que a criou.

3. **Autenticidade (Authentication)**
   - **Ponto Crucial**: O certificado digital prova a **autenticidade** de uma entidade. Ele garante que a pessoa ou o servidor com o qual você está se comunicando é, de fato, quem diz ser.
   - **Por que é Inquestionável**: A autenticidade é garantida pela **cadeia de confiança**. Seu sistema confia na CA, que por sua vez, confia na identidade do emissor do certificado. O certificado digital é como um "passaporte digital" que não pode ser falsificado, pois a assinatura da CA garante sua validade.

4. **Integridade (Integrity)**
   - **Ponto Crucial**: A **integridade** garante que o conteúdo de um documento ou mensagem **não foi alterado** após ter sido assinado.
   - **Por que é Inquestionável**: A assinatura digital é feita sobre um *hash* (resumo criptográfico) do documento original. Qualquer alteração, por menor que seja, no documento, gera um *hash* completamente diferente. Quando o receptor verifica a assinatura, a verificação falha se o *hash* não coincidir, provando que o documento foi adulterado.

5. **Confidencialidade (Confidentiality)**
   - **Ponto Crucial**: A **confidencialidade** garante que os dados trocados entre as partes não possam ser lidos por terceiros.
   - **Por que é Inquestionável**: A confidencialidade é geralmente implementada por meio de criptografia híbrida. O certificado digital é fundamental nesse processo, pois ele contém a chave pública da outra parte, que é usada para **criptografar a chave simétrica** de sessão. Sem o certificado, não há como estabelecer a comunicação segura inicial para a troca da chave.

## 6) Usabilidade
A criptografia assimétrica é amplamente utilizada em diversos cenários, como:

- **Comunicação segura (TLS/SSL)**: A criptografia assimétrica é usada para estabelecer conexões seguras na web. O protocolo HTTPS usa certificados digitais para autenticar servidores e criptografar dados transmitidos.
- **Assinaturas digitais**: As assinaturas digitais garantem que uma mensagem ou documento não foi alterado e foi enviado por uma fonte autenticada.
- **Troca de chaves seguras**: O protocolo de troca de chaves Diffie-Hellman permite que duas partes gerem uma chave de sessão compartilhada para comunicação segura.
- **Autenticação**: Utilizada em sistemas de autenticação multifatorial, como SSH, onde a chave pública do usuário é armazenada no servidor e a chave privada é usada para autenticação.

## 7) Casos de Uso
- **Comunicação Segura na Web**: A maioria dos sites utiliza criptografia assimétrica para proteger dados transmitidos, como senhas e informações de pagamento, por meio do HTTPS.
- **Autenticação SSH**: Para acessar servidores de forma segura, utiliza-se a autenticação baseada em chaves SSH.
- **Assinatura de Software**: Os desenvolvedores assinam pacotes de software digitalmente para garantir que não foram adulterados.
- **Email Seguro (PGP/GPG)**: O PGP (Pretty Good Privacy) utiliza criptografia assimétrica para proteger o conteúdo dos e-mails e garantir a autenticidade do remetente.
- **VPN**: Criptografia do tráfego de rede para proteger a privacidade dos usuários.
- **Infraestrutura de chave pública (PKI)**: Gerenciamento de certificados digitais e hierarquias de confiança.

## 8) Historinhas
### 8.1) O Exemplo do Banco: O Impacto de um Vazamento de Chave
Se a chave privada de um banco vaza, o impacto é catastrófico. É como se a fechadura da porta principal do banco fosse clonada e distribuída para criminosos.

**Impacto na Confidencialidade**: Qualquer pessoa que tenha a chave privada vazada pode interceptar e descriptografar qualquer comunicação que foi criptografada com a chave pública correspondente. Isso inclui informações sensíveis de clientes, como nomes de usuário, senhas, transações e dados de cartão de crédito. É um desastre de segurança total, pois toda a comunicação que se acreditava ser segura se torna pública.

**Impacto na Autenticidade**: Os criminosos podem usar a chave privada vazada para se passar pelo banco. Eles poderiam criar sites falsos (phishing) que parecem legítimos, e o navegador do usuário não conseguiria detectar a fraude porque o site falso apresentaria um certificado digital válido (assinado com a chave privada vazada). Isso permite que eles capturem dados de login e informações financeiras com facilidade, já que os usuários confiam no "cadeado" do navegador.

**Solução de Emergência**: A única solução para um vazamento de chave privada é revogar o certificado digital e gerar um novo par de chaves. Isso é um processo urgente e complexo. A revogação informa aos navegadores e sistemas que o certificado anterior não é mais confiável. No entanto, a propagação dessa informação pode levar tempo, e o risco permanece até que todos os sistemas reconheçam a revogação.

### 8.2) O Advogado e a Chave Privada (versão 2)
Imagine que a chave privada de um advogado é a sua **assinatura única e digitalmente reconhecida**. Ele a usa para assinar petições, contratos e documentos eletrônicos, garantindo a sua autenticidade e validade legal.

**Cenário de Perda:**

Quando um advogado perde o controle de sua chave privada — seja por um ataque de *malware*, roubo do computador ou um simples descuido —, ele não perde apenas um arquivo. Ele perde a capacidade de provar que é ele mesmo quem está assinando os documentos. Pior ainda, um criminoso que tenha acesso a essa chave agora pode:

1. **Assinar Documentos Falsos**: O criminoso pode criar petições falsas ou acordos fraudulentos, assinando-os digitalmente com a chave privada do advogado. Para o sistema judicial e para os clientes, a assinatura parecerá **completamente legítima**, pois a verificação com a chave pública do advogado (que é pública e associada a ele) seria bem-sucedida.
2. **Comprometer a Reputação**: A validade legal das assinaturas do advogado fica comprometida. Como não é possível saber quais documentos foram assinados por ele e quais foram assinados pelo criminoso, a confiança em todas as suas assinaturas digitais, tanto no passado quanto no presente, é destruída. Isso pode levar a processos judiciais, perda de clientes e danos irreparáveis à sua carreira.

Neste cenário, a revogação do certificado digital é a única medida de segurança que o advogado pode tomar para evitar que o criminoso continue usando sua identidade.

## 9) O Processo de Revogação de um Certificado
Revogar um certificado é o ato de declará-lo **inválido antes de sua data de expiração normal**. É um passo crítico para anular a confiança em um certificado comprometido, roubado ou perdido.

O processo funciona da seguinte forma:

1. **Notificação à Autoridade Certificadora (CA)**: O primeiro passo é entrar em contato imediatamente com a **Autoridade Certificadora (CA)** que emitiu o certificado. O advogado deve provar sua identidade e solicitar a revogação. A CA, como a "notária" digital, é a única entidade com autoridade para invalidar o certificado publicamente.
2. **Inclusão na Lista de Revogação (CRL)**: Após a validação do pedido, a CA inclui o certificado em uma **Lista de Revogação de Certificados (CRL)**. Essa lista é um banco de dados público que contém os números de série de todos os certificados que foram revogados. É como uma "lista negra" digital.
3. **Atualização dos Sistemas**: Navegadores, sistemas operacionais e outras aplicações que se comunicam de forma segura são configurados para consultar as CRLs periodicamente (ou usar protocolos de verificação em tempo real, como o OCSP). Quando um sistema tenta verificar um certificado e descobre que seu número de série está na CRL, ele rejeita o certificado imediatamente, mesmo que ele ainda não tenha expirado.
4. **Emissão de Novo Certificado**: Para voltar a operar, o advogado precisa gerar um novo par de chaves e solicitar um **novo certificado digital** à CA. Esse novo certificado não tem nenhuma relação com o comprometido, e o processo de assinatura pode ser retomado com segurança.

A revogação é uma corrida contra o tempo. A rapidez com que a CA atualiza sua CRL e com que os sistemas dos usuários consultam essa lista determina a janela de vulnerabilidade. É por isso que o vazamento de uma chave privada é considerado um incidente de segurança de altíssima gravidade.

## 10) Exemplos Práticos no Linux
A seguir, alguns exemplos de comandos para usar criptografia assimétrica em uma máquina Ubuntu.

### 10.1) Criação de Chaves Públicas e Privadas
Primeiro, vamos gerar um par de chaves (privada e pública), o qual será usado em todos os exemplos seguintes.

**Passos:**
1. **Gerar a chave privada**:  
   ```bash
   openssl genpkey -algorithm RSA -out private.key -aes256
   ```
   A opção `-aes256` adiciona criptografia à chave privada gerada (se preferir uma chave sem criptografia, omita esta opção).

2. **Gerar a chave pública**:  
   ```bash
   openssl rsa -pubout -in private.key -out public.key
   ```

### 10.2) Exemplo 1: Criptografia e Descriptografia de Arquivos
**Passos:**
1. **Criptografar com a chave pública**:  
   ```bash
   openssl rsautl -encrypt -inkey public.key -pubin -in data.txt -out encrypted_data.bin
   ```
2. **Descriptografar com a chave privada**:  
   ```bash
   openssl rsautl -decrypt -inkey private.key -in encrypted_data.bin -out decrypted_data.txt
   ```

**Comportamento esperado**:
- A criptografia com a chave pública só pode ser descriptografada com a chave privada correspondente.
- Isso garante que apenas o destinatário que possui a chave privada correta pode acessar os dados.

### 10.3) Exemplo 2: Assinatura Digital de Arquivo
**Passos:**
1. **Gerar a assinatura digital**:  
   ```bash
   openssl dgst -sha256 -sign private.key -out signature.bin data.txt
   ```
2. **Verificar a assinatura com a chave pública**:  
   ```bash
   openssl dgst -sha256 -verify public.key -signature signature.bin data.txt
   ```
   Saída esperada:
   ```
   Verified OK
   ```

3. **Alterar o arquivo e verificar novamente**:  
   ```bash
   openssl dgst -sha256 -verify public.key -signature signature.bin data.txt
   ```
   Saída esperada:
   ```
   Verification Failure
   ```

### 10.4) Exemplo 3: Envio Seguro de Mensagem
**Passos:**
1. **Criptografar a mensagem com a chave pública do destinatário**:  
   ```bash
   openssl rsautl -encrypt -inkey recipient_public.key -pubin -in message.txt -out encrypted_message.bin
   ```
2. **Descriptografar com a chave privada do destinatário**:  
   ```bash
   openssl rsautl -decrypt -inkey recipient_private.key -in encrypted_message.bin -out decrypted_message.txt
   ```

### 10.5) Exemplo 4: Assinar e Criptografar Arquivo
**Fluxo do Processo:**
1. Assinar digitalmente o arquivo.  
2. Criptografar com a chave pública do destinatário.  
3. Descriptografar com a chave privada do destinatário.  
4. Validar a assinatura digital.

**Passo 1: Assinar**  
```bash
openssl dgst -sha256 -sign private.key -out signature.bin documento.txt
```

**Passo 2: Criptografar**  
```bash
openssl rsautl -encrypt -inkey recipient_public.key -pubin -in documento.txt -out encrypted_document.bin
```

**Passo 3: Descriptografar**  
```bash
openssl rsautl -decrypt -inkey recipient_private.key -in encrypted_document.bin -out decrypted_document.txt
```

**Passo 4: Verificar assinatura**  
```bash
openssl dgst -sha256 -verify public.key -signature signature.bin decrypted_document.txt
```

**Conclusão do fluxo**:
1. Arquivo assinado (autenticidade e integridade).  
2. Arquivo criptografado com a chave pública do destinatário (confidencialidade).  
3. Destinatário descriptografa e valida a assinatura.

### 10.6) Exemplo 5: Assinatura, Criptografia, Descriptografia e Verificação de Integridade com Hash
**Passo a Passo:**

1. **Assinar**  
   ```bash
   openssl dgst -sha256 -sign private.key -out signature.bin documento.txt
   ```

2. **Gerar hash (SHA-256)**  
   ```bash
   openssl dgst -sha256 documento.txt > document_hash.txt
   ```

3. **Criptografar com a chave pública do destinatário**  
   ```bash
   openssl rsautl -encrypt -inkey recipient_public.key -pubin -in documento.txt -out encrypted_document.bin
   ```

4. **Descriptografar com a chave privada do destinatário**  
   ```bash
   openssl rsautl -decrypt -inkey recipient_private.key -in encrypted_document.bin -out decrypted_document.txt
   ```

5. **Verificar a assinatura**  
   ```bash
   openssl dgst -sha256 -verify public.key -signature signature.bin decrypted_document.txt
   ```

6. **Verificar a integridade com o hash**  
   - Gerar hash do descriptografado:  
     ```bash
     openssl dgst -sha256 decrypted_document.txt
     ```
   - Comparar com o hash original:  
     ```bash
     diff document_hash.txt <(openssl dgst -sha256 decrypted_document.txt)
     ```

**Resumo do Fluxo:**
1. **Assinatura Digital**  
   `openssl dgst -sha256 -sign private.key -out signature.bin documento.txt`
2. **Gerar Hash**  
   `openssl dgst -sha256 documento.txt > document_hash.txt`
3. **Criptografar (chave pública do destinatário)**  
   `openssl rsautl -encrypt -inkey recipient_public.key -pubin -in documento.txt -out encrypted_document.bin`
4. **Descriptografar (chave privada do destinatário)**  
   `openssl rsautl -decrypt -inkey recipient_private.key -in encrypted_document.bin -out decrypted_document.txt`
5. **Verificar Assinatura**  
   `openssl dgst -sha256 -verify public.key -signature signature.bin decrypted_document.txt`
6. **Verificar Integridade (hash)**  
   `openssl dgst -sha256 decrypted_document.txt`  
   `diff document_hash.txt <(openssl dgst -sha256 decrypted_document.txt)`
