from flask import Flask, request, redirect, url_for, render_template_string, make_response
import os
import datetime

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'chave-demo-simples-para-laboratorio')

# Credenciais fixas para demonstração
USERS = {
    'admin': '123456',
    'usuario': 'senha123',
    'aluno': 'senai2024'
}

# Template HTML do formulário de login
LOGIN_TEMPLATE = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laboratório de Segurança - Login</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex; 
            justify-content: center; 
            align-items: center; 
            min-height: 100vh; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .login-container { 
            background: white; 
            padding: 40px; 
            border-radius: 12px; 
            box-shadow: 0 10px 40px rgba(0,0,0,0.2); 
            width: 350px;
        }
        h2 { 
            text-align: center; 
            color: #333; 
            margin-bottom: 30px;
            font-size: 24px;
        }
        .warning { 
            background: #fff3cd; 
            border: 1px solid #ffc107; 
            padding: 15px; 
            border-radius: 6px; 
            margin-bottom: 25px; 
            font-size: 13px;
            color: #856404;
            text-align: center;
        }
        .warning strong { display: block; margin-bottom: 5px; }
        .form-group { margin-bottom: 20px; }
        label { 
            display: block; 
            margin-bottom: 8px; 
            color: #555; 
            font-weight: 500;
        }
        input { 
            width: 100%; 
            padding: 12px; 
            border: 2px solid #e0e0e0; 
            border-radius: 6px; 
            font-size: 14px;
            transition: border-color 0.3s;
        }
        input:focus {
            outline: none;
            border-color: #667eea;
        }
        button { 
            width: 100%; 
            padding: 12px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white; 
            border: none; 
            border-radius: 6px; 
            cursor: pointer; 
            font-size: 16px;
            font-weight: 600;
            transition: transform 0.2s;
        }
        button:hover { 
            transform: translateY(-2px);
        }
        .error { 
            color: #e74c3c; 
            text-align: center; 
            margin-bottom: 15px;
            background: #fdf2f2;
            padding: 10px;
            border-radius: 6px;
        }
        .footer {
            text-align: center;
            margin-top: 20px;
            color: #999;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>🔐 Login do Sistema</h2>
        <div class="warning">
            <strong>⚠️ AMBIENTE SEM HTTPS</strong>
            Credenciais transmitidas em PLAINTEXT!<br>
            Acessando: {{ server_ip }}:{{ server_port }}
        </div>
        {% if error %}
        <div class="error">{{ error }}</div>
        {% endif %}
        <form method="POST" action="/">
            <div class="form-group">
                <label>👤 Usuário:</label>
                <input type="text" name="username" placeholder="Digite seu usuário" required autofocus>
            </div>
            <div class="form-group">
                <label>🔑 Senha:</label>
                <input type="password" name="password" placeholder="Digite sua senha" required>
            </div>
            <button type="submit">Entrar</button>
        </form>
        <div class="footer">
            Laboratório de Segurança - SSI
        </div>
    </div>
</body>
</html>
'''

# Template HTML da dashboard
DASHBOARD_TEMPLATE = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Dashboard - Laboratório</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f0f0f0; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; }
        .danger-box { background: #fff3cd; border: 1px solid #ffc107; padding: 15px; margin: 20px 0; }
        pre { background: #282c34; color: #abb2bf; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Login Realizado</h1>
        <p>Usuário: <strong>{{ username }}</strong></p>
        <p>Data/Hora: <strong>{{ timestamp }}</strong></p>
        
        <div class="danger-box">
            <h3>⚠️ Risco Demonstrado</h3>
            <p>Seu tráfego HTTP está sendo capturado. As credenciais foram transmitidas em texto claro.</p>
            <pre>POST / HTTP/1.1
Host: {{ host }}
Content-Type: application/x-www-form-urlencoded

username={{ username }}&password=********</pre>
        </div>
        
        <p><a href="/" style="color: #007bff;">Fazer logout</a></p>
    </div>
</body>
</html>
'''

@app.route('/', methods=['GET', 'POST'])
def index():
    server_ip = os.environ.get('SERVER_HOST', 'localhost')
    server_port = os.environ.get('SERVER_PORT', '5000')
    
    if request.method == 'POST':
        username = request.form.get('username', '')
        password = request.form.get('password', '')
        
        print(f"[LOGIN] {username} - IP: {request.remote_addr}")
        
        if username in USERS and USERS[username] == password:
            return render_template_string(
                DASHBOARD_TEMPLATE,
                username=username,
                timestamp=datetime.datetime.now().strftime('%d/%m/%Y %H:%M:%S'),
                host=f"{server_ip}:{server_port}"
            )
        
        return render_template_string(LOGIN_TEMPLATE, error='❌ Usuário ou senha incorretos!', 
                                      server_ip=server_ip, server_port=server_port)
    
    return render_template_string(LOGIN_TEMPLATE, error=None, server_ip=server_ip, server_port=server_port)


@app.route('/logout')
def logout():
    return redirect(url_for('index'))


@app.route('/status')
def status():
    return {'status': 'online', 'port': 5000}


if __name__ == '__main__':
    print("=" * 50)
    print("🧪 Servidor Laboratório - Sem HTTPS")
    print("=" * 50)
    print(f"Acesse: http://0.0.0.0:{os.environ.get('SERVER_PORT', 5000)}")
    print("Usuários: admin/123456, usuario/senha123, aluno/senai2024")
    print("=" * 50)
    app.run(host='0.0.0.0', port=5000, debug=False)
