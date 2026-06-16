# Orquestador Global de Infraestructura AWS - AUY1105

## Objetivos del Repositorio Raíz
Centralizar el aprovisionamiento de la arquitectura mediante el consumo de 5 módulos de Terraform remotos, independientes y versionados, garantizando la inyección de dependencias cruzada.

## Módulos Consumidos Remotamente
* **Redes (VPC):** `github.com/Mantita188/terraform-aws-vpc-auy1105-cr.git`
* **Cómputo (EC2):** `github.com/Mantita188/terraform-aws-ec2-auy1105-cr.git`
* **Almacenamiento (S3):** `github.com/Mantita188/terraform-aws-storage-auy1105-cr.git`
* **Balanceador (ALB):** `github.com/Mantita188/terraform-aws-alb-auy1105-cr.git`

## Inputs (Variables Inyectadas Dinámicamente)
| Nombre | Descripción | Tipo | Defecto | Obligatorio |
| :--- | :--- | :---: | :---: | :---: |
| `environment` | Ambiente global para la infraestructura (inyectado vía `terraform.tfvars`) | `string` | `"dev"` | Sí |

## Outputs (Valores de Salida del Código)
| Nombre | Descripción | Fuente |
| :--- | :--- | :--- |
| `final_app_url` | Ruta DNS pública para acceder al balanceador ALB | `module.alb.alb_dns_name` |
| `allocated_bucket_name` | Nombre global único asignado al bucket S3 | `module.storage.bucket_name` |