#!/usr/bin/env bash
# Verifica que www.riisupa.org esté bien publicado: DNS, certificado,
# redirecciones, páginas, archivos que no deben verse, encabezados y, si se
# corre en el servidor como root, nginx y la renovación de Certbot.
#
# Uso (en el servidor o en cualquier computadora con curl, dig y openssl):
#     bash despliegue/verificar-sitio.sh
#
# Cada línea dice OK o FALLA; al final, el total. Sale con código 1 si algo falla.

set -u
DOMINIO="${DOMINIO:-riisupa.org}"
WWW="www.$DOMINIO"
CURL_EXTRA="${CURL_EXTRA:-}"     # solo para pruebas (p. ej. --resolve ... -k)
read -r -a EXTRA <<< "$CURL_EXTRA"   # en array: sin expansión de comodines
fallas=0

ok()    { printf '  \033[32mOK\033[0m     %s\n' "$1"; }
falla() { printf '  \033[31mFALLA\033[0m  %s\n' "$1"; fallas=$((fallas + 1)); }
aviso() { printf '  \033[33mAVISO\033[0m  %s\n' "$1"; }
titulo(){ printf '\n\033[1m%s\033[0m\n' "$1"; }
check() { if [ "$2" = "$3" ]; then ok "$1"; else falla "$1 (esperado: $3, obtenido: ${2:-vacío})"; fi; }

# curl con los parámetros de prueba; nunca sigue redirecciones salvo que se pida.
c() { curl -sS --max-time 20 ${EXTRA[@]+"${EXTRA[@]}"} "$@"; }
codigo()   { c -o /dev/null -w '%{http_code}' "$1" 2>/dev/null; }
destino()  { c -o /dev/null -w '%{redirect_url}' "$1" 2>/dev/null; }
final()    { c -L -o /dev/null -w '%{http_code} %{url_effective}' "$1" 2>/dev/null; }
encabezado() { c -o /dev/null -D - "$1" 2>/dev/null | tr -d '\r' | grep -i "^$2:" | head -1 | cut -d' ' -f2-; }

# ---------------------------------------------------------------------------
titulo "1. DNS"
if command -v dig >/dev/null; then
  for host in "$DOMINIO" "$WWW"; do
    for r in 8.8.8.8 1.1.1.1; do
      ip=$(dig +short A "$host" @"$r" | grep -E '^[0-9.]+$' | tail -1)
      if [ -n "$ip" ]; then ok "$host → $ip (resolvedor $r)"; else falla "$host no resuelve en $r (¿DNSSEC o propagación?)"; fi
    done
  done
  ns_org=$(dig +short NS org | head -1)
  ds=$(dig +short DS "$DOMINIO" @"$ns_org" 2>/dev/null)
  if [ -z "$ds" ]; then ok "Sin registro DS en .org (DNSSEC desactivado, coherente con Route 53 sin firma)"
  else aviso "Hay DS en .org: $ds — solo está bien si la zona de Route 53 firma con esa clave"; fi
else
  aviso "dig no está instalado (apt install dnsutils): se saltea la parte de DNS"
fi

# ---------------------------------------------------------------------------
titulo "2. Certificado HTTPS"
if command -v openssl >/dev/null && [ -z "$CURL_EXTRA" ]; then
  for host in "$WWW" "$DOMINIO"; do
    cert=$(echo | openssl s_client -connect "$host:443" -servername "$host" 2>/dev/null | openssl x509 -noout -issuer -enddate -ext subjectAltName 2>/dev/null)
    if [ -z "$cert" ]; then falla "$host:443 no presenta certificado"; continue; fi
    echo "$cert" | grep -q "Let's Encrypt" && ok "$host: emitido por Let's Encrypt" || falla "$host: el emisor no es Let's Encrypt"
    for n in "$WWW" "$DOMINIO"; do
      echo "$cert" | grep -q "DNS:$n\b" && ok "$host: el certificado cubre $n" || falla "$host: el certificado no cubre $n"
    done
    vence=$(echo "$cert" | sed -n 's/^notAfter=//p')
    dias=$(( ( $(date -d "$vence" +%s) - $(date +%s) ) / 86400 ))
    if [ "$dias" -ge 14 ]; then ok "$host: vence en $dias días ($vence)"; else falla "$host: vence en $dias días — revisar la renovación"; fi
  done
else
  aviso "Se saltea (sin openssl o en modo prueba)"
fi

# ---------------------------------------------------------------------------
titulo "3. Redirecciones"
check "http://$DOMINIO/ termina en https://$WWW/"  "$(final "http://$DOMINIO/")"  "200 https://$WWW/"
check "http://$WWW/ → https://$WWW/"              "$(destino "http://$WWW/")"     "https://$WWW/"
check "https://$DOMINIO/la_red → https://$WWW/la_red" "$(destino "https://$DOMINIO/la_red")" "https://$WWW/la_red"

