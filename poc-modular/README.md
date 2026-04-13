# OpenTofu ile ULAKFKM Altyapısında Çok Katmanlı IaC

Bu proje, **OpenTofu** kullanarak ULAKFKM bünyesindeki OpenStack ve Proxmox ortamlarını tek bir IaC konfigürasyonu ile yönetmek için hazırlanmış bir POC (Proof of Concept) çalışmasıdır.

**Yazar:** Alperen Öztaş — ULAKFKM  
**OpenTofu Sürümü:** >= 1.8.0 (test: v1.11.5)

---

## İçindekiler

1. [Ön Gereksinimler](#ön-gereksinimler)
2. [Proje Yapısı](#proje-yapısı)
3. [Kurulum](#kurulum)
4. [Yapılandırma](#yapılandırma)
5. [Kullanım](#kullanım)
6. [Oluşturulan Kaynaklar](#oluşturulan-kaynaklar)
7. [Outputs](#outputs)
8. [Temizlik](#temizlik)
9. [State Yönetimi](#state-yönetimi)
10. [Sık Karşılaşılan Sorunlar](#sık-karşılaşılan-sorunlar)

---

## Ön Gereksinimler

### OpenTofu Kurulumu

```bash
# Linux (snap)
snap install opentofu --classic

# macOS (Homebrew)
brew install opentofu

# Manuel (Linux amd64)
curl -Lo tofu.tar.gz https://github.com/opentofu/opentofu/releases/download/v1.11.5/tofu_1.11.5_linux_amd64.tar.gz
tar -xzf tofu.tar.gz
sudo mv tofu /usr/local/bin/
tofu version
```

### Gerekli Erişimler

| Ortam     | Gereksinim                                      |
|-----------|-------------------------------------------------|
| OpenStack | Keystone kimlik bilgileri, proje üyeliği        |
| Proxmox   | API token (`user@realm!tokenid=secret` formatı) |

### OpenStack API Token Oluşturma

OpenStack erişimi için `openrc.sh` dosyasındaki değişkenler kullanılır. OpenStack Horizon'dan indirilebilir: **Project → API Access → Download OpenStack RC File**

### Proxmox API Token Oluşturma

```
Proxmox Web UI → Datacenter → Permissions → API Tokens → Add
User: root@pam
Token ID: opentofu
Privilege Separation: hayır (POC için)
```

Oluşan token formatı: `root@pam!opentofu=<uuid>`

---

## Proje Yapısı

```
poc-modular/
├── main.tf                          # Modülleri çağıran ana dosya
├── versions.tf                      # Provider sürüm kilitleri
├── providers.tf                     # Provider yapılandırmaları
├── variables.tf                     # Tüm giriş değişkenleri
├── terraform.tfvars                 # Gerçek değerler (git'e eklenmez!)
├── .gitignore
└── modules/
    ├── openstack-infra/             # Katman 1: OpenStack
    │   ├── main.tf                  # Tüm OpenStack kaynakları
    │   ├── variables.tf             # Modül giriş değişkenleri
    │   ├── outputs.tf               # Modül çıktıları
    │   └── versions.tf              # Modül provider gereksinimleri
    └── proxmox-vm/                  # Katman 2: Proxmox
        ├── main.tf                  # Proxmox VM tanımı
        ├── variables.tf             # Modül giriş değişkenleri
        ├── outputs.tf               # Modül çıktıları
        └── versions.tf              # Modül provider gereksinimleri
```

### Katmanlar

```
┌─────────────────────────────────────┐
│  main.tf  (orkestrasyon)            │
│    ├── module "openstack_infra"     │  ← Katman 1
│    └── module "proxmox_vms"         │  ← Katman 2
└─────────────────────────────────────┘
```

---

## Kurulum

```bash
cd poc-modular/

# Provider'ları ve modülleri indir
tofu init
```

`tofu init` çıktısında şunları görmelisiniz:
- `terraform-provider-openstack/openstack v2.1.x`
- `bpg/proxmox v0.99.x`

---

## Yapılandırma

`terraform.tfvars` dosyası oluşturun (`.gitignore`'a eklenmiş olmalı):

```hcl
# ─── OpenStack ────────────────────────────────────────────────────────────────
os_auth_url          = "https://<keystone-endpoint>:5000/v3"
os_username          = "kullanici_adi"
os_password          = "sifre"
os_project_name      = "proje_adi"
os_project_id        = "proje_uuid"
os_user_domain_name  = "user_domain"
os_project_domain_id = "domain_uuid"
os_region            = "RegionOne"

# ─── Proxmox ──────────────────────────────────────────────────────────────────
proxmox_endpoint  = "https://<proxmox-ip>:8006"
proxmox_api_token = "root@pam!opentofu=<token-uuid>"
proxmox_node      = "proxmox-01"

# ─── VM Parametreleri ─────────────────────────────────────────────────────────
vm_count       = 2
vm_name_prefix = "iac-demo"
```

### Özelleştirilebilir Parametreler

| Değişken        | Varsayılan           | Açıklama                         |
|-----------------|----------------------|----------------------------------|
| `vm_name_prefix`| `iac-demo`           | Tüm kaynakların isim öneki       |
| `vm_count`      | `1`                  | Proxmox'ta oluşturulacak VM sayısı |
| `proxmox_node`  | `proxmox-01`         | Proxmox cluster node adı         |

Modül seviyesinde değiştirilebilecek parametreler için `main.tf` içindeki modül bloklarına bakın:

```hcl
module "openstack_infra" {
  source       = "./modules/openstack-infra"
  name_prefix  = var.vm_name_prefix
  subnet_cidr  = "192.168.100.0/24"          # değiştirilebilir
  image_name   = "ULAKBIM-Ubuntu-22.04-jammy" # değiştirilebilir
  flavor_name  = "fkm.c2m4.d20"              # değiştirilebilir
  vm_metadata  = { managed_by = "opentofu" }
}

module "proxmox_vms" {
  source       = "./modules/proxmox-vm"
  name_prefix  = var.vm_name_prefix
  node_name    = var.proxmox_node
  vm_count     = var.vm_count
  cores        = 2      # değiştirilebilir
  memory_mb    = 2048   # değiştirilebilir
  disk_size_gb = 20     # değiştirilebilir
  started      = false  # true yapılırsa VM boot eder (bootable image gerekir)
}
```

---

## Kullanım

### 1. Planı Görüntüle

Herhangi bir değişiklik yapmadan önce ne oluşturulacağını görmek için:

```bash
tofu plan
```

Örnek çıktı:
```
Plan: 13 to add, 0 to change, 0 to destroy.

  + openstack_networking_network_v2.network
  + openstack_networking_subnet_v2.subnet
  + openstack_networking_router_v2.router
  + openstack_networking_router_interface_v2.router_iface
  + openstack_networking_secgroup_v2.sg
  + openstack_networking_secgroup_rule_v2.ssh
  + openstack_networking_secgroup_rule_v2.icmp
  + openstack_networking_port_v2.vm_port
  + openstack_compute_instance_v2.vm
  + openstack_networking_floatingip_v2.fip
  + openstack_networking_floatingip_associate_v2.fip_assoc
  + proxmox_virtual_environment_vm.vm[0]
  + proxmox_virtual_environment_vm.vm[1]
```

### 2. Altyapıyı Oluştur

```bash
tofu apply
```

Onay istemeden uygulamak için:

```bash
tofu apply -auto-approve
```

Tamamlandığında outputs görüntülenir:
```
Outputs:
openstack_floating_ip = "95.183.252.173"
openstack_vm_name     = "iac-demo-vm"
openstack_subnet_cidr = "192.168.100.0/24"
proxmox_vm_ids        = [100, 101]
proxmox_vm_names      = ["iac-demo-1", "iac-demo-2"]
```

### 3. Mevcut State'i Görüntüle

```bash
# Yönetilen tüm kaynakları listele
tofu state list

# Belirli bir kaynağın detaylarını gör
tofu state show module.openstack_infra.openstack_compute_instance_v2.vm
tofu state show module.proxmox_vms.proxmox_virtual_environment_vm.vm[0]
```

### 4. Outputs'u Tekrar Görüntüle

```bash
tofu output
tofu output openstack_floating_ip
```

### 5. VM'e SSH ile Bağlan

OpenStack VM'i oluştuktan sonra floating IP üzerinden bağlanabilirsiniz:

```bash
FLOATING_IP=$(tofu output -raw openstack_floating_ip)
ssh -i ~/.ssh/alperen-macbook ubuntu@$FLOATING_IP
```

---

## Oluşturulan Kaynaklar

### Katman 1: OpenStack (`modules/openstack-infra`)

| Kaynak                    | İsim                    | Açıklama                              |
|---------------------------|-------------------------|---------------------------------------|
| Network                   | `iac-demo-network`      | Private tenant network                |
| Subnet                    | `iac-demo-subnet`       | 192.168.100.0/24, DNS: 8.8.8.8        |
| Router                    | `iac-demo-router`       | `ext_net`'e bağlı                     |
| Router Interface          | —                       | Router ↔ Subnet bağlantısı           |
| Security Group            | `iac-demo-sg`           | SSH (22) ve ICMP izinleri             |
| Neutron Port              | `iac-demo-port`         | VM için sabit port (FIP için gerekli) |
| Compute Instance          | `iac-demo-vm`           | Ubuntu 22.04, fkm.c2m4.d20 flavor    |
| Floating IP               | —                       | `ext_net`'ten alınan public IP        |
| Floating IP Association   | —                       | FIP ↔ Port bağlantısı                |

**Security Group Kuralları:**

| Yön     | Protokol | Port | Kaynak    |
|---------|----------|------|-----------|
| Ingress | TCP      | 22   | 0.0.0.0/0 |
| Ingress | ICMP     | —    | 0.0.0.0/0 |

### Katman 2: Proxmox (`modules/proxmox-vm`)

| Kaynak              | İsim           | Açıklama                         |
|---------------------|----------------|----------------------------------|
| VM (count=2)        | `iac-demo-1`   | vmid: 100, 2 CPU, 2GB RAM, 20GB  |
| VM (count=2)        | `iac-demo-2`   | vmid: 101, 2 CPU, 2GB RAM, 20GB  |

> **Not:** `started = false` olarak ayarlıdır. VM'ler oluşturulur ama boot etmez (bootable OS image olmadığı için). Production'da cloud image ile `started = true` yapılabilir.

---

## Outputs

| Output               | Açıklama                      |
|----------------------|-------------------------------|
| `openstack_floating_ip` | VM'e atanan public IP      |
| `openstack_vm_name`  | Oluşturulan VM adı            |
| `openstack_subnet_cidr` | Oluşturulan subnet CIDR'ı  |
| `proxmox_vm_ids`     | Proxmox VM ID listesi         |
| `proxmox_vm_names`   | Proxmox VM isim listesi       |

---

## Temizlik

Tüm kaynakları yok etmek için:

```bash
tofu destroy
```

Onay istemeden:

```bash
tofu destroy -auto-approve
```

> **Dikkat:** Bu komut tüm oluşturulmuş kaynakları (VM'ler, network, floating IP dahil) kalıcı olarak siler.

### Belirli Bir Modülü Yok Etme

```bash
# Sadece Proxmox VM'lerini sil
tofu destroy -target=module.proxmox_vms

# Sadece OpenStack altyapısını sil
tofu destroy -target=module.openstack_infra
```

### State'ten Kaynak Çıkarma (fiziksel silmeden)

```bash
# Kaynağı state'ten çıkar (silmez, sadece takibini bırakır)
tofu state rm module.proxmox_vms.proxmox_virtual_environment_vm.vm[0]
```

---

## State Yönetimi

Bu POC **local state** kullanmaktadır. State dosyası `terraform.tfstate` olarak proje dizininde oluşturulur.

```bash
# State dosyasını görüntüle (ham JSON)
cat terraform.tfstate | jq .

# State'deki kaynakları listele
tofu state list

# State'i yenile (gerçek altyapıyla senkronize et)
tofu refresh
```

### Production için Remote State Önerisi

Local state ekip çalışmasına uygun değildir. Production ortamında S3/MinIO backend önerilir:

```hcl
# versions.tf'e eklenecek blok
terraform {
  backend "s3" {
    bucket                      = "opentofu-state"
    key                         = "ulakfkm/iac-poc/terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "https://minio.ulakfkm.gov.tr"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
```

---

## Sık Karşılaşılan Sorunlar

### "External network not found"

OpenStack'teki dış ağ adı `public` değil `ext_net` olabilir. Kontrol edin:

```bash
source openrc.sh
openstack --insecure network list --external
```

`modules/openstack-infra/variables.tf` içindeki `external_network_name` değişkenini güncelleyin.

### "Storage 'local-lvm' does not exist"

Proxmox'ta `local-lvm` yerine `local` (directory type) kullanılıyor olabilir. `main.tf` içinde:

```hcl
module "proxmox_vms" {
  datastore_id = "local"  # local-lvm yerine
}
```

### "QEMU exited with code 1"

VM boot etmeye çalışıyor ama bootable disk yok. `started = false` yapın:

```hcl
module "proxmox_vms" {
  started = false
}
```

### Floating IP VM'e bağlanmıyor

Bu proje explicit Neutron port kullanır. Port olmadan FIP association güvenilir değildir. `modules/openstack-infra/main.tf` içindeki `openstack_networking_port_v2` kaynağının mevcut olduğundan emin olun ve VM'in `network { port = ... }` ile bu porta bağlandığını doğrulayın.

### Provider kaynak bulunamıyor (modüler yapı)

Her modülün kendi `versions.tf` dosyası olmalıdır. Örneğin `modules/proxmox-vm/versions.tf`:

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
  }
}
```

Bu dosya olmadan OpenTofu provider'ın nereden geleceğini bilemez.

---

## Güvenlik Notları

- `terraform.tfvars` dosyası asla git'e eklenmemelidir (`.gitignore`'a ekleyin)
- `os_password` ve `proxmox_api_token` `sensitive = true` olarak işaretlenmiştir
- Production'da `insecure = true` kullanmayın; geçerli TLS sertifikası yapılandırın
- Proxmox API token'ı için en az ayrıcalık ilkesini uygulayın (root yerine dedicated kullanıcı)
- Security group'ta `0.0.0.0/0` yerine belirli IP aralıkları kullanın
