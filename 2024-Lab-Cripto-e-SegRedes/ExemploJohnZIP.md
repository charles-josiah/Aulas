 Gerar e Proteger um Arquivo ZIP com Senha

## 1. Criando um arquivo ZIP protegido por senha

No Linux, você pode usar o comando `zip` com a opção `-e` para proteger o arquivo com uma senha. Este comando cria um arquivo ZIP que contém arquivos protegidos por senha.

### Comando:

```bash
zip -e arquivo.zip arquivo1.txt arquivo2.txt
```
Opções:
    -e: habilita a proteção por senha.
    arquivo.zip: nome do arquivo ZIP a ser criado.
    arquivo1.txt, arquivo2.txt: arquivos que serão incluídos no ZIP.

Você será solicitado a definir uma senha para proteger o arquivo ZIP.

## Extraindo o Hash de um Arquivo ZIP

Depois de criar um arquivo ZIP protegido por senha, você pode usar a ferramenta zip2john para extrair o hash desse arquivo. 
O hash pode ser usado para tentar quebrar a senha com ferramentas de força bruta, como o John the Ripper.

### Comando:

```bash
zip2john arquivo.zip > hash_zip.txt
```
Este comando gera o hash do arquivo ZIP e salva no arquivo hash_zip.txt.

## Quebrando a Senha Usando John the Ripper

Agora que você tem o hash da senha no arquivo hash_zip.txt, você pode usar o John the Ripper para tentar quebrar a senha.

### Comando:

```bash
john hash_zip.txt
```
O John the Ripper vai iniciar o processo de tentativa de quebra de senha usando ataques de dicionário ou força bruta.

