# Orquestador Global de Infraestructura AWS - AUY1105

## Objetivos del Repositorio Raíz
Centralizar el aprovisionamiento de la arquitectura mediante el consumo de módulos de Terraform remotos y versionados, garantizando la inyección de dependencias cruzada.

## Arquitectura Desplegada
Este proyecto unifica la topología de red, cómputo y almacenamiento consumiendo componentes desacoplados desde repositorios independientes de GitHub. Implementa un Application Load Balancer (ALB) que distribuye el tráfico web entrante hacia instancias EC2 con Apache, manteniendo bloqueos de seguridad perimetrales y almacenamiento S3 seguro con control de versiones activo.

## Módulos Consumidos Remotamente
* **Redes (VPC):** `github.com/Mantita188/terraform-aws-vpc-auy1105-cr.git`
* **Cómputo (EC2):** `github.com/Mantita188/terraform-aws-ec2-auy1105-cr.git`
* **Almacenamiento (S3):** `github.com/Mantita188/terraform-aws-storage-auy1105-cr.git`

## Parámetros Globales (Variables)
| Nombre | Descripción | Tipo | Defecto |
| :--- | :--- | :---: | :---: |
| `environment` | Prefijo de etiquetado para el ambiente actual | `string` | `"dev"` |

## Valores de Salida Finales (Outputs)
| Nombre | Descripción |
| :--- | :--- |
| `final_app_url` | Ruta DNS pública para acceder a la aplicación web a través del ALB |
| `allocated_bucket_name` | Nombre global único asignado al bucket S3 |