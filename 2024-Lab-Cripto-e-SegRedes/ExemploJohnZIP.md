# Objetivo
Este exemplo mostra como criar um arquivo ZIP protegido por senha e, em seguida, como extrair o hash desse arquivo e quebrar a senha usando a ferramenta **John the Ripper**.

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


## Exemplo na linha de comando

```                                                                                                                       
┌──(vagrant㉿kali)-[~]
└─$ zip -e arq.zip readme.txt        
Enter password: 
Verify password: 
updating: readme.txt (deflated 52%)
                                                                                                                          
┌──(vagrant㉿kali)-[~]
└─$ zip2john arq.zip > hash_zip.txt   
ver 2.0 efh 5455 efh 7875 arq.zip/readme.txt PKZIP Encr: TS_chk, cmplen=405, decmplen=821, crc=795A2E70 ts=9BE9 cs=9be9 type=8
                                                                                                                          
┌──(vagrant㉿kali)-[~]
└─$ cat hash_zip.txt                 
arq.zip/readme.txt:$pkzip$1*1*2*0*195*335*795a2e70*0*44*8*195*9be9*857629966e80a655e8e27b50fae9b3af3ba315d3554f2a1f9f08286c66f7ca1dcccf9e99b67582bebfb424a57dcbff7637e0f9ae106de227bb572ff8af49e95dfba4aa48770024da85acd9c5dc349518891733523552a16c8ae7ff760000b1648c4f94eb0aee92225d4f2b1c3c0f567d2cc8fb37f310666a58a96e60c50b3ed6b139e0d4fe3ed35fe3fec71d8fd30d583db56e73d037a0061ca63ef7adb694bc801ee94c1438f8ff7a2460d6566e505a46c0cd5ae5004dbe8c77a1209b59577704b5dfce853a72f807d1f3a14630177c5607b49068f4a6286365cf16d3febb9856b28fa46c356859b9c98d806223237579b5cf93178c8636b83110a7fbf8f31286f38734fdc039802ecfa12c5fedcbe461a05e17e909e6d6654b08ba47e48289cd0f853e7ae8d2f3fba1d6baca31a7445751127db1d5daff4e2d6bc436346a20d2f0b93cead4f6931f4db1a8bd57c539ec100f347f3099478469bbfc5104b950e13b072c1c4ea2f1013664c562bbbe4ff89bf6c69965b260cf210ad7d08c8a42536fae037d519ff80bae849e37f6b8e7e31f632b8a*$/pkzip$:readme.txt:arq.zip::arq.zip
                                                                                                                          
┌──(vagrant㉿kali)-[~]
└─$ time john hash_zip.txt         
Using default input encoding: UTF-8
Loaded 1 password hash (PKZIP [32/64])
Will run 2 OpenMP threads
Proceeding with single, rules:Single
Press 'q' or Ctrl-C to abort, almost any other key for status
Almost done: Processing the remaining buffered candidate passwords, if any.
Proceeding with wordlist:/usr/share/john/password.lst
Proceeding with incremental:ASCII
teste123         (arq.zip/readme.txt)     
1g 0:00:00:30 DONE 3/3 (2024-10-08 23:05) 0.03276g/s 23885Kp/s 23885Kc/s 23885KC/s tedwahad..tesuebal
Use the "--show" option to display all of the cracked passwords reliably
Session completed. 

real    30.58s
user    59.58s
sys     0.26s
cpu     195%
                                                                                                                          
┌──(vagrant㉿kali)-[~]
└─$ 


```

