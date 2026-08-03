from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer
import os

# Credenciais fixas para demonstração
USERS = {
    'admin': '123456',
    'labuser': 'ftp2024',
    'aluno': 'senai2024'
}

authorizer = DummyAuthorizer()
for user, senha in USERS.items():
    authorizer.add_user(user, senha, '/srv/ftp', perm='elradfmwMT')

handler = FTPHandler
handler.authorizer = authorizer
handler.banner = "Laboratorio de Seguranca - FTP SEM TLS/FTPS"

# Portas passivas (canal de dados) — modo passivo
handler.passive_ports = range(30000, 30100)

print("=" * 50)
print("Servidor FTP Laboratorio - Sem FTPS")
print("Acesse: ftp://IP_SERVIDOR:21")
print("Usuarios: admin/123456, labuser/ftp2024, aluno/senai2024")
print("ATENCAO: senha e comandos em PLAINTEXT!")
print("=" * 50)

server = FTPServer(('0.0.0.0', 21), handler)
server.serve_forever()
