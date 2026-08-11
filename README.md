# Taller Linux

Trabajo realizado con Ansible durante el taller de Linux.

## Descripción del proyecto

Este repositorio contiene el conjunto de herramientas usadas en el taller de Linux con Ansible. Incluye inventario, playbooks, archivos de configuración y plantillas para desplegar una aplicación PHP con MariaDB.

El flujo de despliegue utiliza dos servidores:

- `ubuntu01`: servidor de base de datos MariaDB.
- `centos01`: servidor web Apache y aplicación PHP.

### Estructura del repositorio

```
tree
├── collections/
│   └── requirements.yaml
├── files/
│   ├── jail.local
│   └── schema.sql
├── inventory/
│   ├── group_vars/
│   │   └── linux.yaml
│   └── hosts.ini
├── LICENSE
├── playbooks/
│   ├── app-php.yaml
│   ├── db-mariadb.yaml
│   ├── hardening.yaml
│   ├── reload_apache.yaml
│   └── Requisitos.yaml
├── README.md
├── reload_apache.yaml
├── templates/
│   ├── cumple.j2
│   └── db_config.j2
└── vars/
    └── database.yaml
```
    
- `inventory/`
  - `hosts.ini`: definición de hosts y grupos.
  - `group_vars/`: variables específicas por grupo.
- `playbooks/`
  - `db-mariadb.yaml`: despliega y configura MariaDB, crea la base de datos y aplica el esquema.
  - `app-php.yaml`: configura la aplicación PHP y su conexión a la base de datos.
  - `reload_apache.yaml`: recarga la configuración de Apache.
  - `Requisitos.yaml`: describe requisitos previos y dependencias.
- `files/`
  - `schema.sql`: esquema inicial de la base de datos.
  - `jail.local`: configuración de jail para servicios si aplica.
- `templates/`
  - `cumple.j2`: plantilla Jinja2 para generar archivos de configuración dinámicos.
- `vars/`
  - `database.yaml`: variables reutilizables de base de datos.
- `collections/`
  - `requirements.yaml`: colecciones de Ansible necesarias para el proyecto.
 
## Roles del proyecto

Las responsabilidades están organizadas en playbooks:

| Playbooks |
|---|---|---|
| Requisitos y acceso | `playbooks/Requisitos.yaml` | Instala `sshpass`, registra fingerprints SSH, instala la clave pública y configura sudo sin contraseña para `sysadmin`. También comprueba la conexión y la escalada a root. |
| Base de datos | `playbooks/db-mariadb.yaml` | Instala MariaDB, configura la dirección de escucha, abre el puerto 3306, crea la base de datos, importa `schema.sql`, carga datos iniciales y crea el usuario de la aplicación. |
| Aplicación web | `playbooks/app-php.yaml` | Instala Apache, PHP y PHP-FPM, publica `index.php`, habilita el acceso de Apache a la base de datos mediante SELinux y permite HTTP en el firewall. |
| Recarga web | `playbooks/reload_apache.yaml` | Recarga el servicio Apache después de un cambio de configuración. |

### Qué hace este proyecto
 
- Crea y configura una base de datos MariaDB.
- Importa el esquema SQL inicial necesario para la aplicación.
- Despliega una aplicación PHP conectada a la base de datos.
- Gestiona variables de entorno y credenciales mediante `inventory/group_vars` y `vars`.
- Usa plantillas para generar archivos de configuración dinámicos.

## Requisitos previos

- Un bastión con Ansible instalado.
- Acceso SSH a los hosts definidos en `inventory/hosts.ini`.
- Usuario `sysadmin` disponible en los servidores.
- Una clave pública en `~/.ssh/id_ed25519.pub` del nodo de control.
- Variables sensibles disponibles mediante las variables de entorno usadas por `inventory/group_vars/linux.yaml` (`DB_DBASE`, `DB_USER`, `DB_SERVER` y `DB_PASS`) o mediante el mecanismo de secretos elegido para el entorno.

Instalar las colecciones declaradas por el proyecto:

```bash
ansible-galaxy collection install -r collections/requirements.yaml
```

Este comando instala `community.general`, `ansible.posix` y `community.mysql`, que proporcionan módulos utilizados por los playbooks.
 
## Inventario y conexión

Consultar el inventario antes de ejecutar cambios:

```bash
ansible-inventory -i inventory/hosts.ini --graph
ansible-inventory -i inventory/hosts.ini --list
```

`--graph` muestra los grupos y hosts de forma legible. `--list` muestra el inventario completo en JSON, incluyendo las variables resueltas por Ansible.

Comprobar la conectividad SSH y la configuración del usuario:

```bash
ansible all -i inventory/hosts.ini -m ansible.builtin.ping
```

`ansible` ejecuta una acción puntual sobre el inventario y `-m ping` verifica que Ansible pueda conectarse y ejecutar Python en cada servidor. El resultado esperado es `SUCCESS` para cada host.

