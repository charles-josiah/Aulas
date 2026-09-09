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

## Avisos

- **NUNCA** suba `servidor.key` (ou `ca.key`) para o git — a chave privada fica apenas no servidor.
- A senha `Senha@123` e os dados do documento secreto são **fictícios**, exclusivos para laboratório.
- O `htpasswd` contém o hash `apr1` da senha; para gerar outro: `openssl passwd -apr1 'NovaSenha'`.