
# Aula: Análise de Vulnerabilidades com OpenVAS,  Nessus e mais...

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

## Demonstração e Análise

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


---
## Monitoramento de Vulnerabilidades com Docker

### Por que monitorar vulnerabilidades em containers?

Mesmo usando imagens oficiais, containers podem conter pacotes desatualizados ou vulneráveis. Monitorar vulnerabilidades garante que sua infraestrutura não esteja exposta a riscos conhecidos — especialmente em ambientes de produção, onde falhas de segurança podem ser exploradas rapidamente.

O uso de ferramentas de varredura automatizada permite identificar **CVE (Common Vulnerabilities and Exposures)** em imagens e aplicações rodando em containers.

---

### Exemplo 1: Usando Trivy (scanner de imagem leve)

Trivy é um scanner de vulnerabilidades moderno e rápido, usado para inspecionar imagens antes de enviá-las para produção.

Docuemntação: https://trivy.dev/v0.57/getting-started/installation/

#### Instalar Trivy:
```bash
wget https://github.com/aquasecurity/trivy/releases/download/v0.57.1/trivy_0.57.1_Linux-64bit.deb
sudo dpkg -i trivy_0.57.1_Linux-64bit.deb

#ou

sudo apt-get install wget gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

#ou
#usando docker
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy:0.57.1 image python:3.4-alpine
```

#### Rodar varredura em uma imagem:
```bash
trivy image nginx
```
> Retorna lista de vulnerabilidades por severidade, pacote e CVE.


### Exemplo 2: Clair – Scanner de Imagens Docker

Clair é um scanner popular para **pipelines CI/CD** que inspeciona imagens e armazena relatórios de vulnerabilidade.

#### Exemplo básico com Docker Compose:

```bash
git clone https://github.com/quay/clair
cd clair
docker-compose up
```
> Integra-se facilmente com registries como Harbor ou Quay.io.


### Exemplo 3: Exemplo: Scanner com Nmap contra um container vulnerável (CVE)

 Exemplo: Scanner com Nmap contra um Container Vulnerável (DVWA)

### Objetivo

Simular um ambiente de teste onde:
- Um container roda uma aplicação **vulnerável (DVWA)**.
- Outro container executa **Nmap** para inspecionar serviços e versões expostas.


#### 1. Criar rede isolada para o laboratório

```bash
docker network create lab-net
```

#### 2. Subir o container DVWA (Damn Vulnerable Web Application)

```bash
docker run -d \
  --name dvwa \
  --network lab-net \
  -e MYSQL_ROOT_PASSWORD=dvwa \
  -e MYSQL_PASSWORD=dvwa \
  -e MYSQL_USER=dvwa \
  -e MYSQL_DATABASE=dvwa \
  -p 80:80 \
  vulnerables/web-dvwa
```

> Aguarde 20–30 segundos até o serviço inicializar.

#### 3. Executar Nmap contra o DVWA

```bash
docker run --rm -it \
  --name scanner \
  --network lab-net \
  instrumentisto/nmap \
  nmap -sV dvwa
```
> Esse comando realiza um **scan de versão (-sV)** contra o hostname `dvwa`, resolvido pela rede interna Docker.

> Resultado: Nmap detectará os serviços ativos da DVWA (geralmente Apache, MySQL) e suas versões — você pode usar isso como base para validar a presença de vulnerabilidades conhecidas (CVE).

#### 4. Opcional: Rodar Trivy para inspeção de CVEs diretamente na imagem
```bash 
trivy image vulnerables/web-dvwa
```
> Esse comando realiza um **scan** contra a imagem do dvwa

---

#### Outras ferramentas úteis

- **Anchore Engine** – escaneia imagens e aplica políticas de segurança.
- **Grype** – scanner rápido da Anchore, com suporte nativo a várias distros.
- **Dockle** – verifica práticas de segurança em configurações Dockerfiles.

#### Você pode substituir o DVWA por outras imagens vulneráveis, como:
- vulnerables/web-dvwa
- bkimminich/juice-shop (OWASP Juice Shop)
- cyberxsecurity/metasploitable

E escanear com ferramentas como:
- nmap
- nikto
- wpscan
- sqlmap (em containers ou via Kali)

---

## Dicas Finais

- Use volumes para persistência de dados.
- Evite `:latest`; use tags específicas.
- Segurança: use usuário não root nos containers.
- Use `.dockerignore` como o `.gitignore`.
- Separe ambientes de dev/prod nos `docker-compose.yml`.

---
<div align="center">

⚠️ Aviso Legal

Este conteúdo é fornecido apenas para fins educacionais.<br> Realizar força bruta ou qualquer tipo de acesso não autorizado a sistemas sem permissão constitui crime.<br> Use somente em ambientes controlados e autorizados, como laboratórios e CTFs.
</div>



