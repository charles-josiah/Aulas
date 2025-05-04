
# 📝 Nota de Aula — Captura de Senhas no PostgreSQL, HTTPD e phpMyAdmin

Este documento reúne os tópicos e práticas discutidos em aula, com foco na construção de um ambiente web containerizado usando **Docker**. Além disso, cobre os fundamentos técnicos por trás de containers, autenticação com PHP e integração de banco de dados MySQL/MariaDB, bem como uma alternativa de login local com credenciais fixas.

---

## 🐳 Docker: Evolução dos Jails do FreeBSD

O **Docker** é uma plataforma de empacotamento, distribuição e execução de aplicações em ambientes isolados chamados *containers*. Foi lançado em 2013 e impulsionou a padronização da entrega de software.

### 📜 Antecessor: FreeBSD Jails

- Introduzido no **FreeBSD 4.x** (2000), os *jails* permitem criar múltiplos ambientes isolados no mesmo sistema.
- Cada jail possui:
  - sua própria árvore de diretórios
  - instância de rede
  - contas de usuários e permissões separadas

Apesar de potente, era limitado ao ecossistema BSD.

### 🔧 Arquitetura Docker

Docker usa tecnologias do kernel Linux:

- `Namespaces`: isolamento de processos, PID, rede, UTS, IPC e montagem
- `Cgroups`: controle de uso de CPU, memória, rede e disco
- `UnionFS` (AUFS, OverlayFS): montagem por camadas
- `Containers`: inicialmente com LXC (Linux Containers), depois substituído pelo runtime containerd e runc

### 🚀 Benefícios

- Deploy rápido e consistente em qualquer host com Docker
- Imagens reusáveis e versionadas (Docker Hub)
- Suporte a CI/CD (GitLab CI, Jenkins)
- Compatível com Kubernetes (orquestração)

---

## ⚙️ Ambiente Dockerizado: PHP + Apache + MariaDB + phpMyAdmin

Este ambiente simula um stack LAMP simplificado com Docker Compose.

### Componentes:

| Serviço       | Imagem Docker           | Porta local | Função                              |
|---------------|-------------------------|-------------|--------------------------------------|
| php-httpd     | `php:7.3-apache`        | 80          | Apache + PHP                         |
| mariadb       | `mariadb:10.5.2`        | 3306        | Banco de dados relacional            |
| phpmyadmin    | `phpmyadmin/phpmyadmin` | 8081        | Interface web para gerenciamento DB  |

---

### 🛠 Pré-requisitos

```bash
apt install docker docker-compose
systemctl enable --now docker
```

---

### 📁 Estrutura de Diretórios

```bash
mkdir -p linuxconfig/DocumentRoot
echo "<?php phpinfo(); ?>" > linuxconfig/DocumentRoot/index.php
```

---

### 📄 Dockerfile (customizado)

```dockerfile
FROM php:7.3-apache

RUN docker-php-ext-install pdo pdo_mysql mysqli
```

---

### 📄 docker-compose.yml

```yaml
version: '3.7'

services:
  php-httpd:
    build: .
    ports:
      - "80:80"
    volumes:
      - "./DocumentRoot:/var/www/html"

  mariadb:
    image: mariadb:10.5.2
    ports:
      - "3306:3306"
    volumes:
      - mariadb-volume:/var/lib/mysql
    environment:
      TZ: "Europe/Rome"
      MYSQL_ALLOW_EMPTY_PASSWORD: "no"
      MYSQL_ROOT_PASSWORD: "rootpwd"
      MYSQL_USER: 'testuser'
      MYSQL_PASSWORD: 'testpassword'
      MYSQL_DATABASE: 'testdb'

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    ports:
      - "8081:80"
    environment:
      PMA_HOST: mariadb

volumes:
  mariadb-volume:
```

---

### 🚀 Comandos Essenciais

```bash
docker-compose up -d
docker-compose logs -f
docker-compose down
```

---

### 🌐 Endpoints

- Aplicação Web: http://localhost
- phpMyAdmin: http://localhost:8081

---

## 🔐 Autenticação PHP com MySQL/MariaDB

Sistema de login básico que valida as credenciais em uma tabela do banco.

### 🧾 db.php

```php
<?php
$host = 'mariadb';
$db   = 'testdb';
$user = 'testuser';
$pass = 'testpassword';

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die("Erro de conexão: " . $conn->connect_error);
}
?>
```

### 🧾 login.php

```php
<?php
session_start();
include 'db.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $usuario = $_POST['usuario'];
    $senha = $_POST['senha'];

    $stmt = $conn->prepare("SELECT * FROM usuarios WHERE usuario = ? AND senha = ?");
    $stmt->bind_param("ss", $usuario, $senha);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 1) {
        $_SESSION['usuario'] = $usuario;
        header("Location: home.php");
    } else {
        echo "Login inválido!";
    }
}
?>
```

---

### 🏠 home.php

```php
<?php
session_start();
if (!isset($_SESSION['usuario'])) {
    header("Location: login.php");
    exit();
}
?>

<h1>Bem-vindo, <?php echo $_SESSION['usuario']; ?>!</h1>
<a href="login.php">Sair</a>
```

---

### 🗄 SQL: Criação da Tabela

```sql
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    senha VARCHAR(50) NOT NULL
);

INSERT INTO usuarios (usuario, senha) VALUES ('admin', 'admin123');
```

---

## 🔐 Autenticação Local (Sem Banco)

Alternativa para fins didáticos e de teste com verificação embutida no código.

### index.php

```php
<?php
session_start();

define('USERNAME', 'admin');
define('PASSWORD', '12345');

if (isset($_POST['submit'])) {
    if ($_POST['username'] === USERNAME && $_POST['password'] === PASSWORD) {
        $_SESSION['authenticated'] = true;
        header("Location: dashboard.php");
        exit();
    } else {
        $error = "Credenciais inválidas!";
    }
}
?>
```

### dashboard.php

```php
<?php
session_start();
if (!isset($_SESSION['authenticated'])) {
    header("Location: index.php");
    exit();
}
?>
<h1>Autenticado com sucesso!</h1>
```

### logout.php

```php
<?php
session_start();
session_destroy();
header("Location: index.php");
exit();
```

---

### ✅ Testando

- Acesse `http://localhost`
- Usuário: `admin`
- Senha: `admin123`

---

## 🧪 Possíveis Erros e Soluções

| Erro                                | Causa                                  | Solução                              |
|-------------------------------------|----------------------------------------|--------------------------------------|
| `Class 'mysqli' not found`          | Extensão PHP não instalada             | Usar Dockerfile com `mysqli`         |
| Tela em branco no navegador         | PHP com erro e sem exibição configurada| Verificar logs + `error_reporting()` |
| `No route to host` em `ssh`         | Máquina destino fora da rede ou off    | Verifique IP, firewall, cabeamento   |
| `Access denied` no MariaDB          | Usuário/senha errados ou sem permissão | Validar envs no `docker-compose.yml` |

---

## 📌 Conclusão

Este ambiente demonstra a capacidade do Docker em orquestrar múltiplos serviços para simular um ambiente web completo. Além disso, os exemplos de autenticação com banco e local reforçam fundamentos de segurança e integração backend.