# ---------------------------------------------------------------------------
titulo "4. Páginas y recursos (200)"
for p in / /la_red /la_red.html /universidades /eventos /assets/js/data.js /assets/js/riisupa.js \
         /assets/css/riisupa.css /assets/img/riisupa-isotipo.png \
         /assets/img/actividades/webinar-etica-animales-2026.jpg /favicon.svg /sitemap.xml /robots.txt; do
  check "https://$WWW$p" "$(codigo "https://$WWW$p")" 200
done

# ---------------------------------------------------------------------------
titulo "5. Lo que NO debe verse (404)"
for p in /reglamento.html /reglamento /proyectos.html /README.md /LICENSE \
         /riisupa_github_org_structure.svg /despliegue/nginx/www-riisupa \
         /despliegue/verificar-sitio.sh /.git/HEAD /.env /prueba.php; do
  check "https://$WWW$p" "$(codigo "https://$WWW$p")" 404
done

# ---------------------------------------------------------------------------
titulo "6. Encabezados"
check "nosniff"                         "$(encabezado "https://$WWW/" x-content-type-options)" "nosniff"
check "X-Frame-Options"                 "$(encabezado "https://$WWW/" x-frame-options)"        "SAMEORIGIN"
check "Referrer-Policy"                 "$(encabezado "https://$WWW/" referrer-policy)"        "strict-origin-when-cross-origin"
check "data.js se revalida (no-cache)"  "$(encabezado "https://$WWW/assets/js/data.js" cache-control)" "no-cache"
check "imágenes con caché de 30 días"   "$(encabezado "https://$WWW/assets/img/riisupa-isotipo.png" cache-control)" "max-age=2592000"
gz=$(c -o /dev/null -D - -H 'Accept-Encoding: gzip' "https://$WWW/assets/js/data.js" 2>/dev/null | tr -d '\r' | grep -i '^content-encoding:' | cut -d' ' -f2)
check "data.js comprimido (gzip)"       "$gz" "gzip"

# ---------------------------------------------------------------------------
titulo "7. Contenido publicado"
datos=$(c "https://$WWW/assets/js/data.js" 2>/dev/null)
n_unis=$(printf '%s' "$datos" | sed -n '/^window.RIISUPA.universidades/,/^];/p' | grep -c "^    id:")
n_int=$(printf '%s' "$datos" | sed -n '/^window.RIISUPA.integrantes/,/^];/p' | grep -c "nombre:")
check "universidades en data.js" "$n_unis" 20
check "integrantes en data.js"   "$n_int" 28
printf '%s' "$datos" | grep -q "Ariana Goldman" && ok "Comité Ejecutivo cargado" || falla "No aparece el Comité Ejecutivo en data.js"
c "https://$WWW/robots.txt" 2>/dev/null | grep -q "https://$WWW/sitemap.xml" && ok "robots.txt apunta a https://$WWW/sitemap.xml" || falla "robots.txt no apunta al sitemap de $WWW"
portada=$(c "https://$WWW/" 2>/dev/null)
if ! printf '%s' "$portada" | grep -q "en red."; then falla "No se pudo leer la portada"
elif printf '%s' "$portada" | grep -q "Iniciativa CRUP"; then falla "La portada todavía dice 'Iniciativa CRUP' (contenido viejo)"
else ok "Portada con el contenido nuevo"; fi

# ---------------------------------------------------------------------------
titulo "8. Servidor (solo si se corre en el servidor como root)"
if [ "$(id -u)" = 0 ] && command -v nginx >/dev/null && [ -f /etc/nginx/sites-available/www-riisupa ]; then
  nginx -t >/dev/null 2>&1 && ok "nginx -t sin errores" || falla "nginx -t reporta errores"
  [ -L /etc/nginx/sites-enabled/www-riisupa ] && ok "sites-enabled/www-riisupa es un symlink" || falla "Falta el symlink en sites-enabled/"
  if command -v certbot >/dev/null; then
    certbot renew --dry-run --cert-name "$WWW" >/dev/null 2>&1 && ok "Renovación de prueba de Certbot exitosa" || falla "certbot renew --dry-run falla (ver /var/log/letsencrypt/letsencrypt.log)"
    if systemctl list-timers 2>/dev/null | grep -q certbot || [ -f /etc/cron.d/certbot ]; then ok "Renovación automática programada"; else falla "No hay timer ni cron de Certbot"; fi
  fi
else
  aviso "Se saltea: correlo en el servidor del sitio con sudo para revisar nginx y Certbot"
fi

printf '\n'
if [ "$fallas" -eq 0 ]; then printf '\033[32mTodo en orden.\033[0m\n'; exit 0
else printf '\033[31m%d verificación(es) fallaron.\033[0m\n' "$fallas"; exit 1; fi
