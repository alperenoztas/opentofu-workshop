# OpenTofu Workshop — ULAKFKM

OpenStack ve Proxmox üzerinde Infrastructure as Code (IaC) uygulamalı eğitim.

**Yazar:** Alperen Öztaş — ULAKFKM

---

## Workshop Adımları

Her adım bir öncekinin üzerine inşa edilir. Kodları birlikte yazın; bitirince ilgili branch ile karşılaştırın.

| Branch | Konu | Hedef Komut |
|--------|------|-------------|
| `main` | Başlangıç noktası | — |
| `lab-step1` | Provider & değişken tanımları | `tofu init` |
| `lab-step2` | İlk kaynaklar (düz/flat yapı) | `tofu plan` |
| `lab-step3` | OpenStack modüle alınır | `tofu plan` (aynı sonuç, temiz kod) |
| `lab-step4` | Proxmox modülü eklenir — tam çözüm | `tofu apply` |

---

## Başlamadan Önce

### 1. OpenTofu Kurulumu

```bash
# macOS
brew install opentofu

# Linux (snap)
snap install opentofu --classic

# Linux (manuel)
curl -Lo tofu.tar.gz https://github.com/opentofu/opentofu/releases/download/v1.11.5/tofu_1.11.5_linux_amd64.tar.gz
tar -xzf tofu.tar.gz && sudo mv tofu /usr/local/bin/
tofu version
```

### 2. Credential Dosyası Oluşturun

```bash
cd poc-modular/
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars dosyasını kendi bilgilerinizle doldurun
```

> `terraform.tfvars` dosyası `.gitignore`'a eklenmiştir — git'e gitmez.

### 3. Adımlara Göre İlerleme

```bash
# Mevcut adımı kontrol et
git branch

# Sonraki adıma geç (ya da sadece karşılaştır)
git checkout lab-step2
```

---

## Proje Yapısı (Son Hali)

```
poc-modular/
├── main.tf                    # Modülleri çağıran ana dosya
├── versions.tf                # Provider sürüm kilitleri
├── providers.tf               # Provider yapılandırmaları
├── variables.tf               # Giriş değişkenleri
├── terraform.tfvars.example   # Örnek credential şablonu
└── modules/
    ├── openstack-infra/       # Katman 1: OpenStack ağ + VM
    └── proxmox-vm/            # Katman 2: Proxmox VM'leri
```
