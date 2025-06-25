
# Aula: Análise de Vulnerabilidades com OpenVAS e Nessus

**Objetivo:** Montar um ambiente seguro para análise de vulnerabilidades e comparar os scanners OpenVAS e Nessus utilizando aplicações vulneráveis (DVWA e Metasploitable 2).

---

## Introdução e Conceitos

- O que é uma vulnerabilidade?
- Fases do ciclo de segurança: identificação, análise, mitigação.
- O que são scanners de vulnerabilidades?
- Ferramentas utilizadas:
  - OpenVAS (Greenbone)
  - Nessus (Tenable)
- Imagens para testes 
  - Metasploitable 2
  - DVWA

---

## Ambiente em Docker para o laboratorio

### Pré-requisitos

- Docker e Docker Compose instalados
- Rede Docker customizada:
  ```bash
  docker network create --subnet=192.168.100.0/24 vuln_net
  ```

### 1. DVWA em Docker

```bash
git clone https://github.com/digininja/DVWA.git
cd DVWA
docker run -d --rm --name dvwa \
  -p 8080:80 \
  --network vuln_net \
  --ip 192.168.100.10 \
  vulnerables/web-dvwa
```

### 2. Metasploitable 2

Executar como VM (VirtualBox) com IP estático (ex: `192.168.100.20`).

### 3. OpenVAS via Docker

```bash
docker run -d --name openvas \
  -p 9392:9392 \
  -p 433:433
  -e PUBLIC_HOSTNAME=192.168.100.30
  --network vuln_net \
  --ip 192.168.100.30 \
  mikesplain/openvas
```

Acessar: `https://localhost:9392`  
Usuário: `admin` (senha gerada nos logs)

### 4. Nessus via Docker

Fonte: https://simontaplin.net/2021/02/03/how-to-setup-nessus-in-docker-container/

```bash
docker run -d --name nessus \
  -p 8834:8834 \
  --network vuln_net \
  --ip 192.168.100.40 \
  tenableofficial/nessus
```

Acessar: `https://localhost:8834`  
Registrar com Nessus Essentials

---

## 

Demonstração e Análise

### OpenVAS

- Interface e configuração de alvo (DVWA, Metasploitable)
- Criação de scan
- Relatório com CVEs

### Nessus

- Configuração inicial
- Scan avançado
- Comparação com OpenVAS

---

## Comparação Técnica

| Critério                | OpenVAS                       | Nessus                        |
|-------------------------|-------------------------------|-------------------------------|
| Licença                 | Gratuito (GPL)                | Freemium (Essentials)        |
| Atualizações            | Comunidade                    | Plugins Tenable               |
| Qualidade de relatório  | Boa                           | Excelente e interativo        |
| Facilidade de uso       | Média                         | Alta                          |
| Integração com SIEM     | Moderada                      | Alta                          |

---

## Conclusão

- Como aplicar em nossos ambientes ? 
- Que ações podemos fazer ? 
- Que rotimas podemos implantar ?
- Automatizar esses testes é uma boa ?
- 

---

## 📂 Materiais de Apoio

- [OpenVAS Docker GitHub](https://github.com/mikesplain/openvas)
- [Nessus Docker Guide](https://simontaplin.net/2021/02/03/how-to-setup-nessus-in-docker-container/)
- [DVWA Docker Setup](https://medium.com/@Muriithi_nancy/how-to-setup-dvwa-on-docker-a3819ec25f78)
