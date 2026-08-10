# Taller Linux
Trabajo realizados con ansible durante el taller
 
## Contenido
 
- Inventario
- Playbooks
- Files
 
## Descripción del proyecto
 
Este repositorio contiene el conjunto completo de herramientas usadas en el taller de Linux con Ansible. Incluye inventario, playbooks, archivos de configuración y plantillas para desplegar una aplicación PHP con MariaDB.
 
### Estructura del repositorio
.
├── collections          
│   └── requirements.yaml
├── files             
│   ├── jail.local
│   └── schema.sql
├── inventory           
│   ├── group_vars       
│   │   └── linux.yaml
│   └── hosts.ini      
├── LICENSE              
├── playbooks             
│   ├── app-php.yaml    
│   ├── db-mariadb.yaml      
│   ├── hardening.yaml    
│   ├── reload_apache.yaml
│   └── Requisitos.yaml    
├── README.md           
├── reload_apache.yaml
├── templates          
│   ├── cumple.j2       
│   └── db_config.j2     
└── vars                 
    └── database.yaml    


    
- `inventory/`
  - `hosts.ini`: definición de hosts y grupos.
  - `group_vars/`: variables específicas por grupo.
- `playbooks/`
  - `db-mariadb.yaml`: despliega y configura MariaDB, crea la base de datos y aplica el esquema.
  - `app-php.yaml`: configura la aplicación PHP y su conexión a la base de datos.
  - `hardening.yaml`: tareas de endurecimiento y seguridad del sistema.
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
 
### Qué hace este proyecto
 
- Crea y configura una base de datos MariaDB.
- Importa el esquema SQL inicial necesario para la aplicación.
- Despliega una aplicación PHP conectada a la base de datos.
- Gestiona variables de entorno y credenciales mediante `inventory/group_vars` y `vars`.
- Usa plantillas para generar archivos de configuración dinámicos.
 
### Cómo usarlo
 
1. Instalar las colecciones de Ansible definidas en `collections/requirements.yaml`.
2. Ejecutar los playbooks según el orden necesario, por ejemplo:
   - `ansible-playbook playbooks/db-mariadb.yaml`
   - `ansible-playbook playbooks/app-php.yaml`
 
Esta documentación describe el proyecto completo, sin enfocarse en cambios puntuales o problemas específicos.

Autores: Sebastián Villar (354030) - Silvio Lewkowitz (258664) 🐧