## Orden de ejecución

Ejecutar los playbooks desde la raíz del repositorio y conservar este orden:

### 1. Preparar requisitos y acceso

```bash
ansible-playbook -i inventory/hosts.ini playbooks/Requisitos.yaml --ask-become-pass
```

Este comando ejecuta el playbook local que prepara SSH y sudo y luego valida el acceso a los hosts del grupo `linux`. `-i` indica el inventario y `--ask-become-pass` solicita la contraseña necesaria para las tareas iniciales con privilegios.

Si el acceso inicial necesita contraseña SSH, añadir `--ask-pass` en la primera ejecución:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/Requisitos.yaml --ask-pass --ask-become-pass
```

### 2. Desplegar MariaDB

```bash
ansible-playbook -i inventory/hosts.ini playbooks/db-mariadb.yaml --ask-vault-pass
```

Este comando configura la base de datos en `ubuntu01`. `--ask-vault-pass` permite descifrar variables protegidas con Ansible Vault cuando el inventario las necesita. Si las variables ya se inyectan por otro mecanismo, puede omitirse esta opción.

### 3. Desplegar la aplicación PHP

```bash
ansible-playbook -i inventory/hosts.ini playbooks/app-php.yaml --ask-vault-pass
```

Este comando configura Apache/PHP en `centos01`, instala la plantilla de la aplicación y habilita la comunicación con MariaDB.

### 4. Recargar Apache

```bash
ansible-playbook -i inventory/hosts.ini playbooks/reload_apache.yaml
```

Recarga Apache sin reiniciar todo el servidor. Se usa después de cambios de configuración que no requieren detener el servicio.

## Validación

Antes de aplicar cambios, validar la sintaxis y revisar las tareas:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/Requisitos.yaml --syntax-check
ansible-playbook -i inventory/hosts.ini playbooks/db-mariadb.yaml --syntax-check
ansible-playbook -i inventory/hosts.ini playbooks/app-php.yaml --syntax-check
ansible-playbook -i inventory/hosts.ini playbooks/db-mariadb.yaml --list-tasks
```

`--syntax-check` detecta errores de YAML y de estructura del playbook sin cambiar los servidores. `--list-tasks` muestra las tareas que se ejecutarían y ayuda a revisar el alcance del despliegue.

Para hacer una simulación de los cambios:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/db-mariadb.yaml --check --diff --ask-vault-pass
ansible-playbook -i inventory/hosts.ini playbooks/app-php.yaml --check --diff --ask-vault-pass
```

`--check` ejecuta en modo simulación y `--diff` muestra diferencias de archivos cuando el módulo puede calcularlas. Algunos módulos, como importaciones SQL, servicios o cambios de firewall, pueden no representar completamente su efecto en modo check; por eso la verificación posterior sigue siendo necesaria.

El playbook `Requisitos.yaml` incorpora validaciones automáticas:

- `ansible.builtin.ping` confirma la conectividad con cada servidor.
- `id -un` con `become: true` comprueba la escalada de privilegios.
- `ansible.builtin.assert` exige que el usuario efectivo sea `root`.
- `visudo -cf` valida el archivo creado en `/etc/sudoers.d/90-ansible` antes de instalarlo.

Después del despliegue, comprobar servicios, firewall y la aplicación:

```bash
ansible ubuntu -i inventory/hosts.ini -b -m ansible.builtin.service_facts
ansible centos -i inventory/hosts.ini -b -m ansible.builtin.service_facts
ansible ubuntu -i inventory/hosts.ini -b -m ansible.builtin.command -a "ss -ltnp | grep 3306"
ansible centos -i inventory/hosts.ini -b -m ansible.builtin.command -a "ss -ltnp | grep ':80'"
```

`service_facts` devuelve el estado de los servicios detectados. `ss -ltnp` muestra puertos TCP en escucha; las búsquedas deben encontrar MariaDB en el puerto `3306` y Apache en el puerto `80`.

Desde el bastión, validar la respuesta HTTP:

```bash
curl -I http://10.0.2.15
```

`curl -I` solicita únicamente las cabeceras HTTP. Una respuesta `HTTP/1.1 200 OK` o `HTTP/2 200` indica que Apache responde; también se debe verificar que la página muestre correctamente los datos obtenidos de MariaDB.

## Comandos útiles de Ansible

```bash
ansible-playbook --help
ansible-doc community.mysql.mysql_db
ansible-doc community.general.ufw
```

`--help` muestra las opciones disponibles de `ansible-playbook`. `ansible-doc` consulta la documentación local de un módulo.

Para inspeccionar cambios antes de aplicarlos, usar también:

```bash
git status
git diff -- README.md
```

`git status` muestra archivos modificados o sin seguimiento y `git diff -- README.md` muestra únicamente los cambios realizados en esta documentación.

Autores: Sebastián Villar (354030) - Silvio Lewkowitz (258664)
