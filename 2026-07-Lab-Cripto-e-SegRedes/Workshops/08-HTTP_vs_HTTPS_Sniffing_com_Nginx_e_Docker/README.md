# Laboratório HTTP vs HTTPS — nginx em Docker

Arquivos de apoio do **Workshop 08** (`08-HTTP_vs_HTTPS_Sniffing_com_Nginx_e_Docker.md`).

## Estrutura

```
08-HTTP_vs_HTTPS_Sniffing_com_Nginx_e_Docker/
├── docker-compose.yml          # container nginx:alpine (portas 80 e 443)
└── nginx/
    ├── conf.d/
    │   └── default.conf        # server blocks: porta 80 (HTTP) e 443 (HTTPS)
    ├── htpasswd                # usuário: aluno | senha: Senha@123 (fictícia, só lab)
    └── html/
        ├── index.html          # página inicial com links para as duas portas
        └── secreto/
            └── documento-secreto.txt  # dados FICTÍCIOS para o sniffing
```

## Como usar

1. Complete o **Workshop 07** para ter a PKI (`servidor.crt`, `servidor.key`, `ca.crt`).
2. Copie os certificados para a pasta `pki/` (crie a pasta):
   ```bash
   mkdir -p pki
   cp /tmp/lab-w7-user1/servidor/servidor.crt pki/
   cp /tmp/lab-w7-user1/servidor/servidor.key pki/
   cp /tmp/lab-w7-user1/ca/ca.crt            pki/
   ```
3. Ajuste o IP no `nginx/conf.d/default.conf` (troque `172.30.234.55` pelo IP do seu servidor).
4. Suba o container:
   ```bash
   docker compose up -d
   ```
5. Sniffe de outra estação e compare os pacotes (ver Etapas 8–10 do workshop).

## Baixando estes arquivos (sem clonar o repositório inteiro)

**Opção A — clone completo:**

```bash
git clone --depth 1 https://github.com/charles-josiah/Aulas.git
cd Aulas/2026-07-Lab-Cripto-e-SegRedes/Workshops/08-HTTP_vs_HTTPS_Sniffing_com_Nginx_e_Docker
```

**Opção B — sparse checkout (só esta pasta):**

```bash
git clone --depth 1 --filter=blob:none --sparse https://github.com/charles-josiah/Aulas.git
cd Aulas
git sparse-checkout set 2026-07-Lab-Cripto-e-SegRedes/Workshops/08-HTTP_vs_HTTPS_Sniffing_com_Nginx_e_Docker
```

**Opção C — arquivo por arquivo com `curl` (sem git):**

```bash
mkdir -p lab-nginx-tls/nginx/conf.d lab-nginx-tls/nginx/html/secreto
BASE=https://raw.githubusercontent.com/charles-josiah/Aulas/master/2026-07-Lab-Cripto-e-SegRedes/Workshops/08-HTTP_vs_HTTPS_Sniffing_com_Nginx_e_Docker
curl -o lab-nginx-tls/docker-compose.yml                    "$BASE/docker-compose.yml"
curl -o lab-nginx-tls/nginx/conf.d/default.conf             "$BASE/nginx/conf.d/default.conf"
curl -o lab-nginx-tls/nginx/html/index.html                 "$BASE/nginx/html/index.html"
curl -o lab-nginx-tls/nginx/html/secreto/documento-secreto.txt "$BASE/nginx/html/secreto/documento-secreto.txt"
curl -o lab-nginx-tls/nginx/htpasswd                        "$BASE/nginx/htpasswd"
```

> **Os certificados NÃO estão neste repositório** — a pasta `pki/` é criada por você na Etapa 5 do workshop, copiando os certificados do seu Workshop 07.

## Avisos

- **NUNCA** suba `servidor.key` (ou `ca.key`) para o git — a chave privada fica apenas no servidor.
- A senha `Senha@123` e os dados do documento secreto são **fictícios**, exclusivos para laboratório.
- O `htpasswd` contém o hash `apr1` da senha; para gerar outro: `openssl passwd -apr1 'NovaSenha'`.